//
//  AccountHeaderView.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import SwiftChart

class AccountHeaderView: UIView {
    weak var delegate: AccountHeaderViewDelegate?
    @IBOutlet weak var amountLabel: AmountLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var chartLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var infoStackView: UIStackView!
    var hasAwaken = false
    var chart: Chart!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Setup chart
        chart = Chart(frame: chartContainerView.bounds)
        chart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chart.gridColor = .clear
        chart.axesColor = .clear
        chart.highlightLineColor = .lightGray
        chart.lineWidth = 3
        chart.labelFont = .systemFont(ofSize: 0)
        chart.labelColor = .clear
        chart.topInset = 0
        chart.bottomInset = 0
        chartContainerView.addSubview(chart)
        // Initialization code
        setupData()
        hasAwaken = true
        // Listen for changes to periodic institution data store
        NotificationCenter.default.addObserver(self, selector: #selector(setupData), name: PeriodicFetchDataStorage.shared.institutions.dataChangedNotification, object: nil)
    }
    
    var account: Account? {
        didSet {
            if hasAwaken { setupData() }
        }
    }
    
    var accountIndex: (Int, Int)? {
        didSet {
            if hasAwaken { setupData() }
        }
    }
    
    @objc func setupData() {
        amountLabel.amount = account?.displayBalance ?? 0
        nameLabel.text = account?.name ?? "Account Name"
        institutionLabel.text = account?.institutionDescription ?? "Institution Name"
        pageControl.numberOfPages = accountIndex?.1 ?? 1
        pageControl.currentPage = accountIndex?.0 ?? 0
        setupChart()
    }
    
    private func setupChart() {
        chart.removeAllSeries()
        chartLoadingView.stopAnimating()
        guard let account = account else { return }
        chartLoadingView.startAnimating()
        account.getBalanceHistoricalData(from: Date().addingTimeInterval(-60 * 60 * 24 * 30)) { (data) in
            DispatchQueue.main.async {
                let series = ChartSeries(data: data.map { (x: Float($0.0.timeIntervalSinceReferenceDate), y: Float($0.1)) })
                series.color = .gradientColor(from: Colours.lighterMain, to: Colours.main, height: self.chartContainerView.bounds.height)
                self.chart.add(series)
                self.chartLoadingView.stopAnimating()
            }
        }
    }
    
    // MARK: - Event Handlers

    @IBAction func pageControlChanged(_ sender: Any) {
        delegate?.shouldMove(to: pageControl.currentPage)
        pageControl.currentPage = accountIndex?.0 ?? 0
    }
    
}

protocol AccountHeaderViewDelegate: class {
    func shouldMove(to index: Int)
}
