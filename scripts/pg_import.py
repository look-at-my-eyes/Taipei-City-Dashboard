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

load_dotenv()


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
        ) as f:  # utf-8-sig to handle BOM
            reader = csv.reader(f)
            header = [col_name for col_name in next(reader)]
            if not header:
                print("CSV file is empty or header is missing.", file=sys.stderr)
                return

            print(f"CSV Headers: {header}")

            columns_definition = ", ".join([f'"{col}" TEXT' for col in header])
            create_table_query = f"""
            CREATE TABLE IF NOT EXISTS "{schema_name}"."{table_name}" (
                {columns_definition}
            );
            """
            print(f"Executing: {create_table_query}")
            await conn.execute(create_table_query)
            print(f"Table '{schema_name}.{table_name}' ensured to exist.")

            f.seek(0)
            next(reader)
            records_to_insert = list(reader)

            if not records_to_insert:
                print("No data rows found in CSV after header.")
                return

            qualified_table_name = f'"{schema_name}"."{table_name}"'
            print(f"Qualified table name: {qualified_table_name}")

            await conn.copy_records_to_table(
                table_name=table_name,
                records=records_to_insert,
                columns=header,
                timeout=60,
            )
            print(
                f"{len(records_to_insert)} records copied to '{schema_name}.{table_name}'."
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
