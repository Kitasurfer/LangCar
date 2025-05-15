import Foundation

/// 26‑character Crockford‑Base32 ULID (time‑sortable).
public struct ULID: Equatable, Hashable, Codable, Sendable {
    private static let crock: [Character] = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")
    public let hi: UInt64, lo: UInt64
    public init(date: Date = Date(), rng: inout some RandomNumberGenerator) {
        let ts = UInt64(date.timeIntervalSince1970 * 1000)
        precondition(ts < 1<<48, "ULID timestamp overflow")
        hi = ts << 16 | UInt64.random(in: 0..<1<<16, using: &rng)
        lo = UInt64.random(in: .min... .max, using: &rng)
    }
    public init() { var r = SystemRandomNumberGenerator(); self.init(rng: &r) }
    public var string: String {
        var h = hi, l = lo; var out = [Character](repeating: "0", count: 26)
        for i in stride(from: 25, through: 0, by: -1) {
            let idx = i >= 13 ? UInt8(l & 0x1F) : UInt8(h & 0x1F)
            if i >= 13 { l >>= 5 } else { h >>= 5 }
            out[i] = ULID.crock[Int(idx)]
        }
        return String(out)
    }
}

extension ULID: CustomStringConvertible { public var description: String { string } }
