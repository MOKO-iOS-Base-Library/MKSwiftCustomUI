//
//  MKSwiftBaseNavigationController.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/6.
//

import UIKit

open class MKSwiftBaseNavigationController:UINavigationController {
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true;
        }
        super.pushViewController(viewController, animated: animated);
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default;
    }
}
