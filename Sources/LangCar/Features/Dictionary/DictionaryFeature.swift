import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI
#endif

public struct DictionaryState: Equatable, Sendable {
    public var words: IdentifiedArrayOf<Word> = []
    public var search = ""
    public var error: String? = ""
    // Sheet
    @PresentationState public var addWord: AddWordState?
}

import CasePaths

@CasePathable
public enum DictionaryAction: Equatable, Sendable {
    case onAppear
    case search(String)
    case wordDeleted(IndexSet)
    case addTapped
    case addWord(PresentationAction<AddWordAction>)
    case wordsLoaded([Word])
    case wordLoadError(String)
}

public struct DictionaryReducer: Reducer {
    let repo: WordRepositoryProtocol
    public init(repo: WordRepositoryProtocol) { self.repo = repo }
    public var body: some Reducer<DictionaryState, DictionaryAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [repo] send in
                    do { 
                        let list = try await repo.load()
                        await send(.wordsLoaded(list))
                    } catch { 
                        await send(.wordLoadError(error.localizedDescription))
                    }
                }
            case let .wordsLoaded(list):
                state.words = IdentifiedArray(uniqueElements: list)
                return .none
            case let .wordLoadError(message):
                state.error = message
                return .none
            case let .search(q):
                state.search = q; return .none
            case .addTapped:
                state.addWord = .init(); return .none
            case let .wordDeleted(set):
                state.words.remove(atOffsets: set)
                return .run { [repo, words = state.words] _ in try await repo.save(Array(words)) }
            case .addWord(.presented(.delegate(.saved(let word)))):
                state.words.append(word)
                state.addWord = nil
                return .run { [repo, words = state.words] _ in try await repo.save(Array(words)) }
            case .addWord: return .none
            }
        }
        .ifLet(\.$addWord, action: \.addWord) { AddWordReducer() }
    }
}

#if canImport(SwiftUI)
public struct DictionaryView: View {
    let store: StoreOf<DictionaryReducer>
    public init(store: StoreOf<DictionaryReducer>) { self.store = store }
    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: dictionaryContent)
    }
    
    @ViewBuilder
    private func dictionaryContent(_ vs: ViewStore<DictionaryState, DictionaryAction>) -> some View {
        if #available(macOS 13.0, *) {
            NavigationStack {
                List {
                    ForEach(vs.words.filter { vs.search.isEmpty ? true : $0.original.lowercased().contains(vs.search.lowercased()) || $0.translation.lowercased().contains(vs.search.lowercased()) }) { word in
                        HStack {
                            Text(word.original).font(.headline)
                            Text("[\(word.gender.rawValue)]").foregroundColor(.gray)
                            Spacer()
                            Text(word.translation)
                        }
                    }.onDelete { vs.send(.wordDeleted($0)) }
                }
                .searchable(text: vs.binding(get: \.search, send: DictionaryAction.search))
                .navigationTitle("Словарь")
                .toolbar { Button(action: { vs.send(.addTapped) }) { Image(systemName: "plus") } }
                .sheet(store: store.scope(state: \.$addWord, action: \.addWord)) { scoped in
                    AddWordView(store: scoped)
                }
            }
            .onAppear { vs.send(.onAppear) }
        }
    }
}
#endif
