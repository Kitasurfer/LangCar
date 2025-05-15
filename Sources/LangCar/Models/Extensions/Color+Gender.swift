import SwiftUI

extension GermanGender {
    var accentColor: SwiftUI.Color {
        switch self {
        case .der: return SwiftUI.Color.blue
        case .die: return SwiftUI.Color(red: 1, green: 0.45, blue: 0.65)   // universal «pink»
        case .das: return SwiftUI.Color.green
        }
    }
}
