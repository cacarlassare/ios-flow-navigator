//
//  Navigator.swift
//  
//
//  Created by Cristian Carlassare.
//

import UIKit


open class Navigator {
    
    internal var superNavigator: Navigator? = nil
    internal var navigationController: UINavigationController
    

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    // MARK: Start
    
    open func start(with viewController: UIViewController) {
        if let navigableViewController = viewController as? Navigable {
            self.setNavigator(navigator: self, for: navigableViewController)
        }
    }
    
    internal func startNavigator(from navigable: Navigable) {
        if let navigationController = navigable.navigationController {
            let newNavigator = Navigator(navigationController: navigationController)
            newNavigator.superNavigator = self.superNavigator ?? self
            self.setNavigator(navigator: newNavigator, for: navigable)
        }
    }
    
    
    // MARK: Push
    
    open func push(viewController: Navigable, animated: Bool = true) {
        DispatchQueue.main.async {
            self.setNavigator(navigator: self, for: viewController)
            self.navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    
    // MARK: Go Back
    
    open func goBack(animated: Bool = true) {
        DispatchQueue.main.async {
            self.navigationController.popViewController(animated: animated)
        }
    }
    
    open func goBackToRoot(animated: Bool = true) {
        DispatchQueue.main.async {
            (self.superNavigator ?? self).navigationController.popToRootViewController(animated: animated)
        }
    }
    
    open func canGoBack(to navigable: Navigable) -> Bool {
        return self.navigationController.viewControllers.contains(navigable) || (self.superNavigator ?? self).navigationController.viewControllers.contains(navigable)
    }
    
    open func goBack(to navigable: Navigable, animated: Bool = true) {
        if self.navigationController.viewControllers.contains(navigable) {
            self.popToViewController(navigable, animated: animated)
        } else if let superNavigator = self.superNavigator,  superNavigator.navigationController.viewControllers.contains(navigable) {
            DispatchQueue.main.async {
                superNavigator.navigationController.popToViewController(navigable, animated: animated)
            }
        }
    }
    
    open func goBack(toType navigable: UIViewController.Type, animated: Bool = true) {
    
        for viewController in self.navigationController.viewControllers {
            if navigable == type(of: viewController)  {
                self.popToViewController(viewController, animated: animated)
                return
            }
        }
        
        if let superNavigator = self.superNavigator {
            for viewController in superNavigator.navigationController.viewControllers {
                if navigable == type(of: viewController)  {
                    self.popToViewController(viewController, animated: animated)
                    return
                }
            }
        }
    }
    
    func popToViewController(_ viewController: UIViewController, animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController.popToViewController(viewController, animated: animated)
        }
    }
    
    
    // MARK: - Set Navigator for navigation structures
    
    func setNavigator(navigator: Navigator, for viewController: Navigable) {
        viewController.navigator = navigator
        
        // Set Navigator for TabBar
        if let tabBarViewController = viewController as? UITabBarController {
            self.setTabBarNavigator(navigator: navigator, controller: tabBarViewController)
        }
        
        // Set Navigator for NavigationController
        if let navigationViewController = viewController as? UINavigationController {
            self.setNavigationControllerNavigator(navigator: navigator, controller: navigationViewController)
        }
    }
    
    
    // Set Navigator for TabBar
    
    fileprivate func setTabBarNavigator(navigator: Navigator, controller: UITabBarController) {
        if let viewControllers = controller.viewControllers {
            
            for viewController in viewControllers {
                if let navigableViewController = viewController as? Navigable {
                    navigableViewController.navigator = navigator
                } else if let navigationViewController = viewController as? UINavigationController {
                    self.setNavigationControllerNavigator(navigator: navigator, controller: navigationViewController)
                }
            }
        }
    }
    
    // Set Navigator for NavigationController
    
    fileprivate func setNavigationControllerNavigator(navigator: Navigator, controller: UINavigationController) {
        if let viewController = controller.topViewController {
            if let navigableViewController = viewController as? Navigable {
                navigableViewController.navigator = navigator
            }
        }
    }
}
