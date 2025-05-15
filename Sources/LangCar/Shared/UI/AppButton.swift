import SwiftUI

struct AppButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(SwiftUI.Color.accentColor)
                .cornerRadius(12)
        }
    }
}
