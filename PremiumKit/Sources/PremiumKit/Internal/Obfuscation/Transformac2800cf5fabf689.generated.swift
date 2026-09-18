// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformac2800cf5fabf689 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragmente266f70d93d647b4(salt: state ^ 1091380436358346437).transform(state &+ 1)
        state = Fragment957b30f6b96ac551(salt: state ^ 6731311253487331428).transform(state &+ 2)
        state = Fragmente8ebf7c2385d562b(salt: state ^ 8645619217806408174).transform(state &+ 3)
        state = Fragment445d1e67dd3bab4f(salt: state ^ 3684011394614057603).transform(state &+ 4)
        state = Fragment95e056a5e9c1e2e0(salt: state ^ 17952527492065171117).transform(state &+ 5)
        state = Fragment39dce8672567f5f1(salt: state ^ 12860748056119576366).transform(state &+ 6)
        return state
    }
}

private struct Fragmente266f70d93d647b4 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11324267950110428051, 16744671576545136474, 6678570063371119186, 1214977140631918898, 9089833764584773975, 11752338135070410341, 3704468623455433265, 17153878430793595292]
        self.salt = salt ^ 4791861387655570355
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4791861387655570355) > 1579929868772814771 {
            routed = input &* 5716138167896055217 &+ 3135838244544758010
        } else {
            routed = (input &+ 16681999743605064767) ^ (input / 292185386315)
        }
        let slot = Int((routed >> 22) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 11424749966317176839)
    }
}

private struct Fragment957b30f6b96ac551 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3177276479888727049, 3024182516795453251, 12339593012448657176, 17669058452795804556, 1701503270718897842, 2318054869023954191, 16752306675129481111, 13544460771714863971]
        self.salt = salt ^ 4795300886434055969
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4795300886434055969) > 2862602567200944222 {
            routed = input &* 10335587606990392237 &+ 6057760653954809869
        } else {
            routed = (input &+ 2219198232531553902) ^ (input / 817069196533)
        }
        let slot = Int((routed >> 27) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 4424462956878513171)
    }
}

private struct Fragmente8ebf7c2385d562b {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12790099049458697301, 15416490013027722909, 3129362852362796476, 7579575921370892185, 1627154298192465260, 17140121776750731058, 3984753606291797144, 2902005588480687719]
        self.salt = salt ^ 16744518346288649091
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 16744518346288649091) > 3757391421660755655 {
            routed = input &* 14456567853920638645 &+ 17905603481661674009
        } else {
            routed = (input &+ 14792823080104194824) ^ (input / 133514944041)
        }
        let slot = Int((routed >> 45) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 792350097361160091)
    }
}

private struct Fragment445d1e67dd3bab4f {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3069618301712867055, 4400911582381379627, 6203781394148309352, 11703170938559576406, 4910444850905617171, 13241651924393771330, 10673435479873144693, 17165914602804033166]
        self.salt = salt ^ 2682730175794675609
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2682730175794675609) > 16798357324929145332 {
            routed = input &* 2754202600755836529 &+ 16595073672207792428
        } else {
            routed = (input &+ 8405247793514863638) ^ (input / 679639541579)
        }
        let slot = Int((routed >> 14) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 8718279632504258619)
    }
}

private struct Fragment95e056a5e9c1e2e0 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [4698935377748758356, 3386052093610678138, 17657231765585712037, 18003583892448627824, 6130269824789651588, 5186416826788597073, 10281177030957912310, 10769437226179381951]
        self.salt = salt ^ 8973133058870971595
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8973133058870971595) > 15054664380112952472 {
            routed = input &* 9723742522550226457 &+ 6236050316190778793
        } else {
            routed = (input &+ 14356838591562549485) ^ (input / 323826427575)
        }
        let slot = Int((routed >> 49) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 11693735595996400925)
    }
}

private struct Fragment39dce8672567f5f1 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [8017023170751254174, 389043184299772782, 9849013052288686523, 13657948859978478008, 13751485386971128562, 18155857236767500102, 13543991503575944892, 8350900412405376414]
        self.salt = salt ^ 10432676001277094719
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 10432676001277094719) > 13191654459950347051 {
            routed = input &* 11915054753185159131 &+ 9994747469224838710
        } else {
            routed = (input &+ 6220085924301030500) ^ (input / 1050742522251)
        }
        let slot = Int((routed >> 25) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 9162536225924484663)
    }
}

