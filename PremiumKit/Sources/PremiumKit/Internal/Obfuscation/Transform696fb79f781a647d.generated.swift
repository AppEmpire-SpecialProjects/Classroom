// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform696fb79f781a647d {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment059100b986d8fdf5(salt: state ^ 14663686290515414923).transform(state &+ 1)
        state = Fragment6548a7ffd0f5b5d7(salt: state ^ 7453001838299506880).transform(state &+ 2)
        state = Fragment68752e62083ab42d(salt: state ^ 304110946991831049).transform(state &+ 3)
        state = Fragment096b563fbf30b78c(salt: state ^ 16952432792330550720).transform(state &+ 4)
        state = Fragmente8dfedcfc65f1c35(salt: state ^ 474160857306240158).transform(state &+ 5)
        state = Fragment0aac48a0ce1f393e(salt: state ^ 5206550098220026501).transform(state &+ 6)
        return state
    }
}

private struct Fragment059100b986d8fdf5 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [4721926267592060896, 17649855997718498086, 10551286239858367405, 14919196252568004015, 18411463055172253620, 7852585773396791988, 1876293212041891983, 7920457857482640828]
        self.salt = salt ^ 8081389863739654343
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8081389863739654343) > 12422271663781279648 {
            routed = input &* 13567401346329102429 &+ 113972034648942233
        } else {
            routed = (input &+ 7767363149361848676) ^ (input / 285634689197)
        }
        let slot = Int((routed >> 45) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 2313158566471053537)
    }
}

private struct Fragment6548a7ffd0f5b5d7 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6523776998448774571, 11071443444573856614, 438504548818659395, 8281087044369776092, 10232463007563060225, 11407005355444737205, 13790613126799850573, 2241823782308715374]
        self.salt = salt ^ 3479979385365701299
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 3479979385365701299) > 14229212127170400015 {
            routed = input &* 1063173383798368175 &+ 6855417158940140072
        } else {
            routed = (input &+ 16029965541900175967) ^ (input / 53128022789)
        }
        let slot = Int((routed >> 34) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 10372518805777887327)
    }
}

private struct Fragment68752e62083ab42d {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12839060301651749090, 13095300403941733692, 7672628712094133704, 15435666671085611108, 735570689970293721, 5779949565521557778, 3922006195296234706, 6752685433226077618]
        self.salt = salt ^ 831970529196752265
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 831970529196752265) > 16305082697236331849 {
            routed = input &* 10660800767760445379 &+ 3599052940829137269
        } else {
            routed = (input &+ 2605395458810127388) ^ (input / 768883478233)
        }
        let slot = Int((routed >> 6) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 3487366430466120091)
    }
}

private struct Fragment096b563fbf30b78c {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11449311349087824650, 16325078576089771394, 14085494253614052935, 7202437588947473383, 10667635875851970671, 554263328215329121, 3423665214877316181, 10619901145776039330]
        self.salt = salt ^ 17347813346829714659
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 17347813346829714659) > 17215440549445706958 {
            routed = input &* 2152968416081711533 &+ 18244978700805282209
        } else {
            routed = (input &+ 14229323448458463590) ^ (input / 908582451983)
        }
        let slot = Int((routed >> 14) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 17015232520410935525)
    }
}

private struct Fragmente8dfedcfc65f1c35 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14127631210819132857, 6989229504042609698, 3633858747347735627, 9992044757477971335, 15565629338073214414, 10241708719038977283, 11656954889614975496, 2037940913986687201]
        self.salt = salt ^ 4822324772080004549
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4822324772080004549) > 3455497571531249780 {
            routed = input &* 12194057765695482075 &+ 11052958923617807647
        } else {
            routed = (input &+ 3953361955146016002) ^ (input / 724321351721)
        }
        let slot = Int((routed >> 10) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 9914118897920744531)
    }
}

private struct Fragment0aac48a0ce1f393e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [17040956405949286692, 17206537350381243408, 12594614511116168121, 3152082114381533971, 14954805573300262519, 3872573712254870347, 9996247152461103882, 1616766164273817614]
        self.salt = salt ^ 2566672649541840631
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2566672649541840631) > 9744316783421403056 {
            routed = input &* 13424533849121049447 &+ 9938408666098025472
        } else {
            routed = (input &+ 13257842569186697428) ^ (input / 779835790283)
        }
        let slot = Int((routed >> 18) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 11919524009443887741)
    }
}

