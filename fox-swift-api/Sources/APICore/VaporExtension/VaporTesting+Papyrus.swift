//
//  File.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/17.
//

import Foundation
import Papyrus
import VaporTesting

/// Errors that can occur during testing requests.
public enum TestingRequestError: Error {
    /// Indicates that the application instance is no longer available.
    case appNotExist
    /// Indicates that a synchronous request function is not implemented.
    case functionNotImplemented
}

extension Provider {
    /// Creates a Papyrus provider that uses Vapor's testing infrastructure.
    ///
    /// This method allows integration testing of Vapor applications using Papyrus's HTTP client interface.
    ///
    /// ## Example
    /// ```swift
    /// let app = Application(.testing)
    /// defer { app.shutdown() }
    ///
    /// let provider = Provider.vaporTestingProvider(app: app)
    /// let client = UserAPI(provider: provider)
    /// ```
    ///
    /// - Parameters:
    ///   - app: The Vapor application instance to test.
    ///   - method: The testing method to use (defaults to `.inMemory`).
    /// - Returns: A configured Papyrus provider for testing.
    public static func vaporTestingProvider(
        app: Application,
        method: Application.Method = .inMemory
    ) -> Provider {
        let service = VaporTestingService(app: app, testingMethod: method)
        return Provider(baseURL: "", http: service)
    }
}

/// A service that adapts Vapor's testing infrastructure to Papyrus's HTTP client interface.
struct VaporTestingService: Papyrus.HTTPService {
    /// Represents a response from the testing service.
    struct Response: Papyrus.Response {
        var request: (any PapyrusCore.Request)?
        var body: Data?
        var headers: [String: String]?
        var statusCode: Int?
        let error: (any Error)?
    }

    /// Represents a request to the testing service.
    struct Request: Papyrus.Request {
        var body: Data?
        var url: URL?
        var method: String
        var headers: [String: String]
    }

    /// The Vapor application instance being tested.
    weak var app: Application?

    /// The testing method being used.
    let testingMethod: Application.Method

    /// Builds a request object from the given parameters.
    /// - Parameters:
    ///   - method: The HTTP method.
    ///   - url: The request URL.
    ///   - headers: The request headers.
    ///   - body: The request body data.
    /// - Returns: A request object conforming to `PapyrusCore.Request`.
    func build(
        method: String,
        url: URL,
        headers: [String: String],
        body: Data?
    ) -> any PapyrusCore.Request {
        Request(body: body, url: url, method: method, headers: headers)
    }

    /// Performs an asynchronous HTTP request.
    /// - Parameter req: The request to perform.
    /// - Returns: A response object conforming to `PapyrusCore.Response`.
    func request(_ req: any PapyrusCore.Request) async -> any PapyrusCore.Response {
        do {
            guard
                let app,
                let urlString = req.url?.absoluteString
            else {
                throw TestingRequestError.appNotExist
            }

            let vaporRequest = TestingHTTPRequest(
                method: .RAW(value: req.method),
                url: .init(stringLiteral: urlString),
                headers: HTTPHeaders(Array(req.headers)),
                body: req.body.map(ByteBuffer.init(data:))
                    ?? ByteBufferAllocator().buffer(capacity: 0)
            )

            let res = try await app.testing(method: testingMethod)
                .performTest(request: vaporRequest)

            return Response(
                request: req,
                body: Data(res.body.readableBytesView),
                headers: .init(uniqueKeysWithValues: Array(res.headers)),
                statusCode: Int(res.status.code),
                error: nil
            )
        } catch {
            return .error(error)
        }
    }

    /// Performs a synchronous HTTP request (not implemented).
    /// - Parameters:
    ///   - req: The request to perform.
    ///   - completionHandler: A callback to handle the response.
    func request(
        _ req: any PapyrusCore.Request,
        completionHandler: @escaping (any PapyrusCore.Response) -> Void
    ) {
        completionHandler(.error(TestingRequestError.functionNotImplemented))
    }
}
