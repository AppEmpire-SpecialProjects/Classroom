// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform8d00af8dae2f0c8c {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment50acc77c73a1d884(salt: state ^ 5095807228880232491).transform(state &+ 1)
        state = Fragment401b6d45d200929a(salt: state ^ 1685013022662940927).transform(state &+ 2)
        state = Fragment6139d4d99a8a3d3c(salt: state ^ 4098477749345741931).transform(state &+ 3)
        state = Fragment1a5647ef75ec3b0e(salt: state ^ 2924214498022109124).transform(state &+ 4)
        state = Fragmentf1674ac79f3c9dc3(salt: state ^ 3556490326565276933).transform(state &+ 5)
        state = Fragment014d199ed7360a22(salt: state ^ 12858991569556684046).transform(state &+ 6)
        return state
    }
}

private struct Fragment50acc77c73a1d884 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [13336372721957459090, 2476512660968699287, 16589550876733984882, 6952480653418455615, 17820166888562926155, 17909757282439857842, 10492986977024220425, 11914496178539928589]
        self.salt = salt ^ 17890882260557765285
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 17890882260557765285) > 12724468865160660870 {
            routed = input &* 1372166480867975113 &+ 15445223225393113321
        } else {
            routed = (input &+ 1221922762547999816) ^ (input / 157811930021)
        }
        let slot = Int((routed >> 12) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 15266591407406531341)
    }
}

private struct Fragment401b6d45d200929a {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [8680107744834087305, 9593193235044038332, 6876116085323006470, 854529898953380004, 13998697018045266077, 2415222269672491229, 17324717238974507052, 1386828611253098266]
        self.salt = salt ^ 7693271796057413851
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 7693271796057413851) > 17574489805058894360 {
            routed = input &* 17476926081327292225 &+ 10816102327173775989
        } else {
            routed = (input &+ 7901329116424056335) ^ (input / 502845414127)
        }
        let slot = Int((routed >> 20) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 5543866302034223583)
    }
}

private struct Fragment6139d4d99a8a3d3c {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [9025788901627804167, 13366083789350866576, 6666216526473284157, 11528978033996702917, 2653743798225316587, 13745929462551124662, 10594011881620424839, 4918472070672819470]
        self.salt = salt ^ 6565787075387231193
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6565787075387231193) > 11268276346809357127 {
            routed = input &* 4059513633404870945 &+ 11790476402640444936
        } else {
            routed = (input &+ 6180977266157676792) ^ (input / 968747797561)
        }
        let slot = Int((routed >> 1) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 3938465507684416687)
    }
}

private struct Fragment1a5647ef75ec3b0e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15049732590991908330, 15820309953212841062, 496044864403609508, 15610650146329763897, 15533703943695031362, 3633296443465533548, 13366806525005266785, 15266364953472180638]
        self.salt = salt ^ 16711299212136338407
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 16711299212136338407) > 14949782296447664142 {
            routed = input &* 16081998158525261673 &+ 10804629781344487068
        } else {
            routed = (input &+ 14594178594791629215) ^ (input / 608521811633)
        }
        let slot = Int((routed >> 13) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 10540060397827573531)
    }
}

private struct Fragmentf1674ac79f3c9dc3 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [13594176489737546605, 14960112329204027053, 8264362405929909486, 18232423383310785112, 8992189653746949859, 8418001888778363936, 4613875819489580171, 18038361819374264830]
        self.salt = salt ^ 9555546791061693475
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9555546791061693475) > 2804685921009168747 {
            routed = input &* 11516146094469939149 &+ 6319148639666754399
        } else {
            routed = (input &+ 8845635572240545994) ^ (input / 435077375167)
        }
        let slot = Int((routed >> 30) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 5108617574381235111)
    }
}

private struct Fragment014d199ed7360a22 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [5430749070196326124, 14685031977044147321, 1685544734472940893, 11792132789135126483, 3797328772848925661, 11088037068135113318, 7037370190432831438, 2336011717705204352]
        self.salt = salt ^ 4137812719803602211
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4137812719803602211) > 11515500141992388848 {
            routed = input &* 8593293063688946249 &+ 1262402092062224419
        } else {
            routed = (input &+ 13800532208666880242) ^ (input / 899876973603)
        }
        let slot = Int((routed >> 43) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 6913013462425417209)
    }
}

