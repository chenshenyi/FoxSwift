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
    case appNotExist
    case functionNotImplemented
}

extension Provider {
    public static func vaporTestingProvider(app: Application, method: Application.Method = .inMemory) -> Provider {
        let service = VaporTestingService(app: app, testingMethod: method)
        return Provider(baseURL: "", http: service)
    }
}

struct VaporTestingService: Papyrus.HTTPService {
    struct Response: Papyrus.Response {
        var request: (any PapyrusCore.Request)?
        var body: Data?
        var headers: [String : String]?
        var statusCode: Int?
        let error: (any Error)?
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
        do {
            guard let app else {
                throw TestingRequestError.appNotExist
            }

            let vaporRequest = TestingHTTPRequest(
                method: .RAW(value: req.method),
                url: .init(stringLiteral: req.url!.absoluteString),
                headers: HTTPHeaders(req.headers.map { $0 }),
                body: req.body.map(ByteBuffer.init(data:)) ?? ByteBufferAllocator().buffer(capacity: 0)
            )

            let res = try await app.testing(method: testingMethod)
                .performTest(request: vaporRequest)

            return Response(
                request: req,
                body: Data(res.body.readableBytesView),
                headers: .init(uniqueKeysWithValues: res.headers.map { $0 }),
                statusCode: Int(res.status.code),
                error: nil
            )
        } catch {
            return .error(error)
        }
    }

    func request(_ req: any PapyrusCore.Request, completionHandler: @escaping (any PapyrusCore.Response) -> Void) {
        completionHandler(.error(TestingRequestError.functionNotImplemented))
    }
}

