//
//  NewsDetailsViewController.swift
//  NewsFeed
//
//  Created by Семен Колодин on 03/12/2020.
//  Copyright © 2020 Semen Kolodin. All rights reserved.
//

import UIKit

class NewsDetailsViewController: UIViewController {
    
    var newsInfo: Article?
    var image: UIImage?
    
    @IBOutlet weak var newsDetailsView: NewsDetailInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if newsInfo != nil {
            newsDetailsView.title = newsInfo!.title
            newsDetailsView.content = newsInfo!.content ?? ""
        }
        if let image = image {
            newsDetailsView.image = image
        }
        newsDetailsView.linkButton.addTarget(self, action: #selector(self.handleLinkTapped), for: .touchDown)
        // Do any additional setup after loading the view.
    }
    
    @objc func handleLinkTapped() {
        if let article = newsInfo, let orgiginUrl = article.url, let url = URL(string: orgiginUrl) {
            UIApplication.shared.open(url)
        }
    }

}
