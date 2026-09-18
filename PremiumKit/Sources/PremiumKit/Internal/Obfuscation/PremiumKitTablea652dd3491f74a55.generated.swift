// Generated placement table. Regenerate from a clean clone; do not edit.
internal enum PremiumKitTablea652dd3491f74a55 {
    private static let stream: [UInt8] = [218, 53, 81, 228, 57, 131, 86, 110, 33, 24, 142, 12, 44, 34, 146]
    private static let rows: [[UInt8]] = [[181, 91, 51, 139, 88, 241, 50, 7, 79, 127], [183, 84, 56, 138], [185, 90, 63, 151, 76, 238, 55, 12, 77, 125], [184, 84, 63, 138, 92, 241]]

    @inline(never)
    static func placement(_ index: Int) -> String {
        guard rows.indices.contains(index) else { return "" }
        let row = rows[index]
        let bytes = row.enumerated().map { offset, value in
            value ^ stream[offset % stream.count]
        }
        return String(decoding: bytes, as: UTF8.self)
    }
}
