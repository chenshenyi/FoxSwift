# 系統需求

> 本文件由 AI 輔助生成，請檢查內容的正確性

[English](../en/requirements.md)

## 開發環境

### 必要條件

- macOS 13.0+
- Xcode 16.2+
- Swift 6.0+

### 資料庫

- PostgreSQL 14+
  - 用於儲存使用者資料和連線狀態
  - 建議使用最新版本以獲得更好的效能

### 選用條件

- Docker 24.0+
  - 用於容器化部署
  - 本地開發可使用 Docker Compose

## 網路需求

### 連接埠

- 8080：HTTP/WebSocket（預設）
- 5432：PostgreSQL
- 443：HTTPS（正式環境）
