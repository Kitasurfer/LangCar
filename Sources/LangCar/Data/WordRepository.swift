import Foundation
import ComposableArchitecture

public struct WordRepository {
    public var loadWords: () async throws -> [Word]
    public var saveWord: (Word) async throws -> Void
    public var updateWord: (Word) async throws -> Void
    public var deleteWord: (String) async throws -> Void
    
    public init(
        loadWords: @escaping () async throws -> [Word],
        saveWord: @escaping (Word) async throws -> Void,
        updateWord: @escaping (Word) async throws -> Void,
        deleteWord: @escaping (String) async throws -> Void
    ) {
        self.loadWords = loadWords
        self.saveWord = saveWord
        self.updateWord = updateWord
        self.deleteWord = deleteWord
    }
}

extension WordRepository: DependencyKey {
    public static let liveValue = WordRepository(
        loadWords: { 
            let localStorage = LocalStorage.shared
            return try await localStorage.load("words", as: [Word].self) ?? []
        },
        saveWord: { word in
            var words = try await liveValue.loadWords()
            words.append(word)
            try await LocalStorage.shared.save(words, forKey: "words")
        },
        updateWord: { word in
            var words = try await liveValue.loadWords()
            if let index = words.firstIndex(where: { $0.id == word.id }) {
                words[index] = word
                try await LocalStorage.shared.save(words, forKey: "words")
            }
        },
        deleteWord: { id in
            var words = try await liveValue.loadWords()
            words.removeAll(where: { $0.id == id })
            try await LocalStorage.shared.save(words, forKey: "words")
        }
    )
    
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
