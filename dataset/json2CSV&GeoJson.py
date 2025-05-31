import json
import pandas as pd
import os

# 定義繁體中文欄位名稱對應，可自行設定欄位名稱
header_mapping = {
    "pm_name": "公園名稱",
    "pm_Longitude": "經度",
    "pm_Latitude": "緯度",
    "di_area": "空間面積",
    "di_capacity": "容納人數",
    "di_Amount1": "安置登記站個數",
    "di_Amount2": "醫護站個數",
    "di_Amount3": "播音站個數",
    "di_Amount4": "物資管理站個數",
    "di_Amount5": "器材倉庫個數",
    "di_Amount6": "指揮中心個數",
    "di_Amount7": "伙食區個數",
    "di_Amount8": "帳篷區個數",
    "di_Amount9": "沐浴區個數",
    "di_Amount10": "曬衣場個數",
    "di_Amount11": "公共廁所個數",
    "di_Amount12": "垃圾場個數",
    "di_Amount13": "公共電話個數",
    "di_Amount14": "消防蓄水設施個數",
    "di_Amount15": "消防栓個數",
    "di_Amount16": "自來水取水站個數",
    "di_Amount17": "維生貯水槽個數",
    "di_Amount18": "臨時廁所設置區個數",
    "di_hospital": "週邊醫院資源",
    "di_fire": "週邊消防資源",
    "di_police": "週邊警政資源"
}

# 讀取 JSON 檔案，使用 utf-8-sig 編碼，檔名自行設定
input_file = os.path.join("dataset", "disaster_prevention_park.json")
try:
    with open(input_file, 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"錯誤：找不到檔案 {input_file}")
    exit(1)
except json.JSONDecodeError as e:
    print(f"錯誤：無法解析 JSON 檔案，原因：{e}")
    exit(1)

# 轉換為 pandas DataFrame
df = pd.DataFrame(data)

# 重新命名欄位為繁體中文
df = df.rename(columns=header_mapping)

# 儲存為 CSV，確保使用 utf-8-sig 編碼以正確顯示中文，檔名自行設定
csv_output = "disaster_prevention_park.csv"
df.to_csv(csv_output, index=False, encoding='utf-8-sig')
print(f"已生成 CSV 檔案：{csv_output}")

# 創建 GeoJSON 結構
geojson = {
    "type": "FeatureCollection",
    "features": []
}

for index, row in df.iterrows():
    # 檢查經緯度是否存在且有效
    try:
        lon = float(row["經度"])
        lat = float(row["緯度"])
    except (ValueError, TypeError):
        print(f"警告：公園 {row['公園名稱']} 的經緯度無效，跳過")
        continue

    feature = {
        "type": "Feature",
        "geometry": {
            "type": "Point",
            "coordinates": [lon, lat]
        },
        "properties": {
            key: row[key] for key in df.columns
        }
    }
    geojson["features"].append(feature)

# 儲存為 GeoJSON，檔名自行設定
geojson_output = "disaster_prevention_park.geojson"
with open(geojson_output, 'w', encoding='utf-8') as f:
    json.dump(geojson, f, ensure_ascii=False, indent=2)
print(f"已生成 GeoJSON 檔案：{geojson_output}")