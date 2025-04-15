import Testing
import VaporTesting

@testable import App

@Suite("App Tests", .serialized)
struct AppTests {
    func withApp<T>(_ block: (Application) async throws -> T) async throws -> T {
        try await VaporTesting.withApp { app in
            try await configure(app)
            try await app.autoMigrate()
            let result = try await block(app)
            try await app.autoRevert()
            return result
        }
    }

    @Test func healthCheckTest() async throws {
        try await withApp { app in
            try await app.testing().test(
                .GET,
                "",
                afterResponse: { res async in
                    #expect(res.status == .ok)
                    #expect(res.body.string == "OK")
                }
            )
            return
        }
    }
}
