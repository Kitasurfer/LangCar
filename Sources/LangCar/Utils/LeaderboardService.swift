#if canImport(CloudKit)
import CloudKit
public actor LeaderboardService {
    private let recordType = "RaceScore"; private let db = CKContainer.default().publicCloudDatabase
    public init() {}
    public struct Entry: Identifiable, Sendable, Equatable { public let id: String; public let name: String; public let score: Int }

    public func submit(score: Int, name: String) async throws {
        let rec = CKRecord(recordType: recordType, recordID: .init(recordName: ULID().string))
        rec["name"] = name as CKRecordValue; rec["score"] = score as CKRecordValue
        try await db.save(rec)
    }
    public func top(limit: Int = 25) async throws -> [Entry] {
        let q = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        q.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        let (match, _) = try await db.records(matching: q, desiredKeys: ["name", "score"], resultsLimit: limit)
        return try match.compactMap { _, res -> Entry? in
            let rec = try res.get(); return Entry(id: rec.recordID.recordName, name: rec["name"] as? String ?? "?", score: rec["score"] as? Int ?? 0) }
    }
}
#endif
