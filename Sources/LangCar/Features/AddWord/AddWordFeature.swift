import ComposableArchitecture
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

public struct AddWordState: Equatable, Sendable {
    @BindingState public var original: String = ""
    @BindingState public var translation: String = ""
    @BindingState public var plural: String = ""
    @BindingState public var gender: GermanGender = .der
}

public enum AddWordAction: BindableAction, Equatable, Sendable {
    case binding(BindingAction<AddWordState>)
    case saveTapped
    case cancelTapped
    case delegate(Delegate)
    public enum Delegate: Equatable, Sendable {
        case saved(Word)
        case cancelled
    }
}

public struct AddWordReducer: Reducer {
    public init() {}
    public var body: some Reducer<AddWordState, AddWordAction> {
        CombineReducers {
            BindingReducer()
            Reduce<AddWordState, AddWordAction> { state, action in
                switch action {
                case .saveTapped:
                    guard !state.original.isEmpty, !state.translation.isEmpty else { return .none }
                    let word = Word(original: state.original, gender: state.gender, translation: state.translation, plural: state.plural.isEmpty ? nil : state.plural)
                    return .send(.delegate(.saved(word)))
                case .cancelTapped:
                    return .send(.delegate(.cancelled))
                case .binding, .delegate:
                    return .none
                }
            }
        }
    }
}

#if canImport(SwiftUI)
public struct AddWordView: View {
    let store: StoreOf<AddWordReducer>
    public init(store: StoreOf<AddWordReducer>) { self.store = store }
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if #available(iOS 16.0, macOS 13.0, *) {
                NavigationStack {
                    addWordForm(viewStore: viewStore)
                }
            } else {
                // Для старых версий используем NavigationView
                NavigationView {
                    addWordForm(viewStore: viewStore)
                }
            }
        }
    }
    
    private func addWordForm(viewStore: ViewStore<AddWordState, AddWordAction>) -> some View {
        Form {
            Section(header: Text("Немецкое слово")) {
                VStack(alignment: .leading) {
                    TextField("Haus", text: viewStore.binding(
                        get: { $0.original },
                        send: { .binding(.set(\.$original, $0)) }
                    ))
                        .textCase(.lowercase)
                    if viewStore.original.trimmingCharacters(in: .whitespaces).isEmpty && !viewStore.original.isEmpty {
                        Text("Слово не может состоять только из пробелов")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Picker("Род", selection: viewStore.binding(get: \.gender, send: { .binding(.set(\.$gender, $0)) })) {
                        Text("der").tag(GermanGender.der)
                        Text("die").tag(GermanGender.die)
                        Text("das").tag(GermanGender.das)
                    }.pickerStyle(.segmented)
                    TextField("Мн. число (опц.)", text: viewStore.binding(get: \.plural, send: { .binding(.set(\.$plural, $0)) }))
                }
            }
            
            Section(header: Text("Русский перевод")) {
                VStack(alignment: .leading) {
                    TextField("Дом", text: viewStore.binding(get: \.translation, send: { .binding(.set(\.$translation, $0)) }))
                        .submitLabel(.done)
                    if viewStore.translation.trimmingCharacters(in: .whitespaces).isEmpty && !viewStore.translation.isEmpty {
                        Text("Перевод не может состоять только из пробелов")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Добавить слово")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") { viewStore.send(.cancelTapped) }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") { viewStore.send(.saveTapped) }
                    .disabled(viewStore.original.isEmpty || viewStore.translation.isEmpty)
            }
            #elseif os(macOS)
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") { viewStore.send(.cancelTapped) }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") { viewStore.send(.saveTapped) }
                    .disabled(viewStore.original.isEmpty || viewStore.translation.isEmpty)
            }
            #endif
        }
    }
}
#endif
