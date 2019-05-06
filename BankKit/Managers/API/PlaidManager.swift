//
//  PlaidManager.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-11-29.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation
import LinkKit
import Reachability

public class PlaidManager {
    public static let shared = PlaidManager()
    /// The app group to use to store account information
    static let groupIdentifier = "group.madebyayden.ios.Bank"
    /// The name of the notification fired when the status of Plaid Manager changes.
    public static let statusChangedNotification = Notification.Name(rawValue: "PlaidManagerStatusChangedNotificationName")
    public var api: PlaidAPI!
    public var reachability = Reachability()!, userDefaults: UserDefaults!
    
    private init() {
        // Create API manager with our API info
        api = info.createAPI()
        // Setup user defaults
        userDefaults = UserDefaults(suiteName: PlaidManager.groupIdentifier)
        if userDefaults == nil {
            print("Couldn't initialize user defaults with the app group identifier you specified. Falling back to app-only storage for now, but you should fix this if you want the today widget to work.")
            userDefaults = .standard
        }
        // Start network reachability notifier
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start Reachability notifier for Plaid Manager.")
        }
    }
    
    /// Setup the Plaid Manager for use, if connected to the internet. If not, wait until we are.
    public func setupWhenConnected() {
        guard reachability.connection == .none else { setup(); return }
        print("Internet is not currently reachable. Waiting until the next time the user connects to the internet before setting up Plaid Link...")
        reachability.whenReachable = { _ in
            print("Gained internet connectivity. Setting up Plaid Link for usage.")
            self.setup()
        }
    }
    
    /// Setup the Plaid Manager for use.
    public func setup() {
        // We don't need to set it up more than once.
        if status.isReady {
            print("Not setting up Plaid Link, as it is already ready for use.")
            return
        }
        print("Setting up Plaid Link for use...")
        PLKPlaidLink.setup(with: info.configuration) { (success, error) in
            guard success else {
                print("Unable to setup Plaid Link:", error?.localizedDescription ?? "No error")
                self._status = .failed(error)
                return
            }
            print("Plaid Link setup was successful.")
            self._status = .ready
        }
    }
    
    // MARK: - Storage
    
    /// The currently stored Plaid public token.
    public var accessToken: String? {
        get { return userDefaults.string(forKey: "PlaidAccessToken") }
        set { userDefaults.set(newValue, forKey: "PlaidAccessToken") }
    }
    
    // MARK: - Status
    
    /// The current status of the Plaid Manager.
    public var status: Status {
        // Return private status variable
        return _status
    }
    
    /// The current status of the Plaid Manager. Retrieved by 'status' (so it can't be modified from the outside)
    private var _status = Status.notReady {
        didSet {
            NotificationCenter.default.post(name: PlaidManager.statusChangedNotification, object: nil)
        }
    }
}

// MARK: - Add PlaidManager Status enum
extension PlaidManager {
    /// An enum for showing the current status of the Plaid Manager.
    public enum Status {
        case ready, notReady, failed(Error?)
        
        /// Whether the status represents one that is ready or not.
        public var isReady: Bool {
            switch self {
            case .ready: return true
            default: return false
            }
        }
        
        /// The status's error, if applicable.
        public var error: Error? {
            switch self {
            case .failed(let error): return error
            default: return nil
            }
        }
    }
}

// MARK: - Add Plaid Info
extension PlaidManager {
    /// Information about the current Plaid API being used by the app.
    public struct PlaidInfo {
        let publicKey: String, secret: String, clientID: String, environment: Environment
        
        public var baseURL: String {
            return "https://\(environment).plaid.com/"
        }
        
        public var configuration: PLKConfiguration {
            let config = PLKConfiguration(key: publicKey, env: environment.linkEnvironment, product: .transactions)
            config.clientName = "Bank for iOS"
            return config
        }
        
        fileprivate func createAPI() -> PlaidAPI {
            return PlaidAPI(rootServerURL: baseURL, clientID: clientID, secret: secret)
        }
        
        enum Environment: String {
            case development, sandbox, production
            
            var linkEnvironment: PLKEnvironment {
                switch self {
                case .development: return .development
                case .sandbox: return .sandbox
                case .production: return .production
                }
            }
        }
    }
    
    public var info: PlaidInfo {
        // Read Plaid.plist from main bundle
        guard let plistURL = Bundle.main.url(forResource: "Plaid", withExtension: "plist"), let plistData = try? Data(contentsOf: plistURL), let info = (try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)) as? [String: String] else { fatalError("Invalid or non-existant Plaid info .plist file was provided.") }
        // Get configuration from Plaid.plist
        guard let key = info["publicKey"], let clientID = info["clientID"], let secret = info["secret"], let env = info["environment"], let environment = PlaidInfo.Environment(rawValue: env) else { fatalError("Couldn't get required Plaid API Info from Info.plist") }
        return PlaidInfo(publicKey: key, secret: secret, clientID: clientID, environment: environment)
    }
}
