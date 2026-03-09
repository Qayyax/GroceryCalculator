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
        HStack {
            Button(action: {
                if value > range.lowerBound { value -= 1 }
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
                    .foregroundColor(value > range.lowerBound ? .red : .gray)
            }
            .disabled(value == range.lowerBound)
            
            Text("\(value)")
                .font(.title)
                .frame(width: 50)
                
            Button(action: {
                if value < range.upperBound { value += 1 }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(value < range.upperBound ? .green : .gray)
            }
            .disabled(value == range.upperBound)
        }
    }
}
#Preview {
    @Previewable @State var stepperValue: Int = 1
    CustomStepper(value: $stepperValue, range: 1...10)
}
