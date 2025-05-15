import ComposableArchitecture
import SwiftUI

public struct StartState: Equatable, Sendable {
    public var levels: [String] = ["A1", "A2", "B1", "B2", "C1", "C2"]
    public var selectedLevel: String?
    
    public init(selectedLevel: String? = nil) {
        self.selectedLevel = selectedLevel
    }
}

public enum StartAction: Equatable, Sendable {
    case levelSelected(String)
    case startLearning
    case delegate(Delegate)
    
    public enum Delegate: Equatable, Sendable {
        case routeToRoadMap(String)
    }
}

public struct StartReducer: Reducer {
    public init() {}
    
    public var body: some Reducer<StartState, StartAction> {
        Reduce { state, action in
            switch action {
            case let .levelSelected(level):
                state.selectedLevel = level
                return .none
                
            case .startLearning:
                guard let level = state.selectedLevel else { return .none }
                return .send(.delegate(.routeToRoadMap(level)))
                
            case .delegate:
                return .none
            }
        }
    }
}

public struct StartView: View {
    let store: StoreOf<StartReducer>
    
    public init(store: StoreOf<StartReducer>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                titleView
                levelSelectionView(viewStore: viewStore)
                startButton(viewStore: viewStore)
                carImage
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var titleView: some View {
        VStack(spacing: 10) {
            Text("🚗 LangCar")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(SwiftUI.Color.accentColor)
            
            Text("Выберите уровень немецкого языка")
                .font(.headline)
        }
    }
    
    private func levelSelectionView(viewStore: ViewStore<StartState, StartAction>) -> some View {
        HStack(spacing: 15) {
            ForEach(viewStore.levels, id: \.self) { level in
                levelButton(level: level, viewStore: viewStore)
            }
        }
        .padding(.top, 20)
    }
    
    private func levelButton(level: String, viewStore: ViewStore<StartState, StartAction>) -> some View {
        Button(action: {
            viewStore.send(.levelSelected(level))
        }) {
            Text(level)
                .font(.title2.bold())
                .frame(width: 50, height: 50)
                .background(viewStore.selectedLevel == level ? SwiftUI.Color.accentColor : SwiftUI.Color.gray.opacity(0.2))
                .foregroundColor(viewStore.selectedLevel == level ? SwiftUI.Color.white : SwiftUI.Color.primary)
                .clipShape(Circle())
        }
    }
    
    private func startButton(viewStore: ViewStore<StartState, StartAction>) -> some View {
        Button(action: {
            viewStore.send(.startLearning)
        }) {
            Text("Начать путешествие")
                .font(.headline)
                .foregroundColor(SwiftUI.Color.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewStore.selectedLevel != nil ? SwiftUI.Color.accentColor : SwiftUI.Color.gray)
                .cornerRadius(10)
        }
        .disabled(viewStore.selectedLevel == nil)
        .padding(.horizontal, 40)
        .padding(.top, 30)
    }
    
    private var carImage: some View {
        Image(systemName: "car.fill")
            .font(.system(size: 72))
            .foregroundColor(SwiftUI.Color.accentColor)
            .shadow(radius: 5)
            .padding(.top, 30)
    }
}
