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


async def main():
    parser = argparse.ArgumentParser(
        description="Import a CSV file into a PostgreSQL table."
    )

    # Database arguments: default to environment variables, then to hardcoded values or None
    parser.add_argument(
        "--db-host",
        default=os.getenv("DB_DASHBOARD_HOST", "localhost"),
        help="Database host. Defaults to DB_DASHBOARD_HOST env var or 'localhost'.",
    )
    parser.add_argument(
        "--db-port",
        type=int,
        default=5432,
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
        default="dashboardmanager",
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

    index = input("please input index: ")
    colors = input("please input colors: ").split(",")
    types = input("please input types: ").split(",")
    unit = input("please input unit: ")

    print(unit, types, index, colors)

    conn = await asyncpg.connect(
        user=args.db_user,
        password=args.db_password,
        database=args.db_name,
        host=args.db_host,
        port=args.db_port,
    )

    await conn.execute(
        """
		INSERT INTO "public"."component_charts" ("index", "color", "types", "unit")
		VALUES ($1, $2, $3, $4);
	""",
        index,
        colors,
        types,
        unit,
    )

    name = input("please input name: ")
    query_type = input("please input query_type: ")
    query_chart = input("please input query_chart: ")
    city = input("please input city: ")

    await conn.execute(
        """
		INSERT INTO "public"."components" ("index", "name")
		VALUES ($1, $2);
		""",
        index,
        name,
    )

    await conn.execute(
        """
		INSERT INTO "public"."query_charts" ("index", "created_at", "updated_at", "query_type", "query_chart", "city", "time_from")
		VALUES ($1, $2, $3, $4, $5, $6, $7);
		""",
        index,
        datetime.now(),
        datetime.now(),
        query_type,
        query_chart,
        city,
        "static",
    )

    await conn.close()


if __name__ == "__main__":
    asyncio.run(main())
