//
//  DevicePositioningScreen.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 08/07/2023.
//

import SwiftUI
import Combine

struct DevicePositioningScreen: View {
    
    @State private var animateProgressBar = false
    @ObservedObject var viewModel: DevicePositionViewModel
    var onCompleted: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                blurredEyes(size: proxy.size.height * Constants.eyeScale)
                GlassesView(config: glassesConfigBy(screenSize: proxy.size))
                    .padding(.horizontal, Constants.glassesPadding)
                if viewModel.showDeviceNotVerticalError {
                    positionVerticallyMessage()
                        .transition(.opacity)
                }
            }
            .frame(maxHeight: .infinity)
            .animation(.default, value: viewModel.showDeviceNotVerticalError)
            stateIndicatorViews(screenSize: proxy.size)
        }
        .background(
            backgroundColor
                .edgesIgnoringSafeArea(.all)
        )
        .animation(.easeOut, value: hueValue)
    }
}

// MARK: - Subviews
extension DevicePositioningScreen {
    
    private var hueValue: Double {
        return viewModel.circularHalfPercent * 2 * Constants.hueColorNumber
    }
    
    private var glassesColor: Color {
        return Color(hue: hueValue, saturation: 0.35, brightness: 0.11)
    }
    
    private var backgroundColor: Color {
        return Color(hue: hueValue, saturation: 0.95, brightness: 0.95)
    }
    
    private func stateIndicatorViews(screenSize: CGSize) -> some View {
        VStack {
            let width = screenSize.width * 0.75
            if viewModel.showProgressBar {
                progressBarView(width: width)
                    .transition(.opacity.combined(with: .scale))
            }
            Spacer()
            if viewModel.showContinueButton {
                continueButton(width: width)
                    .transition(.offset(y: 200))
            }
            if viewModel.showInstructions {
                instructions()
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(50)
        .animation(.default, value: viewModel.showProgressBar)
        .animation(.spring(), value: viewModel.showContinueButton)
    }
    
    private func blurredEyes(size: CGFloat) -> some View {
        HStack(spacing: Constants.eyesDistance) {
            EyeView(size: size)
            EyeView(size: size)
        }
        .blur(radius: Constants.eyesBlur)
    }
    
    private func progressBarView(width: CGFloat) -> some View {
        VStack(spacing: 30) {
            VStack(spacing: 6) {
                Text("Perfect!")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("Keep it for few more seconds")
                    .font(.title3)
            }
            .foregroundColor(.black)
            ZStack(alignment: .leading) {
                Color.white.blendMode(.overlay)
                Color.white
                    .frame(width: animateProgressBar ? width : 0)
                    .animation(.linear(duration: 3), value: animateProgressBar)
                .cornerRadius(18)
            }
            .cornerRadius(30)
            .frame(width: width, height: 30)
        }
        .onAppear {
            animateProgressBar = true
        }
        .onDisappear {
            animateProgressBar = false
        }
    }
    
    private func continueButton(width: CGFloat) -> some View {
        Button("Continue") {
            onCompleted()
        }
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black)
                .frame(width: width, height: 50)
        )
    }
    
    private func positionVerticallyMessage() -> some View {
        Color.black
            .edgesIgnoringSafeArea(.all)
            .overlay {
                VStack(spacing: 20) {
                    Image(systemName: "iphone")
                        .font(.system(size: 120))
                    Text("Position your phone vertically in front of you, camera facing up")
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(.white)
                .padding(50)
                .offset(y: -50)
            }
    }
    
    private func instructions() -> some View {
        Text("Move your phone until eyes are fully unblurred")
            .multilineTextAlignment(.center)
            .foregroundColor(.black.opacity(0.8))
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                Color.white.opacity(0.5)
                    .cornerRadius(22)
            )
    }
}


// MARK: - Private Methods
extension DevicePositioningScreen {
    
    private func glassesConfigBy(screenSize: CGSize) -> GlassesConfig {
        let height = screenSize.height * Constants.glassesScale
        let availableSpace = screenSize.height - (height * 1.5)
        let glassesOffset = (viewModel.offsetFromCenter) * availableSpace
        let eyeOffset = glassesOffset * -1
        let eyeState: GlassesConfig.EyeState = viewModel.isInRange ? .fillLens : .ofsseted(value: eyeOffset)
        return GlassesConfig(color: glassesColor, height: height, offset: glassesOffset, eyeState: eyeState)
    }
}

// MARK: - Helpers
extension DevicePositioningScreen {
        
    private struct Constants {
        static let eyeScale: CGFloat = 0.125
        static let glassesScale: CGFloat = 0.25
        static let glassesPadding: CGFloat = 16
        static let eyesDistance: CGFloat = 20
        static let eyesBlur: CGFloat = 5
        static let hueColorNumber: Double = 115 / 360
    }
}

struct DevicePositioningScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DevicePositioningScreen(viewModel: DevicePositionViewModel.inRange) { }
                .previewDisplayName("In Range")
            
            DevicePositioningScreen(viewModel: DevicePositionViewModel.notInRage) { }
                .previewDisplayName("Not In Range")
          
            DevicePositioningScreen(viewModel: DevicePositionViewModel.notPositionedCorrectly) { }
                .previewDisplayName("Not Positioned Correctly")
        }
    }
}
