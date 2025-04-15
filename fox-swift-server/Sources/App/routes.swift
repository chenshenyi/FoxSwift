import Fluent
import FoxSwiftAPI
import Vapor

func routes(_ app: Application) throws {
    // Health check
    app.get { _ in "OK" }

    try app.register(collection: FS.UsersRouteCollection<UsersService>())
    try app.register(collection: MeetingRoomController())
}
