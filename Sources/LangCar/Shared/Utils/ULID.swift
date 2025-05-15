import Foundation

/// 26‑character Crockford‑Base32 ULID (time‑sortable).
public struct ULID: Equatable, Hashable, Codable, Sendable {
    private static let crockford: [Character] = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")
    public let bytes: (UInt64, UInt64)          // 128‑bit value

    public init(date: Date = Date(), rng: inout some RandomNumberGenerator) {
        let ts = UInt64(date.timeIntervalSince1970 * 1000)
        precondition(ts < (1 << 48), "Timestamp out of range for ULID")
        var hi = ts << 16                       // 48‑bit ts + 16‑bit rand
        var lo = UInt64.random(in: .min... .max, using: &rng)
        let rand16 = UInt64.random(in: 0..<1<<16, using: &rng)
        hi |= rand16
        self.bytes = (hi, lo)
    }
    
    public init() { var r = SystemRandomNumberGenerator(); self.init(rng: &r) }
    
    public var string: String {
        let (hi0, lo0) = bytes
        var hi = hi0; var lo = lo0
        var chars = [Character](repeating: "0", count: 26)
        for i in stride(from: 25, through: 0, by: -1) {
            let idx: UInt8 = i >= 13 ? UInt8(lo & 0x1F) : UInt8(hi & 0x1F)
            if i >= 13 { lo >>= 5 } else { hi >>= 5 }
            chars[i] = ULID.crockford[Int(idx)]
        }
        return String(chars)
    }
}

extension ULID: CustomStringConvertible { public var description: String { string } }
