#if canImport(SwiftUI)
import SwiftUI
import ComposableArchitecture
public struct FlashcardsView: View {
    let store: StoreOf<FlashSessionReducer>
    @State private var offset: CGSize = .zero
    private let swipeThreshold: CGFloat = 120
    @Environment(\.colorScheme) private var scheme

    public init(store: StoreOf<FlashSessionReducer>) { self.store = store }

    private func gradient(for gender: GermanGender) -> LinearGradient {
        LinearGradient(colors: [gender.accentColor.opacity(0.4), scheme == .dark ? SwiftUI.Color.black : SwiftUI.Color.white], startPoint: .top, endPoint: .bottom)
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 24) {
                // Progress bar
                ProgressView(value: Double(vs.currentIndex), total: max(1, Double(vs.queue.count)))
                    .tint(.accentColor)
                    .padding(.horizontal)

                if vs.finished {
                    Text("✅ Сессия завершена").font(.title)
                    Button("Повторить") { vs.send(.restart) }
                } else if let card = vs.queue[safe: vs.currentIndex] {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(gradient(for: card.word.gender))
                            .shadow(radius: 6)
                        VStack {
                            Text(card.word.original).font(.largeTitle.weight(.bold)).padding()
                            if card.revealed { Text(card.word.translation).font(.title2).transition(.opacity) }
                        }.animation(.easeInOut, value: card.revealed)
                    }
                    .frame(height: 320)
                    .offset(offset)
                    .rotationEffect(.degrees(Double(offset.width / 20)))
                    .gesture(
                        DragGesture()
                            .onChanged { offset = $0.translation }
                            .onEnded { _ in
                                if offset.width > swipeThreshold { vs.send(.answer(correct: true)) }
                                else if offset.width < -swipeThreshold { vs.send(.answer(correct: false)) }
                                else { vs.send(.reveal) }
                                offset = .zero
                            }
                    )
                    .animation(.spring(response: 0.35), value: offset)
                    // Next button
                    Button(action: { vs.send(.answer(correct: true)) }) {
                        Label("Дальше", systemImage: "chevron.right.circle.fill")
                            .labelStyle(.titleAndIcon)
                    }.padding(.top)
                } else { ProgressView() }
            }
            .padding()
            .onAppear { if vs.queue.isEmpty { vs.send(.restart) } }
            .task { await scheduleSmartReminder(vs: vs) }
        }
    }

    private func scheduleSmartReminder(vs: ViewStore<FlashSessionState, FlashSessionAction>) async {
        let wordsDue = vs.queue.count - vs.currentIndex
        #if os(iOS)
        // Example: Auto schedule each session using current hour
        let hour = Calendar.current.component(.hour, from: Date())
        await NotificationManager.shared.smartSchedule(autoMode: true, lastStudyHour: hour, wordsDue: wordsDue)
        #endif
    }
}
#endif
