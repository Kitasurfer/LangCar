import Foundation

public actor LocalStorage {
    public static let shared = LocalStorage()
    
    private let fileManager: FileManager
    private let documentsURL: URL
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public func save<T: Encodable>(_ value: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(value)
        let fileURL = documentsURL.appendingPathComponent(key + ".json")
        try data.write(to: fileURL)
    }
    
    public func load<T: Decodable>(_ key: String, as type: T.Type) async throws -> T? {
        let fileURL = documentsURL.appendingPathComponent(key + ".json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func delete(_ key: String) async throws {
        let fileURL = documentsURL.appendingPathComponent(key + ".json")
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
