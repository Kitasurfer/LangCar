import Foundation

public struct ULID {
    private let value: UUID
    
    public init() {
        self.value = UUID()
    }
    
    public var string: String {
        value.uuidString.lowercased()
    }
}
