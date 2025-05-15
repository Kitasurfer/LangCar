#if canImport(CloudKit)
import CloudKit

public actor CloudSyncService {
    private let container = CKContainer.default()
    private let recordType = "Word"
    
    public func upload(words: [Word]) async throws {
        // TODO: map Word → CKRecord and save; handle batching
    }
    
    public func fetch() async throws -> [Word] { 
        [] // TODO: implement
    }
}
#endif
