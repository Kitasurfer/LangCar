import ComposableArchitecture

public struct AppState: Equatable, Sendable {
    public var words: IdentifiedArrayOf<Word> = []
    public init() {}
}
