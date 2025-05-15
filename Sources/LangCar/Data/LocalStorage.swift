import Foundation
import Combine

class LocalStorage {
    private let fileManager: FileManager
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    func save<T: Encodable>(_ item: T, forKey key: String) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            do {
                let data = try self.encoder.encode(item)
                try data.write(to: self.getURL(for: key))
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func load<T: Decodable>(forKey key: String) -> AnyPublisher<T, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            do {
                let data = try Data(contentsOf: self.getURL(for: key))
                let item = try self.decoder.decode(T.self, from: data)
                promise(.success(item))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    private func getURL(for key: String) -> URL {
        fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(key).json")
    }
}
