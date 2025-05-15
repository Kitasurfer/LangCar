import Foundation

public struct SRS {
    /// Basic SM‑2 algorithm. Returns next review interval (days) and new ease.
    public static func nextInterval(correct: Bool, currentEase: Double, prevInterval: Int) -> (interval: Int, ease: Double) {
        var ease = currentEase
        if correct {
            ease = max(1.3, ease + 0.1)
        } else {
            ease = max(1.3, ease - 0.2)
        }
        let interval: Int
        if prevInterval == 0 { interval = 1 }
        else if prevInterval == 1 { interval = 3 }
        else { interval = Int(Double(prevInterval) * ease) }
        return (interval, ease)
    }
}
