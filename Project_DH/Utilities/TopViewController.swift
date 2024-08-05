//
//  TopViewController.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/5/24.
//

import Foundation
import UIKit


final class TopViewController {
    
    static let sharedTopController = TopViewController()
    private init() {}
    
    
    /// This method gets the top view controller.
    /// - Parameters:
    ///     - controller: The optional controller to check against.
    /// - Returns: The top ViewController.
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? getKeyWindow()?.rootViewController
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
    
    
    ///  This function returns the key window of the application. The key window is the window currently receiving user events.
    /// - Parameters: none
    /// - Returns: The key UIWindow.
    private func getKeyWindow() -> UIWindow? {
           return UIApplication.shared
               .connectedScenes
               .compactMap { $0 as? UIWindowScene }
               .flatMap { $0.windows }
               .first { $0.isKeyWindow }
    }
    
}
