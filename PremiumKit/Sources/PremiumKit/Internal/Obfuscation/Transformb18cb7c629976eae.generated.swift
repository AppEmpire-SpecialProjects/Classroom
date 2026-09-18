// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformb18cb7c629976eae {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment445b52bae5d1864d(salt: state ^ 326397417185445369).transform(state &+ 1)
        state = Fragment71acd1fbaebb9cc7(salt: state ^ 9556779806939947256).transform(state &+ 2)
        state = Fragment9b3d778e38debe3f(salt: state ^ 426948502766931282).transform(state &+ 3)
        state = Fragment62e958acd2ced07f(salt: state ^ 9913784297401325436).transform(state &+ 4)
        state = Fragment43f43945c2acd5ae(salt: state ^ 15801439271822193725).transform(state &+ 5)
        state = Fragment6d2c4c7dce4d0b30(salt: state ^ 13054511710568393952).transform(state &+ 6)
        return state
    }
}

private struct Fragment445b52bae5d1864d {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14799337398914095565, 15761287989904207, 6677118525883838154, 5386049547609672544, 770257700892716210, 10794745778991876897, 6407478709347211531, 1724831674209722330]
        self.salt = salt ^ 6457706731325120173
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6457706731325120173) > 2621123102016463825 {
            routed = input &* 12980955964523504903 &+ 8559866914530463593
        } else {
            routed = (input &+ 11243842857292184634) ^ (input / 144494315809)
        }
        let slot = Int((routed >> 9) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 2112631905203953159)
    }
}

private struct Fragment71acd1fbaebb9cc7 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6631938019277829173, 2277991003846789131, 2944182321497079899, 1034368415103115527, 6333645964590304207, 8296629402101706325, 9807963369832154157, 6097161551585388599]
        self.salt = salt ^ 845819207912288821
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 845819207912288821) > 18271367720417631487 {
            routed = input &* 6560171626153712175 &+ 11683404975058087877
        } else {
            routed = (input &+ 9638546357515953459) ^ (input / 60143345673)
        }
        let slot = Int((routed >> 5) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 12569889678475830657)
    }
}

private struct Fragment9b3d778e38debe3f {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [2011863201604038695, 15366488371663503855, 14920470182633507143, 18025785469912591998, 3686260810834829858, 14405128668339389809, 8011011114531769386, 8350760622973966450]
        self.salt = salt ^ 13909801192818246923
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13909801192818246923) > 6776831697972474385 {
            routed = input &* 11897266714440720683 &+ 17570892289956489924
        } else {
            routed = (input &+ 3171689940018568501) ^ (input / 117191557049)
        }
        let slot = Int((routed >> 8) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 16987927314673748087)
    }
}

private struct Fragment62e958acd2ced07f {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3869776366387977797, 14301923686129684103, 16473387885934173467, 12544571946956413076, 6186002627453388045, 7752083181433033866, 11933342152376756667, 7192515696328587269]
        self.salt = salt ^ 13723759407855665437
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13723759407855665437) > 1812641398455262609 {
            routed = input &* 3623285056114375403 &+ 9798554028213072936
        } else {
            routed = (input &+ 1576396911293478254) ^ (input / 902582620173)
        }
        let slot = Int((routed >> 41) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 169265848860793131)
    }
}

private struct Fragment43f43945c2acd5ae {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7200958201454205255, 13347725302153686731, 6726663669315042938, 12017756963056594778, 2141219862676619858, 16006394884398987714, 16074313617249237528, 17042952036086152819]
        self.salt = salt ^ 9189144633645288589
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9189144633645288589) > 6708295089344961854 {
            routed = input &* 8189929940396653895 &+ 9640425388888471916
        } else {
            routed = (input &+ 7225243833875715427) ^ (input / 85253076731)
        }
        let slot = Int((routed >> 49) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 2507938731713758871)
    }
}

private struct Fragment6d2c4c7dce4d0b30 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7964126257721517297, 16093391651183237618, 18186020020251271033, 15641061604141365096, 1619546171466346361, 11881544850501185575, 11896853746487643363, 5396081922663645935]
        self.salt = salt ^ 8589989999765218927
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8589989999765218927) > 3394391569721393313 {
            routed = input &* 1221739917672628895 &+ 15936275641488912741
        } else {
            routed = (input &+ 11725958318783141341) ^ (input / 1089252545817)
        }
        let slot = Int((routed >> 3) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 15728308854193623759)
    }
}

