// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform5499989efe0be641 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment3a07a9822ff2f3b8(salt: state ^ 8667144002348358853).transform(state &+ 1)
        state = Fragment670c9992eb1aceb8(salt: state ^ 16487446012613682196).transform(state &+ 2)
        state = Fragmentadf22d4f2d7c777e(salt: state ^ 13715913853630222318).transform(state &+ 3)
        state = Fragment5751a2b5ce9018b5(salt: state ^ 4051057440068288389).transform(state &+ 4)
        state = Fragment56312f962736af12(salt: state ^ 6323428007617750365).transform(state &+ 5)
        state = Fragmentee40da018f3e4822(salt: state ^ 5450167404055372530).transform(state &+ 6)
        return state
    }
}

private struct Fragment3a07a9822ff2f3b8 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [9733795737900865729, 6568931855472260395, 731779666821990978, 4752519223754187154, 15722461059420527979, 8603277726716965351, 597644723680085794, 15718224826250339484]
        self.salt = salt ^ 10083862172870530831
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 10083862172870530831) > 1816289691185900848 {
            routed = input &* 9324036511332557107 &+ 12115168518922429358
        } else {
            routed = (input &+ 9276790318764720242) ^ (input / 359248385611)
        }
        let slot = Int((routed >> 26) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 12712813842252006919)
    }
}

private struct Fragment670c9992eb1aceb8 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11925500246658570497, 2689037137217234968, 16715858926670118637, 6041109705755731160, 14268667362658179872, 3854664753055744392, 15179795454005896813, 2812136564310555460]
        self.salt = salt ^ 590892894281906375
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 590892894281906375) > 12968084249780344304 {
            routed = input &* 16376877738251837479 &+ 18391281234377802489
        } else {
            routed = (input &+ 4115428463750658943) ^ (input / 819677689261)
        }
        let slot = Int((routed >> 41) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 1208219859357567205)
    }
}

private struct Fragmentadf22d4f2d7c777e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [13809695410059254412, 15427025264246686907, 14588100167332651278, 16162504142237737638, 16950203801778657392, 2052122655899869299, 17096194983866934847, 13841160695932784464]
        self.salt = salt ^ 6946271936213895457
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6946271936213895457) > 5008773782969285030 {
            routed = input &* 8214508601527117781 &+ 17999775684611517725
        } else {
            routed = (input &+ 7453415039067116793) ^ (input / 45369578013)
        }
        let slot = Int((routed >> 41) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 647593430032182477)
    }
}

private struct Fragment5751a2b5ce9018b5 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [771588752192058261, 5880922670246988808, 2485034569647194064, 16367997160672461973, 7139672672805954734, 5068176737244913598, 8369203530625576251, 5371659171372653746]
        self.salt = salt ^ 15953948042864554017
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15953948042864554017) > 13525222075713212304 {
            routed = input &* 15333163292608306539 &+ 10812056649109397377
        } else {
            routed = (input &+ 2763800626145723869) ^ (input / 354491566169)
        }
        let slot = Int((routed >> 25) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 9443504786949770925)
    }
}

private struct Fragment56312f962736af12 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [18280850371318830001, 10783415879603358899, 14144332962485950393, 13835215405729498713, 14149005789362286600, 17854367002044078733, 9997770461906829315, 2012112298115427389]
        self.salt = salt ^ 9735235556858583681
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9735235556858583681) > 16538142062753496706 {
            routed = input &* 3052083267840461883 &+ 14253252775778727624
        } else {
            routed = (input &+ 15743465269603579894) ^ (input / 852333689283)
        }
        let slot = Int((routed >> 42) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 2879731341396811835)
    }
}

private struct Fragmentee40da018f3e4822 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12120413048850969841, 12461958701319355611, 10318305493505829674, 3618077625484428141, 7969863655241356425, 3635790082547275586, 15997002686322499191, 9312904813936836230]
        self.salt = salt ^ 13422098390881697635
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13422098390881697635) > 11849932582888037373 {
            routed = input &* 6434962258416401721 &+ 1060896041371692451
        } else {
            routed = (input &+ 15206923728859148751) ^ (input / 1824761983)
        }
        let slot = Int((routed >> 47) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 7003316122185304915)
    }
}

