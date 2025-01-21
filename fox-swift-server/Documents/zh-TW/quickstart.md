# 快速開始

> 本文件由 AI 輔助生成，請檢查內容的正確性

## 前置條件

- macOS 14.0+
- Xcode 15.0+
- Vapor 4.0+
- PostgreSQL 14.0+

## 設定 PostgreSQL

- 如果沒有 PostgreSQL，可以透過以下指令安裝：

```bash
# 安裝 PostgreSQL
brew install postgresql

# 啟動 PostgreSQL
brew services start postgresql@14
```

- 建立使用者及資料庫

```bash
# 建立使用者
createuser foxswiftdev

# 建立資料庫
createdb foxswiftdb -O foxswiftdev -E utf8

# 列出資料庫以確認，應該看到 foxswiftdb
psql -l
```
