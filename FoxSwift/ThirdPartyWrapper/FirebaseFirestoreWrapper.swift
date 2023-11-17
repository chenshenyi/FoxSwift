//
//  Firebase.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/16.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

#if DEBUG
    var WRITELIMIT = 100
#endif

enum FSCollectionError: Error {
    case unknownError
}

enum FSCollection: String {
    case meetingRoom = "MeetingRoom"
    case participantDetail = "ParticipantDetail"
}

protocol FSField: RawRepresentable where RawValue == String {}

class FSCollectionManager {
    static let meetingRoom = FSCollectionManager(collection: .meetingRoom)
    static let participantDetail = FSCollectionManager(collection: .participantDetail)

    typealias CompletionHandler<T> = (_ result: Result<T, Error>) -> Void

    var collection: String
    var collectionListener: ListenerRegistration?
    var documentListener: [String: ListenerRegistration] = [:]

    init(collection: FSCollection) {
        self.collection = collection.rawValue
    }

    private var db: Firestore {
        Firestore.firestore()
    }

    private var reference: CollectionReference {
        db.collection(collection)
    }

    func listenCollection<T: Decodable>(
        asType: T.Type,
        completion: @escaping CompletionHandler<[T]>
    ) {
        collectionListener = reference.addSnapshotListener { querySnapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let querySnapshot else {
                completion(.failure(FSCollectionError.unknownError))
                return
            }


            let documentDecodeResult: [Result<T, Error>] = querySnapshot.documents
                .map { document in
                    do {
                        let documentData = try document.data(as: T.self)
                        return .success(documentData)
                    } catch {
                        return .failure(error)
                    }
                }

            let documetFailures = documentDecodeResult.failedResults()
            let documentData = documentDecodeResult.successfulResults()


            if documetFailures.isEmpty {
                completion(.success(documentData))
            } else {
                documetFailures.forEach { completion(.failure($0)) }
            }
        }
    }

    func stopListenCollection() {
        collectionListener?.remove()
        collectionListener = nil
    }

    func listenToDocument<T: Decodable>(
        asType: T.Type,
        documentId: String,
        completion: @escaping CompletionHandler<T>
    ) {
        documentListener[documentId] = reference.document(documentId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let snapshot else {
                    completion(.failure(FSCollectionError.unknownError))
                    return
                }

                do {
                    let documentData = try snapshot.data(as: T.self)
                    completion(.success(documentData))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    func stopListenDocument(documentId: String) {
        documentListener[documentId]?.remove()
        documentListener[documentId] = nil
    }

    func createDocument(data: Codable, completion: CompletionHandler<String>? = nil) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif
        do {
            let documentReference = try reference.addDocument(from: data)
            completion?(.success(documentReference.documentID))
        } catch {
            completion?(.failure(error))
        }
    }

    func deleteDocument(documentID: String, completion: CompletionHandler<String>? = nil) {
        reference.document(documentID).delete { error in
            if let error {
                completion?(.failure(error))
            } else {
                completion?(.success(documentID))
            }
        }
    }

    func readDocument<T: Codable>(
        asType: T.Type,
        documentID: String,
        completion: @escaping CompletionHandler<T>
    ) {
        reference.document(documentID).getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let snapshot else {
                completion(.failure(FSCollectionError.unknownError))
                return
            }

            do {
                let documentData = try snapshot.data(as: T.self)
                completion(.success(documentData))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateDocument<T: Codable>(
        data: T,
        documentID: String,
        completion: CompletionHandler<T>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif

        do {
            try reference.document(documentID).setData(from: data, merge: true)
            completion?(.success(data))
        } catch {
            completion?(.failure(error))
        }
    }

    func removeDatas<T: Codable>(
        datas: [T],
        documentID: String,
        field: any FSField,
        completion: CompletionHandler<[T]>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif

        let serialDatas: [[String: Any]] = datas.compactMap { data in
            guard let jsonData = try? JSONEncoder().encode(data) else { return nil }
            return try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        }

        reference.document(documentID).updateData(
            [field.rawValue: FieldValue.arrayRemove(serialDatas)]
        ) { error in
            if let error {
                completion?(.failure(error))
                return
            }
            completion?(.success(datas))
        }
    }

    func unionDatas<T: Codable>(
        datas: [T],
        documentID: String,
        field: any FSField,
        completion: CompletionHandler<[T]>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif

        let serialDatas: [[String: Any]] = datas.compactMap { data in
            guard let jsonData = try? JSONEncoder().encode(data) else { return nil }
            return try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        }

        reference.document(documentID).updateData(
            [field.rawValue: FieldValue.arrayUnion(serialDatas)]
        ) { error in
            if let error {
                completion?(.failure(error))
                return
            }
            completion?(.success(datas))
        }
    }

    #if DEBUG
        func clearCollection() {
            reference.getDocuments { snapshot, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                guard let snapshot else {
                    print("unknown error")
                    return
                }
                snapshot.documents.forEach { $0.reference.delete() }
            }
        }
    #endif
}
