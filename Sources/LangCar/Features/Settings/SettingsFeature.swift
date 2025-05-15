import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI
#endif

public struct SettingsState: Equatable, Sendable, Identifiable {
    @UserDefault("cloudSync", defaultValue: false) public var cloudSync: Bool
    @UserDefault("reminders",  defaultValue: false) public var reminders: Bool
    @UserDefault("reminderTime", defaultValue: ReminderTime.auto) public var reminderTime: ReminderTime
    public var id: String { "settings" }
}

public enum SettingsAction: Equatable, Sendable {
    case cloudSyncToggled(Bool)
    case remindersToggled(Bool)
    case reminderTimeChanged(ReminderTime)
}

public struct SettingsReducer: Reducer {
    let cloud: CloudSyncService?; let repo: WordRepositoryProtocol
    public init(cloud: CloudSyncService? = nil, repo: WordRepositoryProtocol) { self.cloud = cloud; self.repo = repo }
    public var body: some Reducer<SettingsState, SettingsAction> {
        Reduce { state, action in
            switch action {
            case let .cloudSyncToggled(v):
                state.cloudSync = v
                guard v, let cloud = cloud else { return .none }
                return .run { _ in let words = try await repo.load(); try await cloud.upload(words: words) }
            case let .remindersToggled(v):
                state.reminders = v; return .none
            case let .reminderTimeChanged(t):
                state.reminderTime = t; return .none
            }
        }
    }
}

#if canImport(SwiftUI)
public struct SettingsView: View {
    let store: StoreOf<SettingsReducer>
    public init(store: StoreOf<SettingsReducer>) { self.store = store }
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            Form {
                Toggle("Облачная синхронизация", isOn: vs.binding(get: \.cloudSync, send: SettingsAction.cloudSyncToggled))
                Section(header: Text("Напоминания")) {
                    Toggle("Включить", isOn: vs.binding(get: \.reminders, send: SettingsAction.remindersToggled))
                    Picker("Время", selection: vs.binding(get: \.reminderTime, send: SettingsAction.reminderTimeChanged)) {
                        Text("Авто").tag(ReminderTime.auto)
                        Text("Утро").tag(ReminderTime.morning)
                        Text("Вечер").tag(ReminderTime.evening)
                    }.pickerStyle(.segmented)
                }
            }.navigationTitle("Настройки")
        }
    }
}
#endif
