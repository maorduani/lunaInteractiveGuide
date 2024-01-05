//
//  EyeView.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 10/07/2023.
//

import SwiftUI

struct EyeView: View {
    
    private let maxSize: CGFloat
    let eyeSize: CGFloat
    let pupilSize: CGFloat
    let fillView: Bool
    
    init(size: CGFloat, fillView: Bool = false) {
        self.eyeSize = size
        self.pupilSize = size * 0.35
        self.fillView = fillView
        self.maxSize = fillView ? .infinity : eyeSize
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: fillView ? 22 : eyeSize)
            .fill(.white)
            .frame(maxWidth: maxSize,
                   maxHeight: maxSize)
            .overlay {
                pupil()
            }
    }
    
    private func pupil() -> some View {
        ZStack {
            Circle()
                .fill(.black)
            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: pupilSize * 0.5)
                .blur(radius: 3)
                .offset(x: 8, y: -8)
            Circle()
                .fill(.white.opacity(0.6))
                .frame(width: pupilSize * 0.2)
                .blur(radius: 2)
                .offset(x: 10, y: -10)
        }
        .frame(width: pupilSize)
    }
}

// MARK: - Private
struct EyeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            EyeView(size: 150, fillView: true)
        }
        .frame(width: 300, height: 300)
        .previewLayout(.sizeThatFits)
    }
}
