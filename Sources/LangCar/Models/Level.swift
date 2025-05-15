public enum CEFRLevel: String, CaseIterable, Codable, Sendable {
    case A1, A2, B1, B2, C1, C2
    public var xpThreshold: Int {
        switch self { case .A1: 0; case .A2: 250; case .B1: 700; case .B2: 1500; case .C1: 2500; case .C2: 4000 }
    }
}
