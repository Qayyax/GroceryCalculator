//
//  CustomStepper.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct CustomStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        // TODO:
        // - Change the color to match the design
        HStack(spacing: 0) {
            Button(action: {
                if value > range.lowerBound { value -= 1 }
            }) {
                Text("-")
                    .font(.title)
                    .foregroundStyle(.itemAmountGray)
                    .padding(8)
                    .background {
                        UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 0, topTrailingRadius: 0)
                            .stroke(.buttonStrokeGray, lineWidth: 0.5)
                    }
            }
            .disabled(value == range.lowerBound)
            
            Text("\(value)")
                .font(.title)
                .foregroundStyle(.itemAmountGray)
                .padding(8)
                .padding(.horizontal, 12)
                .background{
                    Rectangle()
                        .stroke(.buttonStrokeGray, lineWidth: 0.5)
                }

            Button(action: {
                if value < range.upperBound { value += 1 }
            }) {
                Text("+")
                    .font(.title)
                    .foregroundStyle(.itemAmountGray)
                    .padding(8)
                    .background {
                        UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 10, topTrailingRadius: 10)
                            .stroke(.buttonStrokeGray, lineWidth: 0.5)
                    }
            }
            .disabled(value == range.upperBound)
        }
    }
}
#Preview {
    @Previewable @State var stepperValue: Int = 1
    CustomStepper(value: $stepperValue, range: 1...10)
}
