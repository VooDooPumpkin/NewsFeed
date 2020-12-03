//
//  NewsDetailInfo.swift
//  NewsFeed
//
//  Created by Семен Колодин on 03/12/2020.
//  Copyright © 2020 Semen Kolodin. All rights reserved.
//

import UIKit

@IBDesignable
class NewsDetailInfo: UIView {
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    var title: String?{
        didSet {
            titleLabel.text = title
        }
    }
    var content: String? {
        didSet {
            contentLabel.text = content
        }
    }
    var link: String?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    
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
        let nib = UINib(nibName: "NewsDetailInfo", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first! as! UIView
    }

}
