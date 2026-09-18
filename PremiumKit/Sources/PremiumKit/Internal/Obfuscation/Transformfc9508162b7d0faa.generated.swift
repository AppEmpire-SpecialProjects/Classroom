// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformfc9508162b7d0faa {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment348c04346e4d2e0a(salt: state ^ 11604442203607964457).transform(state &+ 1)
        state = Fragment12a8f30f8b155c6e(salt: state ^ 8530822846210066608).transform(state &+ 2)
        state = Fragment6ea6ececcdc14f95(salt: state ^ 14625702099077278269).transform(state &+ 3)
        state = Fragmentdd3eaf77f61af830(salt: state ^ 7473497335111424081).transform(state &+ 4)
        state = Fragment49922fd32465cc45(salt: state ^ 5211157000093849520).transform(state &+ 5)
        state = Fragment342c4eb89a4439da(salt: state ^ 3460941269155388274).transform(state &+ 6)
        return state
    }
}

private struct Fragment348c04346e4d2e0a {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14360673177136619991, 7838789683660933648, 16914347896044011470, 7788998080197207703, 4405340923267032864, 1955281088213346081, 9116717112528211060, 11693536820425034821]
        self.salt = salt ^ 4737331327263108421
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4737331327263108421) > 7139400834461702886 {
            routed = input &* 10727470403268186753 &+ 11325825806952168966
        } else {
            routed = (input &+ 4630635076154364777) ^ (input / 734507316849)
        }
        let slot = Int((routed >> 16) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 3288891636387749657)
    }
}

private struct Fragment12a8f30f8b155c6e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [17514920241842208456, 11999854556189837194, 16737872415619166916, 5573537244690534975, 9734875564681510286, 12447528204686310475, 9283723581355792041, 15550301996453095387]
        self.salt = salt ^ 15773516549677049157
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15773516549677049157) > 4172452125753960349 {
            routed = input &* 63245236597066857 &+ 1737316379631022341
        } else {
            routed = (input &+ 3513458565943112696) ^ (input / 200118743869)
        }
        let slot = Int((routed >> 53) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 14839517621243291711)
    }
}

private struct Fragment6ea6ececcdc14f95 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [8297585640319892362, 2821151597930947880, 11414835265692768210, 14659228201719392364, 4314127981968199966, 15143958506966672627, 4116727462557699420, 4988039554928392100]
        self.salt = salt ^ 6825243934065505889
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6825243934065505889) > 11055394040166221130 {
            routed = input &* 16293011877326313751 &+ 8290413090675852252
        } else {
            routed = (input &+ 3899734518222005680) ^ (input / 494897639719)
        }
        let slot = Int((routed >> 9) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 14597877859833605035)
    }
}

private struct Fragmentdd3eaf77f61af830 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1236326375773533003, 5875456980754053674, 5775288292582220034, 15673854157200588313, 16244981729074660652, 7127751837515017532, 240761693302633921, 10235232246683648655]
        self.salt = salt ^ 8044644024730157257
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8044644024730157257) > 8341111038787032245 {
            routed = input &* 16089099115303460041 &+ 14432707916451128635
        } else {
            routed = (input &+ 8637506048884968984) ^ (input / 907837582451)
        }
        let slot = Int((routed >> 27) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 4936732865415335523)
    }
}

private struct Fragment49922fd32465cc45 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11076476504409237800, 5649633665967414076, 8467818288284363887, 11387829777192837167, 2886345243571911609, 7547795800882094681, 13672956410024145532, 2955480158147551520]
        self.salt = salt ^ 4007330774939085365
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4007330774939085365) > 2303756006546719115 {
            routed = input &* 12339419736672666403 &+ 6660098494215385020
        } else {
            routed = (input &+ 1939498140631110026) ^ (input / 1053305925569)
        }
        let slot = Int((routed >> 3) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 3344806679403212333)
    }
}

private struct Fragment342c4eb89a4439da {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7170905999942755819, 12134017962014354148, 6167067591659610281, 5713470947458171071, 5480069807543308260, 9564767312595467563, 8595713644325640391, 2557122694778962301]
        self.salt = salt ^ 5077984723724291605
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 5077984723724291605) > 11399250410869595856 {
            routed = input &* 17312474043780431833 &+ 7923782783394871076
        } else {
            routed = (input &+ 5400722793292005401) ^ (input / 557485507883)
        }
        let slot = Int((routed >> 25) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 9461657990507011793)
    }
}

