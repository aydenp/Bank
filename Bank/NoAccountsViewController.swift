//
//  NoAccountsViewController.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class NoAccountsViewController: UIViewController {
    weak var delegate: NoAccountsViewControllerDelegate?
    
    @IBAction func tappedUnlink(_ sender: Any) {
        delegate?.didTapUnlink()
    }
    
    static func get() -> NoAccountsViewController {
        return UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "NoAccounts") as! NoAccountsViewController
    }
}

protocol NoAccountsViewControllerDelegate: class {
    func didTapUnlink()
}
