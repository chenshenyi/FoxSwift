# FoxSwiftServer

> This is the signal server for FoxSwift WebRTC communication.
> 這是 FoxSwift WebRTC 通訊的信號伺服器。

[![Swift](https://img.shields.io/badge/swift-6.0-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/vapor-4.0-blue.svg)](https://vapor.codes)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[English](README.md)

## 概述

FoxSwiftServer 是一個使用 Vapor 框架建立的 WebRTC 信號伺服器。它負責處理 WebRTC 信號交換，並維護點對點通訊所需的基本資料結構。

### 主要功能

- WebRTC 信號交換
- 使用者連線狀態管理
- 基本資料結構儲存

## 系統需求

- macOS 13.0+
- Xcode 16.2+
- Swift 6.0+
- PostgreSQL 14+
- Docker（選用）

## 快速開始

### 本地開發

1. 安裝依賴：

    ```bash
    brew install postgresql
    brew services start postgresql@14
    ```

2. 設定資料庫：

    ```bash
    createuser foxswiftdev
    createdb foxswiftdb -O foxswiftdev -E utf8
    ```

3. 執行伺服器：

    ```bash
    swift run
    ```

### Docker 部署

```bash
docker-compose up -d
```

## 文件

詳細文件請參考我們的[文件中心](Documents/index.zh-TW.md)。

- [系統架構概覽](Documents/zh-TW/architecture.md)
- [API 文件](Documents/zh-TW/api.md)
- [資料庫結構](Documents/zh-TW/database.md)
- [WebRTC 信號協定](Documents/zh-TW/signaling.md)
- [部署指南](Documents/zh-TW/deployment.md)

## 貢獻

在提交 Pull Request 之前，請先閱讀我們的[貢獻指南](Documents/zh-TW/contributing.md)。

## 授權條款

本專案使用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 檔案。
