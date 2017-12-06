//
//  AccountHeaderView.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import SwiftChart

class AccountHeaderView: UIView, ChartDelegate {
    weak var delegate: AccountHeaderViewDelegate?
    var hasAwaken = false
    var chart: Chart!, formatter: DateFormatter!
    @IBOutlet weak var amountLabel: AmountLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var historicDateLabel: UILabel!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var chartLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var infoStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Setup formatter
        formatter = DateFormatter()
        formatter.dateStyle = .long
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
        chart.delegate = self
        chartContainerView.addSubview(chart)
        chartSegmentedControl.removeAllSegments()
        ChartViewRange.allOptions.enumerated().forEach {
            chartSegmentedControl.insertSegment(withTitle: $0.element.displayText.uppercased(), at: $0.offset, animated: false)
            if $0.element == SessionDataStorage.shared.selectedChartRange {
                chartSegmentedControl.selectedSegmentIndex = $0.offset
            }
        }
        // Initialization code
        setupData()
        hasAwaken = true
        // Listen for changes to periodic institution data store
        NotificationCenter.default.addObserver(self, selector: #selector(setupData), name: PeriodicFetchDataStorage.shared.institutions.dataChangedNotification, object: nil)
    }
    
    private var selectedRange: ChartViewRange {
        get { return ChartViewRange.allOptions[chartSegmentedControl.selectedSegmentIndex] }
        set {
            guard let index = ChartViewRange.allOptions.index(of: newValue) else { return }
            chartSegmentedControl.selectedSegmentIndex = index
        }
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
    
    var chartChangeIndex = 0
    private func setupChart() {
        chartChangeIndex += 1
        let requiredIndex = chartChangeIndex
        chart.removeAllSeries()
        chartLoadingView.stopAnimating()
        guard let account = account else { return }
        chartLoadingView.startAnimating()
        chart.finishTouchingChart()
        account.getBalanceHistoricalData(from: selectedRange.startDate) { (data) in
            // Make sure this is for the latest fetch, by comparing the change index when we started to the current one.
            if self.chartChangeIndex != requiredIndex { return }
            DispatchQueue.main.async {
                let series = ChartSeries(data: data.map { (x: Float($0.0.timeIntervalSinceReferenceDate), y: Float($0.1)) })
                series.color = Colours.main
                self.chart.add(series)
                self.chartLoadingView.stopAnimating()
            }
        }
    }
    
    func reselectCorrectChartViewRange() {
        selectedRange = SessionDataStorage.shared.selectedChartRange
    }
    
    var viewingChartInfo: (Date, Double)? {
        didSet {
            if let (date, amount) = viewingChartInfo {
                self.historicDateLabel.text = formatter.string(from: date)
                self.amountLabel.amount = amount
            } else {
                self.amountLabel.amount = account?.displayBalance ?? 0
            }
            // The rest is laying out for changes in the chart being selected or not, we can ignore if that hasn't just changed
            let isSelected = viewingChartInfo != nil
            if (oldValue != nil && isSelected) || (oldValue == nil && !isSelected) { return }
            delegate?.setMovementEnabled(to: !isSelected)
            let controlAlpha = CGFloat(isSelected ? 0.2 : 1)
            pageControl.isUserInteractionEnabled = !isSelected
            chartSegmentedControl.isUserInteractionEnabled = !isSelected
            UIView.animate(withDuration: 0.25) {
                self.historicDateLabel.alpha = isSelected ? 1 : 0
                self.pageControl.alpha = controlAlpha
                self.chartSegmentedControl.alpha = controlAlpha
            }
        }
    }
    
    // MARK: - Event Handlers
    
    @IBAction func pageControlChanged(_ sender: Any) {
        delegate?.shouldMove(to: pageControl.currentPage)
        pageControl.currentPage = accountIndex?.0 ?? 0
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        setupChart()
        SessionDataStorage.shared.selectedChartRange = selectedRange
    }
    
    // MARK: - Chart Delegate
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Float, left: CGFloat) {
        // User touched chart
        guard let index = indexes.first ?? nil, let (date, amount) = chart.series.first?.data[index] else { return }
        viewingChartInfo = (Date.init(timeIntervalSinceReferenceDate: TimeInterval(date)), Double(amount))
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        // User swiped outside chart
        viewingChartInfo = nil
    }
    
    func didEndTouchingChart(_ chart: Chart) {}
    
}

protocol AccountHeaderViewDelegate: class {
    func shouldMove(to index: Int)
    func setMovementEnabled(to enabled: Bool)
}

// MARK: - Chart View Range Extension
extension AccountHeaderView {
    enum ChartViewRange: TimeInterval {
        static let allOptions: [ChartViewRange] = [.week, .twoWeeks, .month, .threeMonths, .sixMonths, .year, .all]
        static let defaultOption = ChartViewRange.month
        case week = 7, twoWeeks = 14, month = 30, threeMonths = 90, sixMonths = 180, year = 365, all = 0
        
        var startDate: Date? {
            guard days > 0 else { return nil }
            return Date().addingTimeInterval(-60 * 60 * 24 * days)
        }
        
        var days: TimeInterval {
            return rawValue
        }
        
        var displayText: String {
            switch self {
            case .week: return "1W"
            case .twoWeeks: return "2W"
            case .month: return "1M"
            case .threeMonths: return "3M"
            case .sixMonths: return "6M"
            case .year: return "1Y"
            case .all: return "All"
            }
        }
    }
}
