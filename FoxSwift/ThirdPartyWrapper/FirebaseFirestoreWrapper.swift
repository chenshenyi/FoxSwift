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
    case offerSdp = "OfferSdp"
    case answerSdp = "AnswerSdp"
    case sdp = "Sdp"
    case iceCandidates = "IceCandidates"
    case withParticipant = "Participants"
    case messages = "Messages"
}


class FSCollectionManager<DataType: Codable, CodingKeys: CodingKey> {
    typealias CompletionHandler<T> = (_ result: Result<T, Error>) -> Void

    var reference: CollectionReference
    var collectionListener: ListenerRegistration?
    var documentListener: [String: ListenerRegistration] = [:]

    private let db = Firestore.firestore()

    init(collection: FSCollection) {
        reference = db.collection(collection.rawValue)
    }

    private init(reference: CollectionReference) {
        self.reference = reference
    }

    convenience init(
        fatherDocument: [(collection: FSCollection, documentId: String)],
        collection: FSCollection
    ) {
        guard let rootDocument = fatherDocument.first else {
            self.init(collection: collection)
            return
        }
        let root = Firestore.firestore()
            .collection(rootDocument.collection.rawValue)
            .document(rootDocument.documentId)
        let reference = fatherDocument[1...].reduce(root) { partialResult, document in
            partialResult.collection(document.collection.rawValue)
                .document(document.documentId)
        }
        self.init(reference: reference.collection(collection.rawValue))
    }

    func listenCollection(
        listenToAddedOnly: Bool = false,
        completion: @escaping CompletionHandler<[DataType]>
    ) {
        collectionListener = reference.addSnapshotListener { [weak self] querySnapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let querySnapshot, let self else {
                completion(.failure(FSCollectionError.unknownError))
                return
            }

            let documentDecodeResult = listenToAddedOnly
                ? listenToAdded(querySnapshot: querySnapshot)
                : listenToAll(querySnapshot: querySnapshot)

            let documetFailures = documentDecodeResult.failedResults()
            let documentData = documentDecodeResult.successfulResults()


            if documetFailures.isEmpty {
                completion(.success(documentData))
            } else {
                documetFailures.forEach { completion(.failure($0)) }
            }
        }
    }

    private func listenToAll(querySnapshot: QuerySnapshot) -> [Result<DataType, Error>] {
        querySnapshot.documents.map { document in
            decodeDocument(document: document)
        }
    }

    private func listenToAdded(querySnapshot: QuerySnapshot) -> [Result<DataType, Error>] {
        querySnapshot.documentChanges.compactMap { documentChange in
            if documentChange.oldIndex != -1 {
                return nil
            }
            let document = documentChange.document
            return decodeDocument(document: document)
        }
    }

    private func decodeDocument(document: QueryDocumentSnapshot) -> Result<DataType, Error> {
        do {
            let documentData = try document.data(as: DataType.self)
            return .success(documentData)
        } catch {
            return .failure(error)
        }
    }

    func stopListenCollection() {
        collectionListener?.remove()
        collectionListener = nil
    }

    func listenToDocument(
        documentID: String,
        completion: @escaping CompletionHandler<DataType>
    ) {
        documentListener[documentID] = reference.document(documentID)
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
                    let documentData = try snapshot.data(as: DataType.self)
                    completion(.success(documentData))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    func stopListenDocument(documentID: String) {
        documentListener[documentID]?.remove()
        documentListener[documentID] = nil
    }

    func createDocument(data: DataType, completion: CompletionHandler<String>? = nil) {
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

    func createDocument(
        data: DataType,
        documentID: String,
        completion: CompletionHandler<String>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif
        do {
            try reference.document(documentID).setData(from: data) { error in
                if let error {
                    completion?(.failure(error))
                    return
                }
                completion?(.success(documentID))
            }
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

    func readDocument(
        documentID: String,
        completion: @escaping CompletionHandler<DataType>
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
                let documentData = try snapshot.data(as: DataType.self)
                completion(.success(documentData))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateDocument(
        data: DataType,
        documentID: String,
        completion: CompletionHandler<DataType>? = nil
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

extension FSCollectionManager {
    func updateData(
        data: DataType,
        documentID: String,
        field: KeyedDecodingContainer<CodingKeys>.Key,
        completion: CompletionHandler<DataType>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif

        reference.document(documentID).updateData(
            [field.stringValue: data]
        ) { error in
            if let error {
                completion?(.failure(error))
                return
            }
            completion?(.success(data))
        }
    }

    func removeObjects<T: Codable>(
        objects: [T],
        documentID: String,
        field: KeyedDecodingContainer<CodingKeys>.Key,
        completion: CompletionHandler<[T]>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif

        let serialDatas: [[String: Any]] = objects.compactMap { data in
            guard let jsonData = try? JSONEncoder().encode(data) else { return nil }
            return try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        }

        reference.document(documentID).updateData(
            [field.stringValue: FieldValue.arrayRemove(serialDatas)]
        ) { error in
            if let error {
                completion?(.failure(error))
                return
            }
            completion?(.success(objects))
        }
    }

    func unionObjects<T: Codable>(
        objects: [T],
        documentID: String,
        field: KeyedDecodingContainer<CodingKeys>.Key,
        completion: CompletionHandler<[T]>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif

        let serialDatas: [[String: Any]] = objects.compactMap { data in
            guard let jsonData = try? JSONEncoder().encode(data) else { return nil }
            return try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        }

        reference.document(documentID).updateData(
            [field.stringValue: FieldValue.arrayUnion(serialDatas)]
        ) { error in
            if let error {
                completion?(.failure(error))
                return
            }
            completion?(.success(objects))
        }
    }

    func removeSerialObjects<T: Codable>(
        serialObjects: [T],
        documentID: String,
        field: KeyedDecodingContainer<CodingKeys>.Key,
        completion: CompletionHandler<[T]>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif

        reference.document(documentID).updateData(
            [field.stringValue: FieldValue.arrayRemove(serialObjects)]
        ) { error in
            if let error {
                completion?(.failure(error))
                return
            }
            completion?(.success(serialObjects))
        }
    }

    func unionSerialObjects<T: Codable>(
        serialObjects: [T],
        documentID: String,
        field: KeyedDecodingContainer<CodingKeys>.Key,
        completion: CompletionHandler<[T]>? = nil
    ) {
        #if DEBUG
            guard WRITELIMIT > 0 else { return }
            WRITELIMIT -= 1
        #endif

        reference.document(documentID).updateData(
            [field.stringValue: FieldValue.arrayUnion(serialObjects)]
        ) { error in
            if let error {
                completion?(.failure(error))
                return
            }
            completion?(.success(serialObjects))
        }
    }
}
