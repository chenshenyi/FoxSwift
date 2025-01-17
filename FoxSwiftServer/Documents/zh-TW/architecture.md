# 架構概覽

> 本文件由 AI 輔助生成，請檢查內容的正確性

## 系統元件

```mermaid
graph TB
    Client[FoxSwift Client]
    SignalServer[Signal Server]
    WebRTC[WebRTC P2P]
    Database[(PostgreSQL)]
    
    Client -->|REST API| SignalServer
    Client -->|WebSocket| SignalServer
    Client <-->|P2P Connection| WebRTC
    SignalServer <-->|Query/Update| Database
```

### 信號伺服器

- 處理 WebRTC 信號交換
- 管理使用者連線狀態
- 提供 REST API 服務
- WebSocket 即時通訊

### 資料庫

- 儲存使用者資訊
- 記錄連線歷史
- 管理系統設定

## 資料流

### 信號流程

```mermaid
sequenceDiagram
    participant A as Client A
    participant S as Signal Server
    participant B as Client B
    
    A->>S: Connect (WebSocket)
    B->>S: Connect (WebSocket)
    A->>S: Send Offer
    S->>B: Forward Offer
    B->>S: Send Answer
    S->>A: Forward Answer
    A->>B: Direct P2P Connection
```

### 狀態管理

- 使用者狀態
  - Online/Offline
  - Connection Status
  - Last Seen

- 連線狀態
  - Signaling
  - Connected
  - Disconnected

## 技術棧

- Vapor
- Swift 6.0
- PostgreSQL
- WebSocket Protocol
- Docker
