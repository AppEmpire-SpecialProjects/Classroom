@preconcurrency import ApphudSDK
import StoreKit
import AdServices
import Combine

fileprivate enum Constants {
    static let trialUserDefaultsKey = "TRIAL"
}

@MainActor
internal final class PaymentManager: ObservableObject {
    
    static let shared = PaymentManager()
    
    @Published private(set) var loadedPaywalls: [PremiumPaywallID: PaywallModel] = [:]
    @Published private(set) var isPremium = false
    @Published private(set) var activeProductIds: Set<String> = []
    @Published private(set) var availableProducts: AvailableProducts = .withTrial
    @Published private(set) var isShowingSplash = true
    private var isPremiumChecked = false
    
    var isTrialExpired: Bool {
        isPremiumChecked && UserDefaults.standard.object(forKey: Constants.trialUserDefaultsKey) != nil && !isPremium
    }
    
    private let networkMonitor: NetworMonitoring = NetworMonitoringImpl()
    private let fallbackHelper = FallbackHelper()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var loadState: ProductLoadState = .none
    
    private var forceFallback = false
    private var fallbackFileName = "apphud_paywalls_fallback"
    
    private var paywallsApphud: [PremiumPaywallID: ApphudPaywall] = [:]
    
    private init() {
        let noise7e6a282a7b81111a = PremiumKitNoise99f9e2691a2ca0b4(seed: 313313271140654356)
        _ = noise7e6a282a7b81111a.digest()
        bind()
    }
    
    //MARK: - public methods
    
    func grantPremium() {
        isPremium = true
    }

    func grantPremium(for id: PremiumPaywallID) {
        let ids = loadedPaywalls[id]?.products.map { $0.id } ?? []
        activeProductIds.formUnion(ids)
    }
    
    ///Вызывается при старте приложения didFinishLaunchingWithOptions
    func start(
        apiKey: String,
        userID: String? = nil,
        forceFallback: Bool = false,
        fallbackFileName: String = "apphud_paywalls_fallback"
    ) {
        self.forceFallback = forceFallback
        self.fallbackFileName = fallbackFileName
        Apphud.start(apiKey: apiKey, userID: userID) { [weak self] _ in
            _Concurrency.Task {
                self?.checkPremiumSubscription()
                self?.trackASA()
                Apphud.setPaywallsCacheTimeout(60 * 60)
            }
        }
    }
    
    ///Загружает токек пушей в апхуд
    func submitPushToken(_ token: Data) {
        Apphud.submitPushNotificationsToken(token: token, callback: nil)
    }
    
    func logout() {
        Task { await Apphud.logout() }
        isPremium = false
        activeProductIds = []
    }
    
    private func setPaywall(_ model: PaywallModel, for id: PremiumPaywallID) {
        loadedPaywalls[id] = model
    }
    
    private func paywall(for id: PremiumPaywallID) -> PaywallModel? {
        loadedPaywalls[id]
    }
    
    ///Вызывается для загрузки пейвола только при старте флоу
    func fetchPaywall(_ id: PremiumPaywallID) async {

        setPaywall(.init(id: id), for: id)
        loadState = .loading

        do {
            try await withTimeout(seconds: 5) {
                try await self.loadRealPaywall(id)
            }

            await MainActor.run {
                self.isShowingSplash = false
                self.logPaywallLoaded(id: id, source: "Apphud")
            }
        } catch {
            let fallbackModel = await fallbackHelper.fallbackToPaywallModel(
                for: id,
                fileName: fallbackFileName
            )
            await tryLoadApphudPaywall(id)
            await MainActor.run {
                self.setPaywall(fallbackModel, for: id)
                if id.isAvailablePaywall { self.setAvailableProducts() }
                self.loadState = .failed
                self.isShowingSplash = false
                self.logPaywallLoaded(id: id, source: "Fallback")
            }
        }
    }
    
    private func tryLoadApphudPaywall(_ id: PremiumPaywallID) async {
        if let placement = await Apphud.placement(id.rawValue),
           let paywall = placement.paywall {
            self.paywallsApphud[id] = paywall
        }
    }
    
    ///Ивент аналитики показа пейвола
    func paywallShownEvent(_ id: PremiumPaywallID = .main) {
        guard let apphudPaywall = paywallsApphud[id] else {
            print("⚠️ [PremiumKit] Paywall shown skipped — no Apphud paywall for: \(id.rawValue)")
            return
        }
        
        print("👁️ [PremiumKit] Paywall shown — \(id.rawValue)")
        Apphud.paywallShown(apphudPaywall)
    }
    
