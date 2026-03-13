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
        ZStack(alignment: .center) {
            Circle()
                .fill(.accent)
                .frame(width: 72, height: 72)
            
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 24, height: 24)
                .bold()
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    BtnOverlayComponent(imageName: "plus")
}
