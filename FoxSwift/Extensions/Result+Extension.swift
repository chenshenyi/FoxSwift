//
//  Result+Extension.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/16.
//

import Foundation

extension Array {
    func successfulResults<T, E: Error>() -> [T] where Element == Result<T, E> {
        return compactMap { result in
            switch result {
            case let .success(data): return data
            case .failure: return nil
            }
        }
    }

    func failedResults<T, E: Error>() -> [E] where Element == Result<T, E> {
        return compactMap { result in
            switch result {
            case .success: return nil
            case let .failure(error): return error
            }
        }
    }
}
