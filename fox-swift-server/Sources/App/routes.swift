import Fluent
import Vapor
import FoxSwiftAPI

func routes(_ app: Application) throws {
    // Health check
    app.get { req async in "OK" }

    try app.register(collection: FS.UsersRouteCollection<UsersService>())
}
