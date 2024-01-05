//
//  StepsScreen.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 10/07/2023.
//

import SwiftUI

struct StepsScreen: View {
    
    @StateObject var organizer = StepsOrganizer()
    @State private var disableAnimation = true
    @State private var showVideoIntro = true
            
    var body: some View {
        ZStack {
            switch organizer.currentStep {
            case .welcome:
                WelcomeScreen(onContinueTapped: onStepCompleted)
            case .devicePositioning:
                //Actual screen is presented as full screen cover
                EmptyView()
            case .faceDetection:
                if showVideoIntro {
                    faceDetectionIntro()
                } else {
                    CameraView(onSuccess: onStepCompleted)
                }
            case .completed:
                setupCompletedView()
            }
        }
        .fullScreenCover(item: $organizer.devicePositionViewModel) { viewModel in
            DevicePositioningScreen(viewModel: viewModel,
                                    onCompleted: onStepCompleted)
        }
    }
}

// MARK: - Private
extension StepsScreen {
    
    private func onStepCompleted() {
        organizer.moveToNextStep()
    }
    
    private func setupCompletedView() -> some View {
        VStack {
            Text("🥳 ")
                .font(.system(size: 60))
            Text("Setup completed!")
                .font(.largeTitle)
        }
    }
    
    private func faceDetectionIntro() -> some View {
        VStack {
            Text("Please Position your face in front of the camera.\nTap the button when you are ready.")
                .multilineTextAlignment(.center)
                .font(.title3)
                .foregroundColor(.black)
                .padding(30)
            Button("I'm ready") {
                showVideoIntro = false
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
}
struct GuidesScreen_Previews: PreviewProvider {
    static var previews: some View {
        StepsScreen()
    }
}
