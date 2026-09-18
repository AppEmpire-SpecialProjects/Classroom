// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformfefc4492c084cb0f {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragmentdc06f7a45c0e0439(salt: state ^ 13121754926110250622).transform(state &+ 1)
        state = Fragment2f83a8851a9aa140(salt: state ^ 8977166808501297464).transform(state &+ 2)
        state = Fragmentf4469653cf2d4ec4(salt: state ^ 1462870378954375849).transform(state &+ 3)
        state = Fragmentb0a78600cc9b1f68(salt: state ^ 4046550286347749210).transform(state &+ 4)
        state = Fragmentc068b1bc8e668314(salt: state ^ 3378002517261794573).transform(state &+ 5)
        state = Fragment220f0b9b0fb8e8ac(salt: state ^ 3677020746966371041).transform(state &+ 6)
        return state
    }
}

private struct Fragmentdc06f7a45c0e0439 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1891437249153019752, 14912430570062663905, 5530269931991689294, 2506390016937106103, 13576128293733262834, 7668024597864739582, 8114828609429386584, 18368789476874929999]
        self.salt = salt ^ 10045821308023812995
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 10045821308023812995) > 11689742079500761974 {
            routed = input &* 8063079660896125775 &+ 3359497185835712026
        } else {
            routed = (input &+ 15949746866991645231) ^ (input / 1014272280979)
        }
        let slot = Int((routed >> 41) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 13806871504005169851)
    }
}

private struct Fragment2f83a8851a9aa140 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1505621412649497870, 3560464539685250068, 12146689038318327956, 8230758711555521240, 14545819628456961859, 6803235077066252973, 191350595015916605, 13569412762855207863]
        self.salt = salt ^ 9408198697464149217
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9408198697464149217) > 3185828614800751975 {
            routed = input &* 2545977513289002021 &+ 12641271907505028291
        } else {
            routed = (input &+ 7828522969150392180) ^ (input / 517743789641)
        }
        let slot = Int((routed >> 15) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 2314813262816101903)
    }
}

private struct Fragmentf4469653cf2d4ec4 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [8998384499120823813, 13606603421170920207, 12534530536907433303, 9223372782730976180, 7790946821148564574, 4213471144061356464, 14956531342639667599, 18123947431856291632]
        self.salt = salt ^ 10848569594274041719
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 10848569594274041719) > 15046153325502115558 {
            routed = input &* 3516962228500852039 &+ 350877740613659028
        } else {
            routed = (input &+ 10707256297341486847) ^ (input / 117916292269)
        }
        let slot = Int((routed >> 6) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 9439178305423431985)
    }
}

private struct Fragmentb0a78600cc9b1f68 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14203291593090605733, 9913703977469920300, 13992375012973039359, 12815797135724543457, 6596255998598658638, 9305216304266320189, 4859893062625636211, 9784148600425357958]
        self.salt = salt ^ 13022048755077590661
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13022048755077590661) > 17678579679494329296 {
            routed = input &* 2016425956090588717 &+ 1568147938474222011
        } else {
            routed = (input &+ 1166629409975940662) ^ (input / 315986327799)
        }
        let slot = Int((routed >> 48) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 707413163778263439)
    }
}

private struct Fragmentc068b1bc8e668314 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [18269320744313960690, 13516062559655697194, 12554368333573876829, 15453354342929976088, 16504195373869658404, 6326117283464564276, 18211600034701550101, 18419775300717644039]
        self.salt = salt ^ 22269912915531365
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 22269912915531365) > 4040503131682226149 {
            routed = input &* 560748957435729119 &+ 15225603644473033889
        } else {
            routed = (input &+ 11116583600763459341) ^ (input / 917370058841)
        }
        let slot = Int((routed >> 43) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 17537642681974531827)
    }
}

private struct Fragment220f0b9b0fb8e8ac {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12389245533349084083, 11684728053713690285, 8286361183755504305, 11739224893134421938, 10253502980143805487, 3328124153038243863, 18427899450943649287, 17321340923756701672]
        self.salt = salt ^ 12864636385285537141
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 12864636385285537141) > 17693137036347882210 {
            routed = input &* 2983414446850012583 &+ 18186655963719313545
        } else {
            routed = (input &+ 4995660252169348365) ^ (input / 976794199387)
        }
        let slot = Int((routed >> 12) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 7192035259444301561)
    }
}

