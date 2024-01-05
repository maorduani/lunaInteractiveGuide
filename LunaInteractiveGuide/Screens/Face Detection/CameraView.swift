//
//  CameraView.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 09/07/2023.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
        
    var onSuccess: (() -> Void)
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.onSuccess = onSuccess
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}
