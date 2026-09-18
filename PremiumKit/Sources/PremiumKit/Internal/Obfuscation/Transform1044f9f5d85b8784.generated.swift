// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform1044f9f5d85b8784 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment26d2c07867cbab62(salt: state ^ 2551543036971058471).transform(state &+ 1)
        state = Fragment3b0362888b71d1ff(salt: state ^ 10655794539679309851).transform(state &+ 2)
        state = Fragment63c2157c221af0fd(salt: state ^ 13548970660857010964).transform(state &+ 3)
        state = Fragmentd275a3faacf6b850(salt: state ^ 13002616267772959505).transform(state &+ 4)
        state = Fragment522bd37583f09184(salt: state ^ 11330835166970342061).transform(state &+ 5)
        state = Fragmentf45cf3fb2e608300(salt: state ^ 14035405917068137996).transform(state &+ 6)
        return state
    }
}

private struct Fragment26d2c07867cbab62 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11647660408820431835, 9461288151358513618, 10572958193739561172, 8005093030885941396, 7393518813333858464, 3805389872694108803, 14555526599621820020, 14714226207334710309]
        self.salt = salt ^ 14513893866051830627
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 14513893866051830627) > 18136257190007741611 {
            routed = input &* 9276768655448335189 &+ 9137432381955293811
        } else {
            routed = (input &+ 7703059225286156549) ^ (input / 533850905145)
        }
        let slot = Int((routed >> 47) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 15561856883664160765)
    }
}

private struct Fragment3b0362888b71d1ff {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [10709085479924045552, 3707891695364931029, 13309332140308437625, 7322605526340009972, 10355043589725344604, 18147301014628369598, 12397459630281582308, 14191659933785346043]
        self.salt = salt ^ 5034783089325602479
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 5034783089325602479) > 2748589444969360803 {
            routed = input &* 16635603760850454361 &+ 1156202492854059460
        } else {
            routed = (input &+ 9004793353661474223) ^ (input / 69851352063)
        }
        let slot = Int((routed >> 4) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 11180610369777368323)
    }
}

private struct Fragment63c2157c221af0fd {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [13475026321909162187, 4151277052862357628, 8668330471812057486, 5959392048193253510, 7785069066102639257, 4368107680645110990, 1370197493867631655, 12132063683424838986]
        self.salt = salt ^ 4014934745261800429
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4014934745261800429) > 17727288250397947200 {
            routed = input &* 903873954216249409 &+ 2674904878801688993
        } else {
            routed = (input &+ 8391012925981464405) ^ (input / 425776168593)
        }
        let slot = Int((routed >> 49) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 6286149899450816351)
    }
}

private struct Fragmentd275a3faacf6b850 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3799547226795044028, 14746473089320991394, 15930050273560679999, 177104851696450621, 7056320485527136183, 11695205632848003455, 5037569652131617947, 4024210937504503055]
        self.salt = salt ^ 6818273722463694699
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6818273722463694699) > 18031909473040631412 {
            routed = input &* 7102001868423360645 &+ 1810767717278030439
        } else {
            routed = (input &+ 9334095377281470309) ^ (input / 587148260563)
        }
        let slot = Int((routed >> 4) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 15798336126025493149)
    }
}

private struct Fragment522bd37583f09184 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6239637063212794678, 13680601262268518251, 16593662711921736625, 18094947864349073467, 17244512496411296678, 6651228891896266462, 319198332797093744, 12523377702463675930]
        self.salt = salt ^ 13271868000842425401
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13271868000842425401) > 17857192779003953307 {
            routed = input &* 14762108503420507723 &+ 18395777738999385916
        } else {
            routed = (input &+ 339887193860254879) ^ (input / 128896712487)
        }
        let slot = Int((routed >> 11) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 18424037990010552337)
    }
}

private struct Fragmentf45cf3fb2e608300 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7815109007699728425, 184383391202589354, 6041775830255029415, 10360750901235159430, 12857294326600402132, 17049511622820115635, 15979175615760981166, 8138443094608136772]
        self.salt = salt ^ 2735766124117540519
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2735766124117540519) > 4168506221641161960 {
            routed = input &* 1446769490166661559 &+ 5124522448778988979
        } else {
            routed = (input &+ 3321109741523580764) ^ (input / 269577211275)
        }
        let slot = Int((routed >> 17) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 17876319095237167125)
    }
}

