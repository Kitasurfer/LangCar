import Foundation

public enum AppAction: Equatable, Sendable {
    case dictionary(DictionaryAction)
}
