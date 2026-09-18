import Foundation
@preconcurrency import ApphudSDK

@MainActor
class FallbackHelper {
    func fallbackToPaywallModel(for id: PremiumPaywallID, fileName: String) async -> PaywallModel {
        
        guard let paywallFallback = loadFallbackPaywall(id, fileName: fileName) else { return .init(id: id) }
        
        var products: [ProductModel] = []
        
        for fallbackProduct in paywallFallback.products {
            
            let apphudProduct = await resolveApphudProduct(by: fallbackProduct.id, for: id)

            let storekitProduct = skFind(productId: fallbackProduct.id)
            let storekitPrice = storekitProduct?.displayPrice
            let subscriptionPeriod = storekitProduct?.recurringSubscriptionPeriod

            let isLifetime = (subscriptionPeriod == nil)

            let configPeriodly = L10n.resolve(fallbackProduct.periodly)
            ///Период ищем и в сыром ключе, и в локализованном значении — periodly может быть ключом локализации
            let periodSource = "\(fallbackProduct.periodly) \(configPeriodly)".lowercased()

            let pricePerPeriod: String = {
                if let price = storekitPrice {
                    return perPeriodString(price: price, period: subscriptionPeriod)
                } else {
                    switch periodSource {
                    case let period where period.contains("week"):  return "$4.99/\(L10n.Period.week)"
                    case let period where period.contains("month"): return "$12.99/\(L10n.Period.month)"
                    case let period where period.contains("year"):  return "$39.99/\(L10n.Period.year)"
                    default:                                        return "$59.99/\(L10n.Period.oneTime)"
                    }
                }
            }()

            let pricePerWeek: String = {
                let lifetimeText = configPeriodly.isEmpty ? L10n.Price.limitedOffer : configPeriodly

                if let price = storekitPrice {
                    guard subscriptionPeriod != nil else { return lifetimeText }
                    return perWeekString(price: price, period: subscriptionPeriod)
                } else {
                    switch periodSource {
                    case let period where period.contains("week"):  return L10n.Price.perWeek("$4.99")
                    case let period where period.contains("month"): return L10n.Price.perWeek("$3.24")
                    case let period where period.contains("year"):  return L10n.Price.perWeek("$0.83")
                    default:                                        return lifetimeText
                    }
                }
            }()

            var isTrial = false
            var trialDuration: String? = nil
            var subscriptionDuration: String? = nil
            if let apphudProduct = apphudProduct {
                isTrial = await apphudProduct.isTrail()
                trialDuration = await apphudProduct.getTrialDuration()
                subscriptionDuration = await apphudProduct.getSubscriptionDuration()
            }
            
            let product: ProductModel
            product = ProductModel(
                id: fallbackProduct.id,
                title: L10n.resolve(fallbackProduct.title),
                subtitle: L10n.resolveOptional(fallbackProduct.subtitle),
                nonTrialSubtitle: L10n.resolveOptional(fallbackProduct.nonTrialSubtitle),
                message: L10n.resolveOptional(fallbackProduct.message),
                periodly: L10n.resolve(fallbackProduct.periodly),
                pricePerPeriod: pricePerPeriod,
                pricePerWeek: pricePerWeek,
                isTrial: isTrial,
                isLifetime: isLifetime,
                consumable: fallbackProduct.consumable,
                consumableUnit: fallbackProduct.consumableUnit,
                trialDuration: trialDuration,
                subscriptionDuration: subscriptionDuration
            )
            products.append(product)
        }
        
        let paywall = PaywallModel(id: id,
                                   title: L10n.localized(paywallFallback.title),
                                   tryFreeButton: L10n.localized(paywallFallback.tryFreeButton ?? "button.try_free"),
                                   continueButton: L10n.localized(paywallFallback.continueButton ?? "button.continue"),
                                   purchaseButton: L10n.localized(paywallFallback.purchaseButton ?? "button.purchase"),
                                   limitedButton: L10n.localized(paywallFallback.limitedButton ?? "button.limited"),
                                   configuration: PaywallConfiguration(paywallFallback.configurationAB ?? "variant1"),
                                   products: products,
                                   showRequestReview: paywallFallback.showRequestReview ?? true)
        
        return paywall
    }
    
    private func loadFallbackPaywall(_ paywallType: PremiumPaywallID, fileName: String) -> FallbackPaywall? {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let encryptedData = try? Data(contentsOf: url),
            let data = PremiumKitFallbackDecoder9d838a65664eca38.decrypt(encryptedData),
            let file = try? JSONDecoder().decode(FallbackFile.self, from: data),
            let entry = file.data.results.first(where: { $0.name == paywallType.rawValue }),
            let innerData = entry.json.data(using: .utf8),
            let paywall = try? JSONDecoder().decode(FallbackPaywall.self, from: innerData)
        else {
            print("Load Fallback Paywall: failed for \(paywallType) in \(fileName).json")
            return nil
        }
        return paywall
    }

    private func resolveApphudProduct(by id: String, for paywallType: PremiumPaywallID) async -> ApphudProduct? {
        
        if let placement = await Apphud.placement(paywallType.rawValue),
           let paywall = placement.paywall,
           let ahProduct = paywall.products.first(where: { $0.productId == id }) {
            return ahProduct
        }

        return nil
    }
    
    private func skFind(productId: String) -> SKConfig.SKProduct? {
        guard let config = SKConfig.shared else { return nil }

        if let product = config.subscriptionGroups?.flatMap(\.subscriptions).first(where: { $0.productID == productId }) {
            return product
        }
        if let product = config.nonRenewingSubscriptions?.first(where: { $0.productID == productId }) {
            return product
        }
        if let product = config.nonConsumableProducts?.first(where: { $0.productID == productId }) {
            return product
        }
        return nil
    }
    
    private func perPeriodString(price: String, period: SKConfig.SKProduct.Period?) -> String {
            guard let period else { return "$\(price)/\(L10n.Period.oneTime)" }
            return "$\(price)/\(period.localizedOne)"
        }

    private func moneyToDecimal(_ s: String) -> Decimal? {
        let filtered = s.filter { "0123456789.,".contains($0) }
        let normalized = filtered.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    private func weeks(in period: SKConfig.SKProduct.Period) -> Decimal {
        switch period.unit {
        case .day:        return Decimal(period.numberOfUnits) / 7
        case .weekOfMonth:return Decimal(period.numberOfUnits)
        case .month:      return Decimal(period.numberOfUnits * 4)
        case .year:       return Decimal(period.numberOfUnits * 52)
        default:          return 1
        }
    }

    private func truncate(_ value: Decimal, scale: Int) -> Decimal {
        var v = value, r = Decimal()
        NSDecimalRound(&r, &v, scale, .down)
        return r
    }

    private func currencySymbol(from price: String) -> String {
        for ch in price {
            if !ch.isNumber && ch != "." && ch != "," && !ch.isWhitespace { return String(ch) }
        }
        return "$"
    }

    private func perWeekString(price: String, period: SKConfig.SKProduct.Period?) -> String {
        guard let period, let priceDec = moneyToDecimal(price) else {
            return L10n.Price.limitedOffer
        }

        let isWeekly = (period.unit == .weekOfMonth && period.numberOfUnits == 1)
                    || (period.unit == .day && period.numberOfUnits == 7)

        let weekly = isWeekly ? priceDec : (priceDec / weeks(in: period))
        let truncated = truncate(weekly, scale: 2)

        let sym = currencySymbol(from: price)
        return L10n.Price.perWeek("\(sym)\(truncated)")
    }
}
