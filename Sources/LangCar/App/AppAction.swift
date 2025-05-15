import Foundation

public enum AppAction: Equatable, Sendable {
    case loadSampleData
    case addWord(Word)
    case removeWord(String) // id
}
