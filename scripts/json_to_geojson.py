# /// script
# dependencies = [
#   "pandas==2.2.3",
# ]
# ///

import json
from pathlib import Path
import argparse
import pandas as pd

REPO_ROOT = Path(__file__).parents[1]


print(f"{REPO_ROOT=}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert JSON or CSV file to GeoJSON format."
    )
    parser.add_argument("input_file", help="Path to the input JSON or CSV file.")
    args = parser.parse_args()

    input_file_path = Path(args.input_file)
    geojson_output_file = (
        REPO_ROOT
        / "Taipei-City-Dashboard-FE"
        / "public"
        / "mapData"
        / (input_file_path.stem + ".geojson")
    )
    file_extension = input_file_path.suffix.lower()

    try:
        if file_extension == ".json":
            with input_file_path.open(encoding="utf-8") as f:
                data = json.load(f)
            df = pd.DataFrame(data)
        elif file_extension == ".csv":
            df = pd.read_csv(input_file_path, encoding="utf-8")
        else:
            print(
                f"Error: Unsupported file type: {file_extension}. Please provide a .json or .csv file."
            )
            exit(1)

    except FileNotFoundError:
        print(f"Error: File not found: {input_file_path}")
        exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Failed to parse JSON file: {e}")
        exit(1)
    except pd.errors.EmptyDataError:
        print(f"Error: CSV file is empty: {input_file_path}")
        exit(1)
    except Exception as e:
        print(f"Error: Failed to read or parse CSV file: {e}")
        exit(1)

    features = []
    for index, row in df.iterrows():
        try:
            lon_col_names = ["longitude", "lon", "lng", "經度", "中心點經度"]
            lat_col_names = ["latitude", "lat", "緯度", "中心點緯度"]

            lon_col = next(
                (col for col in lon_col_names if col in row and pd.notna(row[col])),
                None,
            )
            lat_col = next(
                (col for col in lat_col_names if col in row and pd.notna(row[col])),
                None,
            )

            if lon_col is None or lat_col is None:
                print(
                    f"Warning: Row {index + 1} is missing longitude or latitude data or uses unexpected column names. Skipping."
                )
                continue

            lon = float(row[lon_col])
            lat = float(row[lat_col])
        except (ValueError, TypeError):
            print(
                f"Warning: Row {index + 1} has invalid longitude or latitude values. Skipping."
            )
            continue

        feature = {
            "type": "Feature",
            "geometry": {"type": "Point", "coordinates": [lon, lat]},
            "properties": {key: row[key] for key in df.columns if pd.notna(row[key])},
        }

        features.append(feature)

    with geojson_output_file.open(
        "w",
        encoding="utf-8",
    ) as f:
        json.dump(
            {"type": "FeatureCollection", "features": features},
            f,
            ensure_ascii=False,
            indent=2,
        )


if __name__ == "__main__":
    main()
