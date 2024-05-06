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
    
    // MARK: Get the top view controller
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
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
    
}
