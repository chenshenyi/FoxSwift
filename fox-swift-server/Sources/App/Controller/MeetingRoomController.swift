//
//  MeetingRoom.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/23.
//

import Foundation
import Vapor
import IdentifiedCollections

@globalActor
actor MeetingRoomActor {
    static let shared = MeetingRoomActor()
}

struct MeetingRoomController: RouteCollection {
    @MeetingRoomActor
    static var rooms: IdentifiedArrayOf<MeetingRoom> = []

    @MeetingRoomActor
    var rooms: IdentifiedArrayOf<MeetingRoom> {
        get { Self.rooms }
        nonmutating set { Self.rooms = newValue }
    }

    @MeetingRoomActor
    func getRoom(id: MeetingRoom.ID) async -> MeetingRoom {
        if let room = rooms[id: id] {
            return room
        } else {
            let room = MeetingRoom(id: id)
            rooms.append(room)
            return room
        }
    }

    @MeetingRoomActor
    func joinRoom(id: MeetingRoom.ID, userId: User.IDValue, ws: WebSocket) async {
        if rooms[id: id] == nil {
            rooms.append(MeetingRoom(id: id))
        }
        rooms[id: id]?.join(userId: userId, ws: ws)
    }

    func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.webSocket("meetingRoom", ":id") { req, ws in
            guard let id = req.parameters.get("id", as: UUID.self) else {
                do { try await ws.close() }
                catch {}
                return
            }

            guard let userId = req.headers["UserId"].first,
                  let userIdValue = UUID(uuidString: userId)
            else { return }

            await joinRoom(id: id, userId: userIdValue, ws: ws)
        }
    }
}
