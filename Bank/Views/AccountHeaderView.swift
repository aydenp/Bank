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
    @IBOutlet weak var amountLabel: AmountLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupChart()
    }
    
    var account: Account? {
        didSet {
            if hasAwaken { setupData() }
        }
    }
    
    @objc func setupData() {
        amountLabel.amount = account?.displayBalance ?? 0
        nameLabel.text = account?.name ?? "Account Name"
        institutionLabel.text = account?.institutionDescription ?? "Institution Name"
        setupChart()
    }
    
    private func setupChart() {
        chart.removeAllSeries()
        if let chartData = account?.balanceHistoricalData(from: Date().addingTimeInterval(-60 * 60 * 24 * 30)) {
            let series = ChartSeries(chartData.map { Float($0) })
            series.color = .gradientColor(from: Colours.lighterMain, to: Colours.main, height: chartContainerView.bounds.height)
            chart.add(series)
        }
    }
}
