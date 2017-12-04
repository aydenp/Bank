//
//  RangeSegmentedControl.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-04.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class RangeSegmentedControl: UISegmentedControl {
    private var selectionView: UIView!, selectionViewLeftAnchor: NSLayoutConstraint!, selectionViewWidthAnchor: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        selectionView = UIView()
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionView)
        selectionView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        selectionViewLeftAnchor = selectionView.leftAnchor.constraint(equalTo: leftAnchor)
        selectionViewLeftAnchor.isActive = true
        selectionView.topAnchor.constraint(equalTo: bottomAnchor, constant: 3).isActive = true
        selectionViewWidthAnchor = selectionView.widthAnchor.constraint(equalToConstant: 0)
        selectionViewWidthAnchor.isActive = true
        setColours()
        addTarget(self, action: #selector(didChangeIndex), for: .valueChanged)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        setColours()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        moveSelectionView()
    }
    
    @objc func didChangeIndex() {
        self.moveSelectionView(animated: true)
    }
    
    var isAnimating = false
    private func moveSelectionView(animated: Bool = false, overrideAnimationState: Bool = false) {
        if isAnimating && !overrideAnimationState { return }
        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: [], animations: {
                self.moveSelectionView(animated: false, overrideAnimationState: true)
            }, completion: { _ in self.isAnimating = false })
            return
        }
        selectionViewWidthAnchor.constant = bounds.size.width / CGFloat(numberOfSegments)
        selectionViewLeftAnchor.constant = selectionViewWidthAnchor.constant * CGFloat(selectedSegmentIndex)
        layoutIfNeeded()
    }
    
    private func setColours() {
        tintColor = .clear
        setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(white: 0.7569, alpha: 1), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .bold)], for: .normal)
        setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Colours.main], for: .selected)
        selectionView.backgroundColor = Colours.main
    }
}