    ///Востановление покупок
    func restorePurchase() async -> Result<Void, PaymentError> {
        
#if targetEnvironment(simulator)
        return .failure(.restoreNothingToRestore)
#else
        let result = await Apphud.restorePurchases()
        if let error = result?.error {
            return .failure(PaymentError.from(error))
        }
        
        let has = Apphud.hasPremiumAccess() || (Apphud.nonRenewingPurchases()?.isEmpty == false)
        
        if has {
            self.isPremium = true
            
            let subscriptionIds = Apphud.subscriptions()?.filter { $0.isActive() }.map { $0.productId } ?? []
            let nonRenewingIds = Apphud.nonRenewingPurchases()?.filter { $0.isActive() }.map { $0.productId } ?? []
            
            self.activeProductIds = Set(subscriptionIds + nonRenewingIds)
            return .success(())
        } else {
            return .failure(.restoreNothingToRestore)
        }
#endif
    }
    
    func purchase(_ product: ProductModel, from id: PremiumPaywallID) async -> Result<String, PaymentError> {
        guard
            let apphudPaywall = paywallsApphud[id],
            let ahProduct = apphudPaywall.products.first(where: { $0.productId == product.id })
        else {
#if DEBUG
            print("⚠️ [PremiumKit] No Apphud paywall for \(id.rawValue) — debug purchase unavailable")
            return .failure(.productNotAvailable)
#else
            print("⚠️ [PremiumKit] No Apphud paywall for \(id.rawValue) — purchasing by product id: \(product.id)")
            return await purchaseByID(product, paywallID: id)
#endif
        }
        
        print("🛒 [PremiumKit] Purchase started — \(product.id) from paywall: \(id.rawValue)")
        
#if DEBUG
        return await purchaseViaSK2(product, ahProduct: ahProduct, paywallID: id)
#else
        
        let result = await Apphud.purchase(ahProduct)
        
        if result.success {
            let isTrial = product.isTrial || result.subscription?.status == .trial
            
            applyPurchaseSuccess(product: product, paywallID: id, isTrial: isTrial)
            
            return .success(product.id)
        }
        
        if let error = result.error {
            return .failure(PaymentError.from(error))
        }
        
        return .failure(paymentError(from: result))
#endif
    }
    
    /// Ошибка покупки, когда Apphud не вернул error: отложенная транзакция (Ask to Buy) — это .pending
    private func paymentError(from result: ApphudPurchaseResult) -> PaymentError {
        if result.transaction?.transactionState == .deferred {
            return .pending
        }
        
        return .unknown
    }
    
    /// Общая обработка успешной покупки для всех способов оплаты
    private func applyPurchaseSuccess(product: ProductModel, paywallID: PremiumPaywallID, isTrial: Bool) {
        isPremium = true
        activeProductIds.insert(product.id)
        
        if isTrial {
            saveTrialStartDate()
        }
        
        addConsumableTokens(from: product, paywallID: paywallID)
    }
    
    /// Фоллбэк-покупка по product id из фолбэк-модели, когда пейвол Apphud не загрузился
    private func purchaseByID(_ product: ProductModel, paywallID: PremiumPaywallID) async -> Result<String, PaymentError> {
        let result: ApphudPurchaseResult = await withCheckedContinuation { continuation in
            Apphud.purchase(product.id) { result in
                continuation.resume(returning: result)
            }
        }
        
        if result.success {
            ///В фолбэке ProductModel.isTrial недостоверен — берём статус из ответа Apphud
            let isTrial = product.isTrial || result.subscription?.status == .trial
            
            applyPurchaseSuccess(product: product, paywallID: paywallID, isTrial: isTrial)
            
            print("🛒 [PremiumKit] Purchased by product id — \(product.id)")
            return .success(product.id)
        }
        
        if let error = result.error {
            return .failure(PaymentError.from(error))
        }
        
        return .failure(paymentError(from: result))
    }
    
