//
//  BtnOverlayComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-13.
//

import SwiftUI

struct BtnOverlayComponent: View {
    var imageName: String
    init(imageName: String) {
        self.imageName = imageName
    }
    var body: some View {
        ZStack {
            Circle()
                .fill(.accent)
                .frame(width: 72, height: 72)
            
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 24, height: 24)
                .bold()
        }
    }
}

#Preview {
    BtnOverlayComponent(imageName: "plus")
}
