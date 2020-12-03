//
//  HeadlinesFeed.swift
//  NewsFeed
//
//  Created by Семен Колодин on 03/12/2020.
//  Copyright © 2020 Semen Kolodin. All rights reserved.
//

import UIKit

@IBDesignable
class HeadlinesFeed: UIView {
    
    
    @IBOutlet weak var hStack: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let view = loadViewFromXib()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HeadlinesFeed", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first! as! UIView
    }

}
