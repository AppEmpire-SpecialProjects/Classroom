// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform27684822f7426ff7 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment503d3e98a50a5956(salt: state ^ 4355590966017309798).transform(state &+ 1)
        state = Fragment207ac0064f11fdef(salt: state ^ 13508012349044001781).transform(state &+ 2)
        state = Fragment77c196b4d793c953(salt: state ^ 9846768878794796205).transform(state &+ 3)
        state = Fragment68928e94f52e347a(salt: state ^ 15767986869819653498).transform(state &+ 4)
        state = Fragmentc4cd3a0452511b11(salt: state ^ 10317384632268256873).transform(state &+ 5)
        state = Fragment0c6bd8748f6d0f66(salt: state ^ 6812021783825959323).transform(state &+ 6)
        return state
    }
}

private struct Fragment503d3e98a50a5956 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7497294825852553094, 7458349598192106351, 11770959400107871108, 16500775638426797942, 3289844743209875351, 12756818590035063168, 17818108041640497644, 16427316263802722511]
        self.salt = salt ^ 8097713208105229095
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8097713208105229095) > 11237281710072446990 {
            routed = input &* 11092333896762915701 &+ 10600216977118345591
        } else {
            routed = (input &+ 7492195708143638230) ^ (input / 548504527833)
        }
        let slot = Int((routed >> 46) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 15165157271166265603)
    }
}

private struct Fragment207ac0064f11fdef {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [13176586890684135003, 13263417093931526760, 14771367341518439082, 7812780093363585033, 5879090857635375362, 925517091083637903, 11606533019547992030, 9787352756676649236]
        self.salt = salt ^ 15440608086242785263
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15440608086242785263) > 2943742807948432319 {
            routed = input &* 9068994007246917803 &+ 8565521052098741856
        } else {
            routed = (input &+ 18274131377349955724) ^ (input / 377687311825)
        }
        let slot = Int((routed >> 19) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 11460873544430113271)
    }
}

private struct Fragment77c196b4d793c953 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3147523945723337647, 9999987334988211408, 9276360375542343026, 6251802923751025858, 17623473206279037187, 17345454133979326486, 9433542310562884120, 2648889146452830923]
        self.salt = salt ^ 8590362347039695089
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8590362347039695089) > 13981126481481716730 {
            routed = input &* 2421450874887533509 &+ 5213485437773719649
        } else {
            routed = (input &+ 3841249907135952592) ^ (input / 574218305165)
        }
        let slot = Int((routed >> 6) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 3158967481753513421)
    }
}

private struct Fragment68928e94f52e347a {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [17599617056465798931, 13913060485383290569, 8636098776377673331, 16544255785733587660, 17434435386659971514, 14384372781313082373, 11098760666920828864, 10457257652784838677]
        self.salt = salt ^ 9925008895664237433
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9925008895664237433) > 9165647247991991818 {
            routed = input &* 8558389416869788427 &+ 4659299153546469766
        } else {
            routed = (input &+ 15760798252759849645) ^ (input / 1002665221069)
        }
        let slot = Int((routed >> 14) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 9060127942369450097)
    }
}

private struct Fragmentc4cd3a0452511b11 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7647218890978554257, 9947739693158855395, 534347837308041658, 17227445728339803573, 3572782080914602075, 10974097600720688925, 17093030987339771809, 10243020383556253693]
        self.salt = salt ^ 13799743152063452599
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13799743152063452599) > 1143074604371287127 {
            routed = input &* 7232962061503829137 &+ 8934317850686840184
        } else {
            routed = (input &+ 10986357620641541481) ^ (input / 887120142301)
        }
        let slot = Int((routed >> 13) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 2297441252107927885)
    }
}

private struct Fragment0c6bd8748f6d0f66 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6102494266709531862, 8094245880311469877, 15835440527136938057, 2979754608710767648, 4359381758906793081, 2207413767071674893, 9700900495345393074, 6375918984426687971]
        self.salt = salt ^ 15718296879333227789
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15718296879333227789) > 7326211244365268319 {
            routed = input &* 11322352593463048901 &+ 1968914036288460882
        } else {
            routed = (input &+ 12692837526856932128) ^ (input / 901180255567)
        }
        let slot = Int((routed >> 45) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 318833696640959649)
    }
}

