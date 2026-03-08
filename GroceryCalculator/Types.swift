//
//  Types.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import Foundation

struct GroceryListT: Identifiable {
    let title: String
    let date: Date
    let id: UUID = UUID()
    
}
