import SwiftUI

struct WordOfTheDayCard: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Слово дня")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(word.original)
                .font(.title)
                .foregroundColor(.primary)
            
            HStack {
                Text(word.gender.rawValue)
                    .font(.subheadline)
                    .foregroundColor(word.gender.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(word.gender.accentColor.opacity(0.1))
                    .cornerRadius(8)
                
                if let plural = word.plural {
                    Text("мн.ч.: \(plural)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(word.translation)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    private var genderColor: Color {
        switch word.gender {
        case .der: return .blue
        case .die: return .red
        case .das: return .green
        }
    }
}
