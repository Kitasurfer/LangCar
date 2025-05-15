#if canImport(SwiftUI)
import SwiftUI
extension GermanGender {
    var accentColor: Color {
        switch self { case .der: Color.blue; case .die: Color.pink; case .das: Color.green }
    }
}
#endif