    private func purchaseViaSK2(_ product: ProductModel, ahProduct: ApphudProduct, paywallID: PremiumPaywallID) async -> Result<String, PaymentError> {
        guard let sk2Product = try? await ahProduct.product() else {
            return .failure(.productNotAvailable)
        }
        
        do {
            let result = try await sk2Product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    applyPurchaseSuccess(product: product, paywallID: paywallID, isTrial: product.isTrial)
                    print("🛒 [PremiumKit] Debug: purchased via SK2 — \(product.id)")
                    return .success(product.id)
                case .unverified:
                    return .failure(.verificationFailed)
                }
            case .userCancelled:
                return .failure(.cancelled)
            case .pending:
                return .failure(.pending)
            @unknown default:
                return .failure(.unknown)
            }
        } catch {
            return .failure(PaymentError.from(error))
        }
    }

    
    //MARK: - private methods
    private func loadRealPaywall(_ id: PremiumPaywallID) async throws {

        guard let placement = await Apphud.placement(id.rawValue),
              let paywall = placement.paywall
        else {
            throw PaymentError.productNotAvailable
        }

        self.paywallsApphud[id] = paywall

        if forceFallback || paywall.shouldShowFallback {
            print("🧪 [PremiumKit] \(forceFallback ? "forceFallback" : "showFallback")=true — using fallback model for: \(id.rawValue)")
            let fallbackModel = await fallbackHelper.fallbackToPaywallModel(
                for: id,
                fileName: fallbackFileName
            )
            self.setPaywall(fallbackModel, for: id)
            if id == .main || id == .onboarding { self.setAvailableProducts() }
            self.loadState = .loaded
            return
        }

        for ahProduct in paywall.products {
            guard let _ = try? await ahProduct.product() else {
                throw PaymentError.productNotAvailable
            }
        }

        if let response = paywall.paywallResponse,
           let responseProducts = response.products, !responseProducts.isEmpty {
            var productModels: [ProductModel] = []

            for responseProduct in responseProducts {
                guard let ahProduct = paywall.products.first(
                    where: { $0.productId == responseProduct.id }
                ) else { continue }

                let isTrial = await ahProduct.isTrail()
                let isLifetime = await ahProduct.nonConsumable
                let pricePerPeriod = await ahProduct.getPricePerPeriod()
                var pricePerWeek = await ahProduct.getPricePerWeek()
                let trialDuration = await ahProduct.getTrialDuration()
                let subscriptionDuration = await ahProduct.getSubscriptionDuration()

                if isLifetime {
                    let configPeriodly = L10n.resolve(responseProduct.periodly)
                    if !configPeriodly.isEmpty { pricePerWeek = configPeriodly }
                }

                let productModel = ProductModel(
                    id: responseProduct.id,
                    title: L10n.resolve(responseProduct.title),
                    subtitle: L10n.resolveOptional(responseProduct.subtitle),
                    nonTrialSubtitle: L10n.resolveOptional(responseProduct.nonTrialSubtitle),
                    message: L10n.resolveOptional(responseProduct.message),
                    periodly: L10n.resolve(responseProduct.periodly),
                    pricePerPeriod: pricePerPeriod,
                    pricePerWeek: pricePerWeek,
                    isTrial: isTrial,
                    isLifetime: isLifetime,
                    consumable: responseProduct.consumable,
                    consumableUnit: responseProduct.consumableUnit,
                    trialDuration: trialDuration,
                    subscriptionDuration: subscriptionDuration
                )
                productModels.append(productModel)
            }

            self.setPaywall(PaywallModel(
                id: id,
                response: response,
                products: productModels
            ), for: id)
        } else {
            print("⚠️ [PremiumKit] JSON mismatch — using mock model for: \(id.rawValue)")
            var mock = PaywallModel(id: id)
            var productModels: [ProductModel] = []

            for (index, ahProduct) in paywall.products.enumerated() {
                let isTrial = await ahProduct.isTrail()
                let isLifetime = await ahProduct.nonConsumable
                let pricePerPeriod = await ahProduct.getPricePerPeriod()
                var pricePerWeek = await ahProduct.getPricePerWeek()
                let trialDuration = await ahProduct.getTrialDuration()
                let subscriptionDuration = await ahProduct.getSubscriptionDuration()

                let mockProduct = index < mock.products.count ? mock.products[index] : nil

                if isLifetime, let configPeriodly = mockProduct?.periodly, !configPeriodly.isEmpty {
                    pricePerWeek = L10n.resolve(configPeriodly)
                }

                productModels.append(ProductModel(
                    id: ahProduct.productId,
                    title: mockProduct?.title ?? ahProduct.productId,
                    subtitle: mockProduct?.subtitle,
                    nonTrialSubtitle: mockProduct?.nonTrialSubtitle,
                    message: mockProduct?.message,
                    periodly: mockProduct?.periodly ?? "",
                    pricePerPeriod: pricePerPeriod,
                    pricePerWeek: pricePerWeek,
                    isTrial: isTrial,
                    isLifetime: isLifetime,
                    consumable: mockProduct?.consumable,
                    consumableUnit: mockProduct?.consumableUnit,
                    trialDuration: trialDuration,
                    subscriptionDuration: subscriptionDuration
                ))
            }

            mock.products = productModels
            self.setPaywall(mock, for: id)
        }

        if id == .main || id == .onboarding { self.setAvailableProducts() }
        self.loadState = .loaded
    }

    
    private func setAvailableProducts() {
        let products = (loadedPaywalls[.main] ?? loadedPaywalls[.onboarding])?.products ?? []

        if products.count > 1 {
            availableProducts = .bothProducts
            return
        }

        if products.first?.isTrial == true {
            availableProducts = .withTrial
        } else {
            availableProducts = .noTrial
        }
    }

    
    nonisolated
    private func withTimeout(
        seconds: Double,
        task: @escaping @Sendable () async throws -> Void
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await task()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw PaymentError.productNotAvailable
            }

            try await group.next()
            group.cancelAll()
        }
    }
    
    private func bind() {
        networkMonitor.isConnectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self, isConnected else { return }

                Task { @MainActor in
                    guard self.loadState == .failed else { return }
                    let failedID = self.loadedPaywalls.first(where: { $0.key.isAvailablePaywall })?.key ?? .main
                    await self.fetchPaywall(failedID)
                }
            }
            .store(in: &cancellables)
    }


    
    private func trackASA() {
        _Concurrency.Task {
            if let asaToken = try? AAAttribution.attributionToken() {
                Apphud.setAttribution(data: nil,
                                      from: .appleAdsAttribution,
                                      identifer: asaToken,
                                      callback: nil)
            }
        }
    }
    
    private func checkPremiumSubscription() {
        isPremium = Apphud.hasPremiumAccess() || (Apphud.nonRenewingPurchases()?.isEmpty == false)
        activeProductIds = Set(
            Apphud.subscriptions()?.filter { $0.isActive() }.map { $0.productId } ?? []
        )
        isPremiumChecked = true
        checkAndUpdateSubscriptionTokens()
        
        #if DEBUG
        Task {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    await MainActor.run {
                        self.activeProductIds.insert(transaction.productID)
                    }
                }
            }
        }
        #endif
    }
    
    private func checkAndUpdateSubscriptionTokens() {
        guard let subscription = Apphud.subscriptions()?.first(where: { $0.isActive() }) else {
            TokenStorage.shared.resetSubscriptionTokens()
            TokenStorage.shared.lastKnownExpiresAt = nil
            TokenStorage.shared.lastSubscriptionProductId = nil
            return
        }
        
        let currentExpiresAt = subscription.expiresDate
        let lastExpiresAt = TokenStorage.shared.lastKnownExpiresAt
        let lastProductId = TokenStorage.shared.lastSubscriptionProductId
        
        let isNewPeriod = lastExpiresAt == nil || currentExpiresAt > lastExpiresAt!
        let isProductChanged = lastProductId != subscription.productId
        
        if isNewPeriod || isProductChanged {
            let storedAmount = TokenStorage.shared.lastSubscriptionTokenAmount
            if storedAmount > 0 {
                TokenStorage.shared.setSubscriptionTokens(storedAmount)
            }
            
            TokenStorage.shared.lastKnownExpiresAt = currentExpiresAt
            TokenStorage.shared.lastSubscriptionProductId = subscription.productId
        }
    }
    
    private func logPaywallLoaded(id: PremiumPaywallID, source: String) {
        let config = paywall(for: id)?.configuration
        print("📦 [PremiumKit] Paywall \(id.rawValue) loaded — source: \(source), configuration: \(config?.rawValue ?? "none")")
    }
    
    private func saveTrialStartDate() {
        UserDefaults.standard.set(Date(), forKey: Constants.trialUserDefaultsKey)
    }
    
    private func addConsumableTokens(from product: ProductModel, paywallID: PremiumPaywallID) {
        guard let tokens = product.consumable, tokens > 0 else { return }
        
        if paywallID == .consumable {
            TokenStorage.shared.addPurchased(tokens)
        } else {
            TokenStorage.shared.setSubscriptionTokens(tokens)
            TokenStorage.shared.lastSubscriptionTokenAmount = tokens
            if let subscription = Apphud.subscriptions()?.first(where: { $0.isActive() }) {
                TokenStorage.shared.lastKnownExpiresAt = subscription.expiresDate
                TokenStorage.shared.lastSubscriptionProductId = product.id
            }
        }
    }
}
