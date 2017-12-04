//
//  SetupBankViewController.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import LinkKit

class StatusViewController: UIViewController, PLKPlaidLinkViewDelegate {
    @IBOutlet weak var setupBankView: UIStackView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    weak var delegate: StatusViewControllerDelegate?
    private var statusToSetOnLoad: ViewController.Status?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let status = statusToSetOnLoad {
            update(with: status)
            statusToSetOnLoad = nil
        }
    }
    
    func update(with status: ViewController.Status) {
        guard isViewLoaded else {
            statusToSetOnLoad = status
            return
        }
        if status.needsOverlaySpinner {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
        setupBankView.isHidden = !status.needsLinkView
        // TODO: Support showing Plaid Manager errors here
    }
    
    @IBAction func tappedSetup(_ sender: Any) {
        let linkViewController = PLKPlaidLinkViewController(configuration: PlaidManager.shared.info.configuration, delegate: self)
        if UIDevice.current.userInterfaceIdiom == .pad {
            linkViewController.modalPresentationStyle = .formSheet
        }
        present(linkViewController, animated: true)
    }
    
    // MARK: - Plaid Link View Delegate
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        print("Successfully linked Plaid with public token: \(publicToken).")
        delegate?.didFinishSetup(with: publicToken)
        dismiss(animated: true, completion: nil)
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        print("Couldn't link bank account:", error?.localizedDescription ?? "no error", metadata ?? "no metadata")
        dismiss(animated: true, completion: nil)
        showAlert(title: "Couldn't Link Bank Account", message: error?.localizedDescription ?? "An unknown error occurred while trying to link your bank account.")
    }
}

protocol StatusViewControllerDelegate: class {
    func didFinishSetup(with publicToken: String)
}
