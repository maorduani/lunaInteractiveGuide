//
//  GlassesView.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 10/07/2023.
//

import SwiftUI

struct GlassesConfig {
    let color: Color
    let height: CGFloat
    let offset: CGFloat
    let eyeState: EyeState
    
    enum EyeState: Equatable {
        case fillLens
        case ofsseted(value: CGFloat)
    }
}

struct GlassesView: View {
    
    let config: GlassesConfig
        
    var body: some View {
        HStack(spacing: 0) {
            sideHandle
                .offset(x: 5)
            lens()
            Rectangle()
                .frame(width: 10, height: 8)
            lens()
            sideHandle
                .offset(x: -5)
        }
        .foregroundColor(config.color)
        .frame(height: config.height)
        .offset(y: config.offset)
        .animation(.spring(response: 0.7,
                           dampingFraction: 0.7,
                           blendDuration: 0.4),
                   value: config.offset)
    }
}

// MARK: - Subviews
extension GlassesView {
    
    private var sideHandle: some View {
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 20, height: 15)
    }
    
    private func lens() -> some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 35)
                .strokeBorder(lineWidth: 10)
                .background(
                    EyeView(size: proxy.size.width,
                            fillView: config.eyeState == .fillLens)
                    .offset(y: eyeOffset)
                )
                .clipShape(RoundedRectangle(cornerRadius: 35))
        }
        .animation(
            .spring(response: 0.7,
                    dampingFraction: 0.7,
                    blendDuration: 0.4),
            value: config.eyeState
        )
    }
}

// MARK: - Private
extension GlassesView {
        private var eyeOffset: CGFloat {
        switch config.eyeState {
        case .fillLens:
            return 0
        case .ofsseted(let value):
            return value
        }
    }
}

// MARK: - Previews
struct GlassesView_Previews: PreviewProvider {

    static var previews: some View {
        ZStack {
            Color.gray
                .edgesIgnoringSafeArea(.all)
            GlassesView(config: GlassesConfig(color: .blue, height: 250, offset: 0, eyeState: .fillLens))
        }
    }
}
