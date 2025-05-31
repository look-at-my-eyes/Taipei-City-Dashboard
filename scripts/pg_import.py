# /// script
# dependencies = [
#   "asyncpg==0.30.0",
#   "python-dotenv",
# ]
# ///

import csv
import argparse
import asyncio
import sys
import os
import asyncpg
from dotenv import load_dotenv
from datetime import datetime
from typing import Any

load_dotenv()

TYPE_PRIORITY = {
    "INTEGER": 1,
    "NUMERIC": 2,
    "DOUBLE PRECISION": 2,
    "TIMESTAMP WITH TIME ZONE": 3,
    "TIMESTAMP WITHOUT TIME ZONE": 4,
    "TEXT": 5,
}

PRIORITY_TO_TYPE = {
    1: "INTEGER",
    2: "NUMERIC",
    3: "TIMESTAMP WITH TIME ZONE",
    4: "TIMESTAMP WITHOUT TIME ZONE",
    5: "TEXT",
}

type_to_python_type = {
    "INTEGER": int,
    "NUMERIC": float,
    "TIMESTAMP WITH TIME ZONE": datetime,
    "TIMESTAMP WITHOUT TIME ZONE": datetime,
    "TEXT": str,
}


# Helper function to infer data type
def infer_pg_type(value_str: str) -> str:
    try:
        int(value_str)
        return "INTEGER"
    except ValueError:
        try:
            float(value_str)
            return "NUMERIC"
        except ValueError:
            try:
                iso_datetime = datetime.fromisoformat(value_str)
                if iso_datetime.tzinfo:
                    return "TIMESTAMP WITH TIME ZONE"
                return "TIMESTAMP WITHOUT TIME ZONE"
            except ValueError:
                return "TEXT"


async def import_csv_to_pg(
    csv_file_path: str,
    table_name: str,
    db_host: str,
    db_port: int,
    db_user: str,
    db_password: str,
    db_name: str,
    schema_name: str,
):
    """
    Imports data from a CSV file into a PostgreSQL table.
    """
    conn = None
    try:
        conn = await asyncpg.connect(
            user=db_user,
            password=db_password,
            database=db_name,
            host=db_host,
            port=db_port,
        )
        print(f"Successfully connected to database '{db_name}' on {db_host}:{db_port}")

        # Read CSV header
        with open(
            csv_file_path, "r", encoding="utf-8-sig"
            # csv_file_path, "r", encoding="big5-hkscs"
            
        ) as f:  # utf-8-sig to handle BOM
            reader = csv.reader(f)
            header = [col_name for col_name in next(reader)]
            if not header:
                print("CSV file is empty or header is missing.", file=sys.stderr)
                return

            print(f"CSV Headers: {header}")

            f.seek(0)
            reader_for_type_inference = csv.reader(f)
            next(reader_for_type_inference)  # Skip header

            sample_rows = []
            for i, row in enumerate(reader_for_type_inference):
                if i >= 100:  # Sample up to 100 rows
                    break
                sample_rows.append(row)

            # Determine column types based on sample data
            inferred_column_types = ["TEXT"] * len(header)  # Default to TEXT

            if sample_rows:
                for col_idx in range(len(header)):
                    current_col_max_priority = -1  # Lower than any actual priority
                    for sample_row in sample_rows:
                        if (
                            col_idx < len(sample_row)
                            and sample_row[col_idx] is not None
                        ):
                            value_str = sample_row[col_idx].strip()
                            if (
                                value_str
                            ):  # Ensure it's not an empty string after stripping
                                potential_type = infer_pg_type(value_str)
                                priority = TYPE_PRIORITY[potential_type]
                                if priority > current_col_max_priority:
                                    current_col_max_priority = priority
                                # Optimization: if TEXT is reached, it's the most general
                                if current_col_max_priority == TYPE_PRIORITY["TEXT"]:
                                    break

                    if (
                        current_col_max_priority != -1
                    ):  # If any type was identified for the column
                        inferred_column_types[col_idx] = PRIORITY_TO_TYPE[
                            current_col_max_priority
                        ]
            # If sample_rows is empty or a column had no identifiable non-empty values, it remains TEXT.

            print(f"Inferred column types: {list(zip(header, inferred_column_types))}")

            columns_definition_parts = ['"id" SERIAL PRIMARY KEY']
            columns_definition_parts.extend(
                [
                    f'"{col_name}" {col_type}'
                    for col_name, col_type in zip(header, inferred_column_types)
                ]
            )
            columns_definition = ", ".join(columns_definition_parts)
            create_table_query = f"""
            CREATE TABLE IF NOT EXISTS "{schema_name}"."{table_name}" (
                {columns_definition}
            );
            """

            print(f"Executing: {create_table_query}")
            await conn.execute(create_table_query)
            print(f"Table '{schema_name}.{table_name}' ensured to exist.")

            f.seek(0)
            reader = csv.reader(f)  # Re-initialize reader for data insertion
            next(reader)  # Skip header again

            raw_records_from_csv = list(reader)
            typed_records_to_insert = []

            if not raw_records_from_csv:
                print("No data rows found in CSV after header.")
                return

            for row_num, record_values in enumerate(raw_records_from_csv):
                if len(record_values) != len(header):
                    print(
                        f"Warning: Row {row_num + 1} has {len(record_values)} columns, expected {len(header)}. Skipping. Data: {record_values}",
                        file=sys.stderr,
                    )
                    continue

                typed_row: list[Any | None] = []
                for i, value_str in enumerate(record_values):
                    target_pg_type = inferred_column_types[i]
                    python_converter = type_to_python_type[target_pg_type]
                    stripped_value = value_str.strip()

                    if not stripped_value:
                        typed_row.append(None)  # Convert empty strings to None for DB
                    else:
                        try:
                            if python_converter == datetime:
                                # Ensure consistency with infer_pg_type's format
                                typed_row.append(datetime.fromisoformat(stripped_value))
                            else:
                                typed_row.append(python_converter(stripped_value))
                        except ValueError:
                            print(
                                f"Warning: Row {row_num + 1}, Column '{header[i]}': Could not convert '{stripped_value}' to {target_pg_type}. Inserting NULL.",
                                file=sys.stderr,
                            )
                            typed_row.append(
                                None
                            )  # Fallback to None if conversion fails
                typed_records_to_insert.append(tuple(typed_row))

            if not typed_records_to_insert:
                print(
                    "No processable data rows found in CSV after header and type conversion."
                )
                return

            await conn.copy_records_to_table(
                table_name=table_name,
                records=typed_records_to_insert,
                columns=header,
                schema_name=schema_name,  # Added schema_name for robustness
                timeout=60,
            )
            print(
                f"{len(typed_records_to_insert)} records copied to '{schema_name}.{table_name}'."
            )

    except FileNotFoundError:
        print(f"Error: CSV file not found at '{csv_file_path}'", file=sys.stderr)
    except asyncpg.exceptions.PostgresError as e:
        print(f"Database error: {e}", file=sys.stderr)
    except ValueError as e:
        print(f"Value error (e.g., bad column name): {e}", file=sys.stderr)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
    finally:
        if conn:
            await conn.close()
            print("Database connection closed.")


