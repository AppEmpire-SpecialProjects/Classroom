// Generated source diversification entry point. Regenerate from a clean clone.
internal struct PremiumKitNoise99f9e2691a2ca0b4 {
    private let seed: UInt64

    init(seed: UInt64) {
        self.seed = seed
    }

    @inline(never)
    func digest() -> UInt64 {
        var state = seed
        state = Transform696fb79f781a647d.mix(state ^ 16441585018556766840)
        state = Transform1044f9f5d85b8784.mix(state ^ 9454186621278670476)
        state = Transform8d00af8dae2f0c8c.mix(state ^ 9830349293452386629)
        state = Transformfefc4492c084cb0f.mix(state ^ 16417841644825412234)
        state = Transform5499989efe0be641.mix(state ^ 735990169417990758)
        state = Transformfc9508162b7d0faa.mix(state ^ 4536046072187775579)
        state = Transformac2800cf5fabf689.mix(state ^ 2743553025521388887)
        state = Transform1b4a5a25c646613b.mix(state ^ 15064411074514865955)
        state = Transform27684822f7426ff7.mix(state ^ 4655057276751604413)
        state = Transformb18cb7c629976eae.mix(state ^ 4863351467810896771)
        state = Transform8fad8a04e88c7ad4.mix(state ^ 14383075393596821981)
        state = Transformb3b1289adfd507eb.mix(state ^ 5862137392697010583)
        return state
    }
}
