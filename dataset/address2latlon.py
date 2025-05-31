import pandas as pd
import requests
from openpyxl import Workbook
from tqdm import tqdm
import logging
import sys
import os
import time

# 設定標準輸出編碼為 UTF-8
sys.stdout.reconfigure(encoding='utf-8')

# 設定日誌記錄
logging.basicConfig(filename='geocode_errors.log', level=logging.INFO, encoding='utf-8',
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Google Maps Geocoding API 金鑰（請替換為您自己的 API 金鑰）
API_KEY = "AIzaSyBeCZh0rWOotV_Gi5d4QHyo_NHOivyzAQ8"

# 清理地址函數（僅保留主要地址部分）
def clean_address(address):
    if not isinstance(address, str) or not address.strip():
        logging.error(f"地址格式錯誤，非字串或空值：{address}")
        return ""
    cleaned = address.split('、')[0].split('；')[0].strip()
    if not cleaned:
        logging.error(f"清理後地址無效：{address}")
    return cleaned

# 定義地址轉經緯度的函數
def get_coordinates(address, max_retries=3):
    for attempt in range(max_retries):
        try:
            # 構建 Google Maps Geocoding API 請求
            url = f"https://maps.googleapis.com/maps/api/geocode/json?address={address}&key={API_KEY}"
            response = requests.get(url)
            data = response.json()

            # 檢查 API 回應狀態
            if data['status'] == 'OK':
                location = data['results'][0]['geometry']['location']
                lat = location['lat']
                lng = location['lng']
                print(f"地址「{address}」轉換成功：緯度={lat}, 經度={lng}")
                logging.info(f"地址「{address}」轉換成功：緯度={lat}, 經度={lng}")
                return lat, lng
            else:
                error_message = data.get('error_message', '無詳細錯誤訊息')
                print(f"地址「{address}」無法解析，API 狀態：{data['status']}，錯誤訊息：{error_message}")
                logging.warning(f"地址「{address}」無法解析，API 狀態：{data['status']}，錯誤訊息：{error_message}")
                if data['status'] in ['OVER_QUERY_LIMIT', 'REQUEST_DENIED'] and attempt < max_retries - 1:
                    time.sleep(2)  # 若超過請求限制或被拒絕，等待後重試
                    continue
                return None, None
        except Exception as e:
            print(f"地址「{address}」轉換失敗: {e}")
            logging.error(f"地址「{address}」轉換失敗: {e}")
            if attempt < max_retries - 1:
                time.sleep(2)  # 等待後重試
            continue
    print(f"地址「{address}」轉換失敗，已達最大重試次數")
    logging.error(f"地址「{address}」轉換失敗，已達最大重試次數")
    return None, None

# 掃描資料夾並統計不含 _with_latlon 的 CSV 檔案
dataset_path = "dataset"
if not os.path.exists(dataset_path):
    print(f"資料夾 {dataset_path} 不存在，程式結束")
    logging.error(f"資料夾 {dataset_path} 不存在")
    sys.exit(1)

csv_files = [f for f in os.listdir(dataset_path) if f.endswith('.csv')]
without_latlon_count = len([f for f in csv_files if '_with_latlon' not in f])
print(f"掃描到 {len(csv_files)} 個 CSV 檔案，其中不含 '_with_latlon' 的檔案數量為 {without_latlon_count}")
logging.info(f"掃描到 {len(csv_files)} 個 CSV 檔案，其中不含 '_with_latlon' 的檔案數量為 {without_latlon_count}")

# 處理每個不含 _with_latlon 的 CSV 檔案
for csv_file in [f for f in csv_files if '_with_latlon' not in f]:
    input_file = os.path.join(dataset_path, csv_file)
    output_file = os.path.join(dataset_path, csv_file.replace('.csv', '_with_latlon.csv'))
    
    try:
        df = pd.read_csv(input_file, encoding='utf-8')
        print(f"處理檔案: {csv_file}, 欄位：{df.columns.tolist()}")  # 打印欄位名稱以驗證
    except Exception as e:
        logging.error(f"讀取檔案 {input_file} 失敗: {e}")
        print(f"讀取檔案 {input_file} 失敗: {e}")
        continue

    # 檢查並處理地址欄位
    address_column = '地址'
    if address_column not in df.columns:
        logging.error(f"檔案 {csv_file} 未找到欄位「{address_column}」，可用欄位：{df.columns.tolist()}")
        print(f"檔案 {csv_file} 未找到欄位「{address_column}」，可用欄位：{df.columns.tolist()}")
        continue

    # 初始化經緯度欄位
    df['緯度'] = None
    df['經度'] = None

    # 將經緯度欄位插入到地址欄位後方
    cols = df.columns.tolist()
    address_idx = cols.index(address_column)
    cols = cols[:address_idx + 1] + ['緯度', '經度'] + cols[address_idx + 1:]
    df = df[cols]

    # 轉換地址為經緯度
    for idx in tqdm(range(len(df)), desc=f"處理 {csv_file} 地址"):
        raw_address = df.at[idx, address_column]
        addr = clean_address(raw_address)
        if not addr:
            print(f"檔案 {csv_file} 第 {idx} 行地址無效：{raw_address}")
            logging.error(f"檔案 {csv_file} 第 {idx} 行地址無效：{raw_address}")
            continue
        lat, lng = get_coordinates(addr + ", 台灣")
        df.at[idx, '緯度'] = lat
        df.at[idx, '經度'] = lng
        time.sleep(0.5)  # 避免過快請求，符合 Google API 每秒 50 次限制

    # 儲存結果到新 CSV 檔案
    try:
        df.to_csv(output_file, index=False)
        print(f"檔案 {csv_file} 處理完成，結果儲存至 {output_file}")
        logging.info(f"檔案 {csv_file} 處理完成，結果儲存至 {output_file}")
    except Exception as e:
        print(f"儲存檔案 {output_file} 失敗: {e}")
        logging.error(f"儲存檔案 {output_file} 失敗: {e}")