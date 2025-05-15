import Foundation
import ComposableArchitecture

public struct AppState: Equatable, Sendable {
    public var dictionary: DictionaryState? = DictionaryState()
    public var flashcards: FlashSessionState? = FlashSessionState()
    public var roadmap: RoadMapState? = RoadMapState()
    public var race: RaceState? = RaceState()
    public var settings: SettingsState? = SettingsState()
    public var xp: Int = 0
    
    public init() {}
    
    public static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.dictionary == rhs.dictionary &&
        lhs.flashcards == rhs.flashcards &&
        lhs.roadmap == rhs.roadmap &&
        lhs.race == rhs.race &&
        lhs.settings == rhs.settings &&
        lhs.xp == rhs.xp
    }
}
