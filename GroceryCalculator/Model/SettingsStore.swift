//
//  SettingsStore.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-05-05.
//

import Foundation
import Observation

@Observable
public final class SettingsStore {
    public var selectedCurrency: String {
        didSet { UserDefaults.standard.set(selectedCurrency, forKey: Keys.selectedCurrency) }
    }
    public var currencies: [String] {
        didSet {
            if let data = try? JSONEncoder().encode(currencies) {
                UserDefaults.standard.set(data, forKey: Keys.currencies)
            }
        }
    }
    public var taxInclusive: Bool {
        didSet { UserDefaults.standard.set(taxInclusive, forKey: Keys.taxInclusive) }
    }
    public var taxPercentage: Double {
        didSet { UserDefaults.standard.set(taxPercentage, forKey: Keys.taxPercentage) }
    }

    public init() {
        let defaults = UserDefaults.standard
        selectedCurrency = defaults.string(forKey: Keys.selectedCurrency) ?? "USD"
        taxInclusive = defaults.bool(forKey: Keys.taxInclusive)
        taxPercentage = defaults.double(forKey: Keys.taxPercentage)

        if let data = defaults.data(forKey: Keys.currencies),
           let saved = try? JSONDecoder().decode([String].self, from: data) {
            currencies = saved
        } else {
            currencies = ["USD", "CAD", "GBP", "NGN"]
        }
    }

    // Decimal multiplier for tax (1.0 when tax is off or 0%)
    public var taxMultiplier: Decimal {
        guard taxInclusive && taxPercentage > 0 else { return 1 }
        return Decimal(1) + Decimal(taxPercentage) / Decimal(100)
    }

    private enum Keys {
        static let selectedCurrency = "selectedCurrency"
        static let currencies = "currencies"
        static let taxInclusive = "taxInclusive"
        static let taxPercentage = "taxPercentage"
    }
}
