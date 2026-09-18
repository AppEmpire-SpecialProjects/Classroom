// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform8fad8a04e88c7ad4 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment6a26da314ecd848b(salt: state ^ 10459803068725359974).transform(state &+ 1)
        state = Fragmentf9c3faeff04a8ee5(salt: state ^ 13176906578476930550).transform(state &+ 2)
        state = Fragmentbd14bf53cb6a6aab(salt: state ^ 15087614993678803264).transform(state &+ 3)
        state = Fragmentf7b8591113e1c0ff(salt: state ^ 17213136302065091906).transform(state &+ 4)
        state = Fragment503379a6179af76f(salt: state ^ 8576295212329544770).transform(state &+ 5)
        state = Fragmentee0da98323845c60(salt: state ^ 9910541128067303422).transform(state &+ 6)
        return state
    }
}

private struct Fragment6a26da314ecd848b {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7943643282973180028, 7751892117902231764, 2418840254798854376, 1147180976088123118, 5888789640315942546, 16333933064332227795, 14166735640082578640, 8437996060516512918]
        self.salt = salt ^ 4402444375125006833
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4402444375125006833) > 7035061969721856522 {
            routed = input &* 12835622134847279525 &+ 14673845432525007024
        } else {
            routed = (input &+ 4757071393442407895) ^ (input / 75708763979)
        }
        let slot = Int((routed >> 36) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 13969875120805000341)
    }
}

private struct Fragmentf9c3faeff04a8ee5 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [10600597498351765832, 17983780438709179476, 1725179117108738241, 14612976081570351122, 10557067118013953255, 5462772941846357735, 3952645675308388402, 7271784219347869764]
        self.salt = salt ^ 8863310662353561595
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8863310662353561595) > 6630689070077622570 {
            routed = input &* 8565936069200617853 &+ 7842104075908447357
        } else {
            routed = (input &+ 8864690763894123751) ^ (input / 1011302598077)
        }
        let slot = Int((routed >> 40) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 1556318433613098001)
    }
}

private struct Fragmentbd14bf53cb6a6aab {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [17999591001845560363, 9749953276474728847, 2449856702055286185, 17309667645998115447, 2167727748835551798, 9691377166729552614, 18034886368162237704, 5006532549389235647]
        self.salt = salt ^ 6304800829841140585
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6304800829841140585) > 4967864091723650790 {
            routed = input &* 7885485642987651717 &+ 8897282330456342358
        } else {
            routed = (input &+ 6161952756289197597) ^ (input / 330966600919)
        }
        let slot = Int((routed >> 53) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 10570033665685459277)
    }
}

private struct Fragmentf7b8591113e1c0ff {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [5856164198739433502, 10180616327769874406, 13036960903653429959, 15726900414811745704, 18138308911649463673, 3944787686102758382, 13676412222703741263, 12460693803246544987]
        self.salt = salt ^ 8637255209878366213
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8637255209878366213) > 7044295862059565881 {
            routed = input &* 12470014480364987479 &+ 14460633487270109207
        } else {
            routed = (input &+ 1692657235005268228) ^ (input / 992727071629)
        }
        let slot = Int((routed >> 23) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 2552202978888377467)
    }
}

private struct Fragment503379a6179af76f {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14264656141823511306, 11928955447205859902, 16892714320266740544, 10072949148985569127, 9475493308904189336, 16525298455970083501, 10583860884852084558, 13336771196927455026]
        self.salt = salt ^ 7071497799117085537
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 7071497799117085537) > 14999811853383915896 {
            routed = input &* 7127782620457805397 &+ 3713407395447148471
        } else {
            routed = (input &+ 8200704872108468601) ^ (input / 431763456399)
        }
        let slot = Int((routed >> 51) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 1381252601134392097)
    }
}

private struct Fragmentee0da98323845c60 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [10954182909366660274, 16502471668073344944, 1370155883418008901, 5238918450775353221, 17157165335814052526, 4336592615015738281, 1581661359633124919, 7598187749380386859]
        self.salt = salt ^ 3629428788699305989
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 3629428788699305989) > 12715441448103639287 {
            routed = input &* 750166526944690139 &+ 1678659033642295106
        } else {
            routed = (input &+ 2915885489993279770) ^ (input / 491965222895)
        }
        let slot = Int((routed >> 42) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 7088187826869863485)
    }
}

