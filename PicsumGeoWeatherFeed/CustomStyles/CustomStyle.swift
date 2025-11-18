//
//  CustomStyle.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 18/11/25.
//
import SwiftUI

struct ListMapToggleStyle: ToggleStyle {
    @SwiftUI.State private var isAnimating = false
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            guard !isAnimating else { return }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                configuration.isOn.toggle()
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    isAnimating = false
                }
            }
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(configuration.isOn ? "mapSelectedSwitch" : "listSelectedSwitch")
            }
        }
        .buttonStyle(.plain)
        .disabled(isAnimating)
        .opacity(isAnimating ? 0.3 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isAnimating)
    }
}
