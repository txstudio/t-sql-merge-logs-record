# 使用 Transact-SQL 的 MERGE 進行指定資料表的同步作業

建立來源與目的地資料表內容，使用 MERGE 對資料表進行合併，並將合併結果記錄到同步紀錄資料表。

## 檔案說明

此內容有兩個 Transact-SQL 檔案
- prepare-schema.sql
- merge-with-output-record.sql

### prepare-schema.sql 

此指令碼會建立下列物件與預設的資料內容

| 物件名稱 | 備註 |
| -- | -- |
| dbo.StockList | 同步來源資料表 |
| dbo.StockList_Target | 同步目的地資料表 |
| dbo.MergeRecords | 將同步結果記錄到此資料表內容 |

資料庫物件架構圖如下

![img](https://raw.githubusercontent.com/txstudio/t-sql-merge-logs-record/master/img/structure.gif)

### merge-with-output-record.sql

使用 MERGE 指令進行 dbo.StockList 與 dbo.StockList_Target 資料表同步作業，並將異動結果記錄到 dbo.MergeRecords 資料表。

## 使用方式

執行 prepare-schema.sql 建立環境需要的物件與資料表內容，建立完成後可使用 merge-with-output-record.sql 進行資料表同步作業。

merge-with-output-record.sql 語法有加入交易 (Transaction) 設定，在同步完成後會自動 Rollback 交易。可註解交易指令碼片段將異動寫入到目的地資料表與紀錄資料表。

## 參考資料
[合併式 (TRANSACT-SQL) | Microsoft Docs](https://docs.microsoft.com/zh-tw/sql/t-sql/statements/merge-transact-sql)
