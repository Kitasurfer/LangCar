public struct XPManager {
    public static func level(for xp: Int) -> CEFRLevel {
        CEFRLevel.allCases.last { xp >= $0.xpThreshold } ?? .A1
    }
    public static func progressPercent(xp: Int) -> Double {
        let lvl = level(for: xp)
        let next = CEFRLevel.allCases.drop(while: { $0 != lvl }).dropFirst().first?.xpThreshold ?? (lvl.xpThreshold + 1000)
        return Double(xp - lvl.xpThreshold) / Double(next - lvl.xpThreshold)
    }
}
