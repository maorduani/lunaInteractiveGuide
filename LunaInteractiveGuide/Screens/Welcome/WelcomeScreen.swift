//
//  WelcomeScreen.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 11/07/2023.
//

import SwiftUI

struct WelcomeScreen: View {
    
    var onContinueTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 80) {
            VStack(spacing: 14) {
                title
                instrurctions
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 22)
            button
        }
    }
}

// MARK: - Subviews
extension WelcomeScreen {
    
    private var title: some View {
        Text("😄 \nWelcome to our interactive setup guide")
            .font(.title)
    }
    
    private var instrurctions: some View {
        Text("To obtain accurate results, we need you to position your phone vertically in a stable position and place your face in front of the front camera. \nIn this guide, we'll walk you through each step and ensure that everything is set up correctly.")
            .lineLimit(nil)
            .font(.body)
    }
    
    private var button: some View {
        Button("Letss start") {
            onContinueTapped()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(
            Color.blue
                .cornerRadius(14)
        )
        .padding(.horizontal, 70)
    }
}
struct InstructionScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen() { }
    }
}
