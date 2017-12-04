//
//  UIViewController+ShorthandAlerts.swift
//
//  Created by Ayden P on 2017-07-31.
//  Copyright © 2017 Ayden P. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Show an alert on the view controller.
    func showAlert(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .alert, actions: [UIAlertAction] = [.ok], completion: (() -> Void)? = nil) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.showAlert(title: title, message: message, preferredStyle: preferredStyle, actions: actions, completion: completion)
            }
            return
        }
        let alert = UIAlertController.createAlert(title: title, message: message, preferredStyle: preferredStyle, actions: actions, completion: completion)
        present(alert, animated: true, completion: completion)
    }
    
    /// Show an alert on the view controller.
    func showAlert(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .alert, action: UIAlertAction, completion: (() -> Void)? = nil) {
        showAlert(title: title, message: message, preferredStyle: preferredStyle, actions: [action], completion: completion)
    }
    
}

extension UIAlertController {
    
    static func createAlert(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .alert, actions: [UIAlertAction] = [.ok], completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = self.init(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach({ alert.addAction($0) })
        return alert
    }
    
}

// Extend UIAlertAction to have quick and Swift-like initializers
extension UIAlertAction {
    
    static func cancel(_ title: String = "Cancel", handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .cancel, handler: handler)
    }
    
    static func ok(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return self.cancel("OK", handler: handler)
    }
    
    static func dismiss(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return self.cancel("Dismiss", handler: handler)
    }
    
    static func normal(_ title: String, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: handler)
    }
    
    static func destructive(_ title: String, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .destructive, handler: handler)
    }
    
    static func delete(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "Delete", style: .destructive, handler: handler)
    }
    
    // Allow being accessed as properties:
    
    static var cancel: UIAlertAction {
        return .cancel()
    }
    
    static var ok: UIAlertAction {
        return .ok()
    }
    
    static var dismiss: UIAlertAction {
        return .dismiss()
    }
    
    static var delete: UIAlertAction {
        return .delete()
    }
    
}
