//
//  File.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/17.
//

import Foundation
import Papyrus
import VaporTesting

public enum TestingRequestError: Error {
    case invalidURL
    case appNotExist
    case closureNotResponse
}

extension Provider {
    public static func vaporTestingProvider(app: Application, method: Application.Method = .inMemory) -> Provider {
        let service = VaporTestingService(app: app, testingMethod: method)
        return Provider(baseURL: "", http: service)
    }
}

private struct VaporTestingService: Papyrus.HTTPService {
    struct Response: Papyrus.Response {
        var request: (any PapyrusCore.Request)?
        var body: Data?
        var headers: [String : String]?
        var statusCode: Int?
        let error: (any Error)? = nil
    }

    struct Request: Papyrus.Request {
        var body: Data?
        var url: URL?
        var method: String
        var headers: [String : String]
    }

    typealias BeforeRequestBlock = @Sendable (inout TestingHTTPRequest) async throws -> ()
    weak var app: Application?
    let testingMethod: Application.Method

    func build(method: String, url: URL, headers: [String : String], body: Data?) -> any PapyrusCore.Request {
        Request(body: body, url: url, method: method, headers: headers)
    }

    func request(_ req: any PapyrusCore.Request) async -> any PapyrusCore.Response {
        guard let app else {
            return .error(TestingRequestError.appNotExist)
        }

        guard let url = req.url else {
            return .error(TestingRequestError.invalidURL)
        }

        do {
            let vaporRequest = TestingHTTPRequest(
                method: .RAW(value: req.method),
                url: .init(stringLiteral: url.absoluteString),
                headers: HTTPHeaders(req.headers.map { $0 }),
                body: req.body.map(ByteBuffer.init(data:)) ?? ByteBufferAllocator().buffer(capacity: 0)
            )

            let res = try await app.testing(method: testingMethod)
                .performTest(request: vaporRequest)

            return Response(
                request: req,
                body: Data(res.body.readableBytesView),
                headers: .init(res.headers.map { $0 }) { _, newValue in newValue },
                statusCode: Int(res.status.code)
            )
        } catch {
            return .error(error)
        }
    }

    func request(_ req: any PapyrusCore.Request, completionHandler: @escaping (any PapyrusCore.Response) -> Void) {
        guard let url = req.url
        else {
            completionHandler(.error(TestingRequestError.invalidURL))
            return
        }

        guard let app else {
            completionHandler(.error(TestingRequestError.appNotExist))
            return
        }

        do {
            let group = dispatch_group_t()
            var res: TestingHTTPResponse?
            let method = HTTPMethod.RAW(value: req.method)
            let headers = HTTPHeaders(req.headers.map { $0 })
            let body = req.body.map(ByteBuffer.init(data:)) ?? ByteBufferAllocator().buffer(capacity: 0)
            let vaporRequest = TestingHTTPRequest(
                method: method,
                url: .init(stringLiteral: url.absoluteString),
                headers: headers,
                body: body
            )

            Task {
                group.enter()
                res = try await app.testing(method: testingMethod)
                    .performTest(request: vaporRequest)

                group.leave()
            }
            group.wait()

            guard let res else {
                throw TestingRequestError.closureNotResponse
            }
            let papyrusResponse = Response(
                request: req,
                body: Data(res.body.readableBytesView),
                headers: .init(res.headers.map { $0 }) { _, newValue in newValue },
                statusCode: Int(res.status.code)
            )
            completionHandler(papyrusResponse)
        } catch {
            completionHandler(.error(error))
        }
    }
}

