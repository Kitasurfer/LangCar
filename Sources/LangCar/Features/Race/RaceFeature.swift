import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#endif

public struct RaceState: Equatable, Sendable { public var top: [LeaderboardService.Entry] = []; public var myScore: Int = 0 }
public enum RaceAction: Equatable, Sendable {
    case onAppear
    case scoresLoaded(Result<[LeaderboardService.Entry], Never>)
    case participateTapped
}

public struct RaceReducer: Reducer {
    let leaderboard: LeaderboardService
    public init(leaderboard: LeaderboardService = .init()) { self.leaderboard = leaderboard }
    public var body: some Reducer<RaceState, RaceAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do { let list = try await leaderboard.top(); await send(.scoresLoaded(.success(list))) }
                    catch { print(error) }
                }
            case let .scoresLoaded(.success(list)):
                state.top = list; return .none
            case .scoresLoaded(.failure): return .none
            case .participateTapped:
                state.myScore += 10
                return .run { [score = state.myScore] _ in
                    #if canImport(UIKit)
                    try? await leaderboard.submit(score: score, name: UIDevice.current.name)
                    #else
                    try? await leaderboard.submit(score: score, name: "Player")
                    #endif
                }
            }
        }
    }
}

#if canImport(SwiftUI)
public struct RaceView: View {
    let store: StoreOf<RaceReducer>
    public init(store: StoreOf<RaceReducer>) { self.store = store }
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            List {
                Section("Таблица лидеров") {
                    ForEach(Array(vs.top.enumerated()), id: \.offset) { i, e in
                        HStack { Text("#\\(i+1)"); Text(e.name); Spacer(); Text("\\(e.score)") }
                    }
                }
                Button("Участвовать (+10 очков)") { vs.send(.participateTapped) }
            }
            .navigationTitle("Гонка")
            .onAppear { vs.send(.onAppear) }
        }
    }
}
#endif
