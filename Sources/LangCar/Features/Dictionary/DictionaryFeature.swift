import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI
#endif

public struct DictionaryState: Equatable, Sendable {
    public var words: IdentifiedArrayOf<Word> = []
    public var search: String = ""
    // Sheet
    @PresentationState public var addWord: AddWordState?
}

public enum DictionaryAction: Equatable, Sendable {
    case onAppear
    case wordsLoaded(Result<[Word], Error>)
    case search(String)
    case addTapped
    case addWord(PresentationAction<AddWordAction>)
    case wordDeleted(IndexSet)
}

public struct DictionaryReducer: Reducer {
    let repo: WordRepositoryProtocol
    public init(repo: WordRepositoryProtocol) { self.repo = repo }
    public var body: some Reducer<DictionaryState, DictionaryAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [repo] send in
                    do { let list = try await repo.load(); await send(.wordsLoaded(.success(list))) }
                    catch { await send(.wordsLoaded(.failure(error))) }
                }
            case let .wordsLoaded(.success(list)):
                state.words = IdentifiedArray(uniqueElements: list)
                return .none
            case .wordsLoaded(.failure):
                return .none  // TODO: error UI
            case let .search(q):
                state.search = q; return .none
            case .addTapped:
                state.addWord = AddWordState(); return .none
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
        .ifLet(\.$addWord, action: /DictionaryAction.addWord) { AddWordReducer() }
    }
}

#if canImport(SwiftUI)
public struct DictionaryView: View {
    let store: StoreOf<DictionaryReducer>
    public init(store: StoreOf<DictionaryReducer>) { self.store = store }
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
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
                .searchable(text: vs.binding(get: \.$search, send: DictionaryAction.search))
                .navigationTitle("Словарь")
                .toolbar { Button(action: { vs.send(.addTapped) }) { Image(systemName: "plus") } }
                .sheet(store: store.scope(state: \.$addWord, action: DictionaryAction.addWord)) { scoped in
                    AddWordView(store: scoped)
                }
            }
            .onAppear { vs.send(.onAppear) }
        }
    }
}
#endif
