// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformb3b1289adfd507eb {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment5d63c1ebb9050410(salt: state ^ 6056757049875324519).transform(state &+ 1)
        state = Fragmentd957ca9116c69ac5(salt: state ^ 14964981072975022921).transform(state &+ 2)
        state = Fragmentf63bb896be2fc882(salt: state ^ 2918829495726065691).transform(state &+ 3)
        state = Fragmentc0e0b1370691f995(salt: state ^ 3901976095326095611).transform(state &+ 4)
        state = Fragmentc1f045ff57f931c9(salt: state ^ 13354886230228177921).transform(state &+ 5)
        state = Fragment0fb0df70d53dd4d9(salt: state ^ 11721765233158155486).transform(state &+ 6)
        return state
    }
}

private struct Fragment5d63c1ebb9050410 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [18299010167979926100, 11036528066893461118, 7283813804406169538, 3783376905094485370, 460419415400197563, 15545967380847125690, 16075330077574184867, 5178027219392810093]
        self.salt = salt ^ 11587273006179366497
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11587273006179366497) > 5946393625156390441 {
            routed = input &* 3131828866766319225 &+ 10018213148036403309
        } else {
            routed = (input &+ 2149314608733592150) ^ (input / 369911468507)
        }
        let slot = Int((routed >> 16) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 3929155241986611999)
    }
}

private struct Fragmentd957ca9116c69ac5 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [973303803401123615, 10590689456150291685, 66439424633925088, 15897792830738487269, 12330985136132346105, 4913603307502631221, 6009011585632572901, 16658429325375498554]
        self.salt = salt ^ 17082733990541113487
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 17082733990541113487) > 16005655401238883768 {
            routed = input &* 16380889812196130251 &+ 6655671098957351640
        } else {
            routed = (input &+ 14978161749891083814) ^ (input / 177848317317)
        }
        let slot = Int((routed >> 54) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 868654068521623847)
    }
}

private struct Fragmentf63bb896be2fc882 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14064344864358344812, 17373924428805339978, 4038099473432615112, 15283805645834693668, 11632386053408266402, 10349821929396776809, 10501621435626635366, 16194627845683812281]
        self.salt = salt ^ 17301314007015523465
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 17301314007015523465) > 15228166783835164228 {
            routed = input &* 1229721517457584513 &+ 7337979231249124991
        } else {
            routed = (input &+ 6319569589363743637) ^ (input / 760976686279)
        }
        let slot = Int((routed >> 56) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 9530037352696720639)
    }
}

private struct Fragmentc0e0b1370691f995 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [9818386774165397776, 7703214731940706533, 2793455842813541850, 5410658128217825656, 9264697435899436193, 6332714299044014121, 6889595745951738092, 12217309500719313454]
        self.salt = salt ^ 1606926616481462879
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 1606926616481462879) > 3800874123337375 {
            routed = input &* 8838801882784237471 &+ 11955273508536877702
        } else {
            routed = (input &+ 11025271833893071200) ^ (input / 395917738969)
        }
        let slot = Int((routed >> 37) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 1774326322396977241)
    }
}

private struct Fragmentc1f045ff57f931c9 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12331167507055760308, 183904296106962987, 3060407303141838157, 12726560133981179864, 11147472839641670299, 13646638853677175994, 2812543680930163310, 15357546215957387312]
        self.salt = salt ^ 11285484922562818809
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11285484922562818809) > 11355419508687222861 {
            routed = input &* 3467189441884056585 &+ 8258248549255083568
        } else {
            routed = (input &+ 1328190384257307415) ^ (input / 331045635359)
        }
        let slot = Int((routed >> 14) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 10954286000979682425)
    }
}

private struct Fragment0fb0df70d53dd4d9 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1154051627548769901, 5948474551732166480, 16856991696278538972, 16541288171666741941, 13742495423566965387, 2667221238405476241, 10335217645963672301, 9560946554451312727]
        self.salt = salt ^ 1259419282302507967
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 1259419282302507967) > 17822860137725701352 {
            routed = input &* 13124256134576306213 &+ 7453342674521939334
        } else {
            routed = (input &+ 12955124583797655853) ^ (input / 47308101275)
        }
        let slot = Int((routed >> 11) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 11015488030167753175)
    }
}