async def main():
    parser = argparse.ArgumentParser(
        description="Import a CSV file into a PostgreSQL table."
    )
    parser.add_argument("--csv-file", required=True, help="Path to the CSV file.")
    parser.add_argument("--table-name", required=True, help="Name of the target table.")

    # Database arguments: default to environment variables, then to hardcoded values or None
    parser.add_argument(
        "--db-host",
        default=os.getenv("DB_DASHBOARD_HOST", "localhost"),
        help="Database host. Defaults to DB_DASHBOARD_HOST env var or 'localhost'.",
    )
    parser.add_argument(
        "--db-port",
        type=int,
        default=os.getenv("DB_DASHBOARD_PORT", "5432"),
        help="Database port. Defaults to DB_DASHBOARD_PORT env var or 5432.",
    )
    parser.add_argument(
        "--db-user",
        default=os.getenv("DB_DASHBOARD_USER"),
        help="Database user. Defaults to DB_DASHBOARD_USER env var.",
    )
    parser.add_argument(
        "--db-password",
        default=os.getenv("DB_DASHBOARD_PASSWORD"),
        help="Database password. Defaults to DB_DASHBOARD_PASSWORD env var.",
    )
    parser.add_argument(
        "--db-name",
        default=os.getenv("DB_DASHBOARD_DATABASE", "dashboard"),
        help="Database name. Defaults to DB_DASHBOARD_DATABASE env var or 'dashboard'.",
    )
    parser.add_argument(
        "--schema-name",
        default=os.getenv("DB_DASHBOARD_SCHEMA", "public"),
        help="Schema name. Defaults to DB_DASHBOARD_SCHEMA env var or 'public'.",
    )

    args = parser.parse_args()

    if not args.db_user:
        print(
            "Error: Database user not provided. Set DB_DASHBOARD_USER environment variable or use --db-user argument.",
            file=sys.stderr,
        )
        sys.exit(1)
    if not args.db_password:
        print(
            "Error: Database password not provided. Set DB_DASHBOARD_PASSWORD environment variable or use --db-password argument.",
            file=sys.stderr,
        )
        sys.exit(1)

    await import_csv_to_pg(
        args.csv_file,
        args.table_name,
        args.db_host,
        args.db_port,
        args.db_user,
        args.db_password,
        args.db_name,
        args.schema_name,
    )


if __name__ == "__main__":
    asyncio.run(main())
