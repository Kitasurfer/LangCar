import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI
#endif

public struct Flashcard: Equatable, Identifiable, Sendable {
    public let id: String
    public let word: Word
    public var revealed = false
    public init(word: Word) { self.word = word; self.id = word.id }
}

public struct FlashSessionState: Equatable, Sendable {
    public var queue: [Flashcard] = []
    public var currentIndex: Int = 0
    public var finished: Bool { currentIndex >= queue.count }
}

public enum FlashSessionAction: Equatable, Sendable {
    case start([Word])
    case reveal
    case answer(correct: Bool)
    case next
    case restart
}

public struct FlashSessionReducer: Reducer {
    let repo: WordRepositoryProtocol
    public init(repo: WordRepositoryProtocol) { self.repo = repo }
    public var body: some Reducer<FlashSessionState, FlashSessionAction> {
        Reduce { state, action in
            switch action {
            case let .start(words):
                state.queue = words.shuffled().map(Flashcard.init)
                state.currentIndex = 0
                return .none
            case .reveal:
                guard !state.finished else { return .none }
                state.queue[state.currentIndex].revealed = true
                return .none
            case let .answer(correct):
                guard !state.finished else { return .none }
                let card = state.queue[state.currentIndex]
                let currentWord = card.word
                let prevInterval = currentWord.nextReviewDate.flatMap { Int($0.timeIntervalSince(currentWord.lastSeen ?? Date())/86400) } ?? 0
                var updatedWord = currentWord
                updatedWord.lastSeen = Date()
                updatedWord.nextReviewDate = Calendar.current.date(byAdding: .day, value: correct ? prevInterval * 2 + 1 : 1, to: Date())
                return .run { [repo, updatedWord] _ in
                    var all = try await repo.load()
                    if let idx = all.firstIndex(where: { $0.id == updatedWord.id }) {
                        all[idx] = updatedWord
                        try await repo.save(all)
                    }
                }.concatenate(with: Effect.send(.next))
            case .next:
                state.currentIndex += 1
                return .none
            case .restart:
                state.currentIndex = 0
                state.queue.shuffle()
                return .none
            }
        }
    }
}


