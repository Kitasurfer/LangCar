import Foundation

public protocol WordRepositoryProtocol: Sendable {
    func load() async throws -> [Word]
    func save(_ list: [Word]) async throws
}

public final actor WordRepository: WordRepositoryProtocol {
    let fileURL: URL
    public init(filename: String = "Words.json", seed: String = "SeedWords_de") {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent(filename)
        if !fm.fileExists(atPath: fileURL.path) {
            if let seedURL = Bundle.main.url(forResource: seed, withExtension: "json") {
                try? fm.copyItem(at: seedURL, to: fileURL)
            }
        }
    }
    public func load() async throws -> [Word] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Word].self, from: data)
    }
    public func save(_ list: [Word]) async throws {
        let data = try JSONEncoder().encode(list)
        try data.write(to: fileURL, options: .atomic)
    }
}

extension WordRepository: DependencyKey {
    public static let liveValue = WordRepository()
    
    public static let previewValue = WordRepository()
    public static let previewValue = WordRepository(
        loadWords: { [] },
        saveWord: { _ in },
        updateWord: { _ in },
        deleteWord: { _ in }
    )
}

extension DependencyValues {
    public var wordRepository: WordRepository {
        get { self[WordRepository.self] }
        set { self[WordRepository.self] = newValue }
    }
}
