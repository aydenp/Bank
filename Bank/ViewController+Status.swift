//
//  ViewController+Status.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

// MARK: - View controller status handling
extension ViewController {
    func setupStatus() {
        // Determine the current status
        determineStatus()
        // and update us with Plaid Manager status changes
        NotificationCenter.default.addObserver(self, selector: #selector(determineStatus), name: PlaidManager.statusChangedNotification, object: nil)
    }
    
    func handleStatusChange(to status: Status) {
        // Ensure we're on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async { self.handleStatusChange(to: status) }
            return
        }
        print("Status has changed: \(status)")
        if status == .loading {
            startLoading()
        }
        if status.needsOverlayView {
            // This status needs an overlay view
            if let vc = statusViewController {
                // If we already have a status view controller, just update its status
                vc.update(with: status)
            } else {
                // If not, show it (it will get the current status during segue preparation)
                self.performSegue(withIdentifier: "ShowStatus", sender: nil)
            }
        } else {
            // This status doesn't require an overlay view, dismiss and destroy ours
            statusViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            statusViewController = nil
        }
    }
    
    enum Status: String, CustomDebugStringConvertible {
        case ready, loading, waitingForManager, needsLink, obtainingAccessToken, initialLoading
        
        var needsOverlayView: Bool {
            return needsOverlaySpinner || needsLinkView
        }
        
        var needsOverlaySpinner: Bool {
            switch self {
            case .loading, .initialLoading, .waitingForManager, .obtainingAccessToken: return true
            default: return false
            }
        }
        
        var needsLinkView: Bool {
            switch self {
            case .needsLink: return true
            default: return false
            }
        }
        
        var debugDescription: String {
            switch self {
            case .ready: return "Ready with account info"
            case .needsLink: return "Ready to link with Plaid"
            case .loading: return "Getting account info"
            case .obtainingAccessToken: return "Obtaining permanent access token"
            case .waitingForManager: return "Waiting for Plaid Manager to setup"
            case .initialLoading: return "Initial loading"
            }
        }
    }
    
    @objc func determineStatus() {
        if PlaidManager.shared.accessToken != nil {
            // We have a access token, we're ready
            status = SessionDataStorage.shared.accounts != nil ? .ready : .loading
        } else if PlaidManager.shared.status.isReady {
            // No stored access token, we need to show link or loading
            status = isExchanging ? .obtainingAccessToken : .needsLink
        } else {
            // We need to wait for the Plaid Manager to prepare itself
            status = .waitingForManager
        }
    }
}

// MARK: - Status View Controller Delegate
extension ViewController: StatusViewControllerDelegate {
    func didFinishSetup(with publicToken: String) {
        isExchanging = true
        determineStatus()
        print("Obtaining access token from public token...")
        PlaidManager.shared.api.getAccessToken(from: publicToken) { (accessToken, error) in
            self.isExchanging = false
            guard error == nil, let accessToken = accessToken else {
                print("Couldn't exchange access token:", error?.localizedDescription ?? "unknown error")
                (self.statusViewController ?? self).showAlert(title: "Couldn't Link Bank Account", message: error?.localizedDescription ?? "An unknown error occurred while attempting to link your bank account.")
                return
            }
            print("Got access token from Plaid.")
            PlaidManager.shared.accessToken = accessToken
            self.determineStatus()
        }
    }
}
