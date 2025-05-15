#if DEBUG
import SwiftUI
import ComposableArchitecture

struct AppPreview: View {
    let store = Store(initialState: .init()) { AppReducer(repository: WordRepository.preview) }
    var body: some View { Text("LangCar · Sprint0 Skeleton") }
}
#endif
