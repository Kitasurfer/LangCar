import Foundation
import Combine

protocol WordRepositoryProtocol {
    func fetchWords() -> AnyPublisher<[Word], Error>
    func saveWord(_ word: Word) -> AnyPublisher<Void, Error>
}

class WordRepository: WordRepositoryProtocol {
    private let storage: LocalStorage
    
    init(storage: LocalStorage = LocalStorage()) {
        self.storage = storage
    }
    
    func fetchWords() -> AnyPublisher<[Word], Error> {
        storage.load(forKey: "words")
    }
    
    func saveWord(_ word: Word) -> AnyPublisher<Void, Error> {
        storage.save(word, forKey: "words")
    }
}
