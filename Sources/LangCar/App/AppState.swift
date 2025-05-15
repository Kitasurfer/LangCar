import ComposableArchitecture

public struct AppState: Equatable, Sendable {
    public var dictionary = DictionaryState()
    public init() {}
}
