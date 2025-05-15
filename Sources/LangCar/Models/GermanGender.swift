import Foundation

public enum GermanGender: String, Codable, CaseIterable, Equatable, Sendable {
    case der, die, das
    public var colorName: String { 
        switch self { 
        case .der: "Blue"
        case .die: "Pink"
        case .das: "Green" 
        } 
    }
}
