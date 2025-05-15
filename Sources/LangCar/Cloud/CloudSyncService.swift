#if canImport(CloudKit)
import CloudKit

public actor CloudSyncService {
    private let container = CKContainer.default()
    private var db: CKDatabase { container.privateCloudDatabase }
    private let recordType = "Word"

    func toRecord(word: Word) -> CKRecord {
        let recID = CKRecord.ID(recordName: word.id)
        let rec = CKRecord(recordType: recordType, recordID: recID)
        rec["original"] = word.original as CKRecordValue
        rec["translation"] = word.translation as CKRecordValue
        rec["gender"] = word.gender.rawValue as CKRecordValue
        rec["plural"] = word.plural as CKRecordValue?
        rec["difficulty"] = word.difficulty.rawValue as CKRecordValue
        rec["ease"] = word.easeFactor as CKRecordValue?
        rec["nextReview"] = word.nextReviewDate as CKRecordValue?
        rec["lastSeen"] = word.lastSeen as CKRecordValue?
        return rec
    }

    public func upload(words: [Word]) async throws {
        let ops = words.map { CKModifyRecordsOperation(recordsToSave: [toRecord(word: $0)]) }
        for op in ops {
            let (savedResults, _) = try await db.modifyRecords(saving: op.recordsToSave ?? [], deleting: [])
            for (recordID, result) in savedResults {
                switch result {
                case .success(let savedRecord):
                    print("Successfully saved record: \(savedRecord.recordID)")
                case .failure(let error):
                    print("Failed to save record \(recordID): \(error)")
                    throw error
                }
            }
        }
    }

    public func fetch() async throws -> [Word] {
        var result: [Word] = []
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let (match, _) = try await db.records(matching: query)
        for (_, rec) in match {
            let rec = try rec.get()
            if let orig = rec["original"] as? String,
               let trans = rec["translation"] as? String,
               let gStr = rec["gender"] as? String,
               let gender = GermanGender(rawValue: gStr) {
                var w = Word(original: orig, gender: gender, translation: trans, plural: rec["plural"] as? String)
                w.id = rec.recordID.recordName
                w.difficulty = Difficulty(rawValue: rec["difficulty"] as? String ?? "medium") ?? .medium
                w.easeFactor = rec["ease"] as? Double
                w.lastSeen = rec["lastSeen"] as? Date
                w.nextReviewDate = rec["nextReview"] as? Date
                result.append(w)
            }
        }
        return result
    }
}
#endif
