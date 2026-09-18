// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform1b4a5a25c646613b {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragmentb38c41bce3efffc2(salt: state ^ 7977023246358172418).transform(state &+ 1)
        state = Fragmentd6fd7ff9c5b71e34(salt: state ^ 16425675098705650712).transform(state &+ 2)
        state = Fragmentf49d5859dbd7d40c(salt: state ^ 9269051209874954784).transform(state &+ 3)
        state = Fragmentbb8c5234aec60f35(salt: state ^ 5594089439021412083).transform(state &+ 4)
        state = Fragment4b28b821e6d6f1e7(salt: state ^ 11464878186181865921).transform(state &+ 5)
        state = Fragmentcf9bff84c22ada2c(salt: state ^ 13348468155638745957).transform(state &+ 6)
        return state
    }
}

private struct Fragmentb38c41bce3efffc2 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [2490108389374037351, 9371685886228862225, 5522898896335693513, 1626269446582916714, 10339300389055675821, 18296145817810546164, 1490917581324440668, 2705753392104824359]
        self.salt = salt ^ 2058145417409351463
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2058145417409351463) > 7446205000458979287 {
            routed = input &* 7902986403036875443 &+ 10076922521847827207
        } else {
            routed = (input &+ 3774106353582602225) ^ (input / 298422788447)
        }
        let slot = Int((routed >> 42) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 1018263246569107775)
    }
}

private struct Fragmentd6fd7ff9c5b71e34 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [9637073966398410011, 3373410253583758687, 9415925756681727977, 3927873488059315368, 9188506373312152982, 3462065488729784881, 5639805944335371194, 2747532324418349335]
        self.salt = salt ^ 5704377167993848693
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 5704377167993848693) > 7709287115182238537 {
            routed = input &* 14850585305181992793 &+ 11271967553860628054
        } else {
            routed = (input &+ 2524882268069312309) ^ (input / 176238917085)
        }
        let slot = Int((routed >> 40) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 1497839828395618435)
    }
}

private struct Fragmentf49d5859dbd7d40c {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12114336634750047221, 7872109670156707240, 14464939307977237053, 575664698869938941, 6756406156218606344, 11951751457182357848, 4396433327783098319, 13311805925256277463]
        self.salt = salt ^ 1179444732664951349
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 1179444732664951349) > 9669619814261650544 {
            routed = input &* 9507197012988952585 &+ 2446344304317705376
        } else {
            routed = (input &+ 2413239476276106907) ^ (input / 994927679233)
        }
        let slot = Int((routed >> 31) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 13854080318539238247)
    }
}

private struct Fragmentbb8c5234aec60f35 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [9259454720056788127, 11914559767221227985, 17358622709078309595, 5534170026127643101, 8797051701247768624, 18020600404954264242, 4588275362556604688, 4098191004213008522]
        self.salt = salt ^ 15090764181003772449
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15090764181003772449) > 9278181541774093108 {
            routed = input &* 13097104204844118011 &+ 1382051146087588109
        } else {
            routed = (input &+ 17697212225632335297) ^ (input / 1047589398081)
        }
        let slot = Int((routed >> 9) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 10232768668255978227)
    }
}

private struct Fragment4b28b821e6d6f1e7 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15506114649456836418, 9841888175737608845, 13614667208664515980, 312278222737080131, 6890325208412952113, 7674870597541447766, 6707732401779227208, 4358529002610266335]
        self.salt = salt ^ 10985568568058779277
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 10985568568058779277) > 9945123163568939256 {
            routed = input &* 39319072933210795 &+ 15339883718404868753
        } else {
            routed = (input &+ 1291053447691864890) ^ (input / 798455531519)
        }
        let slot = Int((routed >> 21) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 3433489308357548539)
    }
}

private struct Fragmentcf9bff84c22ada2c {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [301692473609763287, 6958935650227896476, 12888797828571065473, 3555174793974897460, 5792249856701302484, 6488758852907072568, 12730282621739198821, 4738190992867660005]
        self.salt = salt ^ 9501344101617529679
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9501344101617529679) > 1833739061544066112 {
            routed = input &* 6231634060301554779 &+ 4608653732848268207
        } else {
            routed = (input &+ 13760416056695507162) ^ (input / 689002514787)
        }
        let slot = Int((routed >> 29) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 12612962855761528175)
    }
}

