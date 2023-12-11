//
//  KeyChainWrapper.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import Foundation
import Security

class KeyChainManager {
    enum SavingKey: String {
        case userData
    }

    func storeUser() {
        guard let user = FSUser.currentUser,
              let data = try? JSONEncoder().encode(user)
        else { return }

        let query = [
            kSecValueData: data,
            kSecAttrAccount: SavingKey.userData.rawValue,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        let status = SecItemAdd(query, nil)
        if status == errSecDuplicateItem {
            updateUser()
        } else if status != errSecSuccess {
            print(status)
        }
    }

    func updateUser() {
        guard let user = FSUser.currentUser,
              let data = try? JSONEncoder().encode(user)
        else { return }

        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SavingKey.userData.rawValue
        ] as CFDictionary

        let updateData = [
            kSecValueData: data
        ] as CFDictionary

        let status = SecItemUpdate(query, updateData)
        if status != errSecSuccess {
            print(status)
        }
    }

    func deleteUser() {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SavingKey.userData.rawValue
        ] as CFDictionary
        // Find user and delete
        let status = SecItemDelete(query as CFDictionary)
        if status != noErr {
            print(status)
        }
    }

    func loadUser() -> FSUser? {
        let query = [
            kSecAttrAccount: SavingKey.userData.rawValue,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        if status != errSecSuccess {
            print(status)
            return nil
        }

        guard let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(FSUser.self, from: data)
    }
}
