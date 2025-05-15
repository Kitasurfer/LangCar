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
                var card = state.queue[state.currentIndex]
                var word = card.word
                let prevInterval = word.nextReviewDate.flatMap { Int($0.timeIntervalSince(word.lastSeen ?? Date())/86400) } ?? 0
                let ease = word.easeFactor ?? 2.5
                let result = SRS.nextInterval(correct: correct, currentEase: ease, prevInterval: prevInterval)
                word.lastSeen = Date()
                word.easeFactor = result.ease
                word.nextReviewDate = Calendar.current.date(byAdding: .day, value: result.interval, to: Date())
                // persist update in background
                return .run { [repo] _ in
                    var all = try await repo.load()
                    if let idx = all.firstIndex(where: { $0.id == word.id }) {
                        all[idx] = word
                        try await repo.save(all)
                    }
                }.concatenate(with: .task { state.currentIndex += 1 })
            case .restart:
                state.currentIndex = 0
                state.queue.shuffle()
                return .none
            }
        }
    }
}

#if canImport(SwiftUI)
public struct FlashcardsView: View {
    let store: StoreOf<FlashSessionReducer>
    public init(store: StoreOf<FlashSessionReducer>) { self.store = store }
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                if vs.finished {
                    Text("✅ Сессия завершена").font(.title)
                    Button("Повторить") { vs.send(.restart) }
                } else if let card = vs.queue[safe: vs.currentIndex] {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(card.word.gender.accentColor.opacity(0.15))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(
                                VStack {
                                    Text(card.word.original).font(.largeTitle).padding()
                                    if card.revealed {
                                        Text(card.word.translation).font(.title2).transition(.scale)
                                    }
                                }.animation(.spring, value: card.revealed)
                            )
                            .padding()
                            .onTapGesture { vs.send(.reveal) }
                    }
                    HStack {
                        Button("Не знаю") { vs.send(.answer(correct: false)) }.buttonStyle(.bordered)
                        Button("Знаю") { vs.send(.answer(correct: true)) }.buttonStyle(.borderedProminent)
                    }.padding()
                } else {
                    ProgressView().task { vs.send(.restart) }
                }
            }
            .onAppear { if vs.queue.isEmpty { vs.send(.restart) } }
            .navigationTitle("Карточки")
        }
    }
}
#endif
