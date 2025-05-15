import Foundation
import SwiftUI

@propertyWrapper
public struct UserDefault<Value: Codable & Sendable & Equatable>: Sendable, Equatable {
    let key: String
    let defaultValue: Value
    
    public init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Value {
        get { (UserDefaults.standard.object(forKey: key) as? Data)
                .flatMap { try? JSONDecoder().decode(Value.self, from: $0) } ?? defaultValue }
        mutating set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                guard let data = try? JSONEncoder().encode(newValue) else { return }
                UserDefaults.standard.set(data, forKey: key)
            }
        )
    }
}
