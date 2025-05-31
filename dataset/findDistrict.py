import pandas as pd
import os
# 讀取 CSV 檔案
input_file = '臺北市流感疫苗合約醫療院所(成人)_with_latlon.csv'

df = pd.read_csv(input_file, encoding='utf-8')
# df = pd.read_csv(input_file, encoding='big5-hkscs')

file_name, _ = os.path.splitext(input_file)
output_file = file_name+'_with_district.csv'
# add_column="機構地址"
add_column="地址"
# 雙北 41 個行政區名稱列表
districts = [
    "北投區", "士林區", "內湖區", "南港區", "松山區", "信義區", "中山區", "大同區", "中正區", "萬華區",
    "大安區", "文山區", "新莊區", "淡水區", "汐止區", "板橋區", "三重區", "樹林區", "土城區", "蘆洲區",
    "中和區", "永和區", "新店區", "鶯歌區", "三峽區", "瑞芳區", "五股區", "泰山區", "林口區", "深坑區",
    "石碇區", "坪林區", "三芝區", "石門區", "八里區", "平溪區", "雙溪區", "貢寮區", "金山區", "萬里區", "烏來區"
]

# 定義函數從 address 欄位擷取區名
def extract_district(address):
    for district in districts:
        if pd.isna(address):
            return None
        if district in address:
            return district
    return None

# 新增 district 欄位
df['district'] = df[add_column].apply(extract_district)

# 可選：將結果存成新檔案
df.to_csv(output_file, index=False)

# 印出前5筆檢查
print(df[[add_column, 'district']].head())
