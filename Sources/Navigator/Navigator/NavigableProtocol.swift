//
//  NavigableProtocol.swift
//  
//
//  Created by Cristian Carlassare.
//

import UIKit


// MARK: - Navigable ViewControllers

public protocol Navigable where Self: UIViewController {
    
    var navigator: Navigator? { get set }
}


public extension Navigable {
    
//    static func instantiateFromStoryboard(name storyboardName: String) -> Self {
//        return Self.fromStoryboard(name: storyboardName)
//    }
//
//    static func instantiateFromNib() -> Self {
//        return Self.fromNib()
//    }
    
    func startNavigatorFromHere() {
        if let navigator = self.navigator {
            navigator.startNavigator(from: self)
            
        } else if let navigationController = self.navigationController {
            let newNavigator = Navigator(navigationController: navigationController)
            self.navigator = newNavigator
            self.navigator?.setNavigator(navigator: newNavigator, for: self)
        }
    }
}
