//
//  ViewController.swift
//  NewsFeed
//
//  Created by Семен Колодин on 01/12/2020.
//  Copyright © 2020 Semen Kolodin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var vScroll: UIScrollView!
    @IBOutlet weak var verticalStack: UIStackView!
    
    @IBOutlet weak var topHeadline: HeadlinesFeed!
    var topHeadlinesStack: UIStackView! {
        return self.topHeadline.hStack
    }
    private var isAlertShowed = false
    private var isLoading = false {
        didSet {
            if isLoading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
            loadingIndicator.isHidden = !isLoading
        }
    }
    private var topHeadlinesNews: [Article]?
    private var news: [Article]?
    private var newsPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.vScroll.delegate = self
        loadHeadlinesNews()
        loadMoreNews()
    }
    
    private func loadHeadlinesNews() {
        NewsApiService().getArticles(from: .topHeadLines(country: "us"), handleError: {[weak self] _ in self?.showErrorAlert()}, handleSuccess: {[weak self] in self?.placeHeadlinesNews($0.articles)})
    }
    
    private func loadMoreNews() {
        if !self.isLoading {
            self.isLoading = true
            NewsApiService().getArticles(from: .everything(source: "the-verge"), page: newsPage, handleError: {[weak self] _ in self?.showErrorAlert()}, handleSuccess: {[weak self] in self?.placeNews($0.articles)})
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let heigth = scrollView.frame.height
        if (contentHeight - (offsetY + heigth) < 0.1 * contentHeight  ) && !isLoading {
            loadMoreNews()
        }
    }
    
    private func showErrorAlert() {
        DispatchQueue.main.sync {
            if !self.isAlertShowed {
                self.isAlertShowed = true
                let alert = UIAlertController(title: "Error!", message: "Network error occured, please try later.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {[weak self] _ in self?.isAlertShowed = false}))

                self.present(alert, animated: true)
                
            }
        }
    }
    
    @objc private func handleNewsItemTapped(_ sender: UITapGestureRecognizer) {
        if let view = sender.view, news != nil{
            var image: UIImage?
            var article: Article?
            switch type(of: view) {
            case is NewsPreviewRow.Type:
                image = (view as! NewsPreviewRow).image.image
                article = self.news?[view.tag]
            case is NewsPreview.Type:
                image = (view as! NewsPreview).image.image
                article = self.topHeadlinesNews?[view.tag]
            default:
                return
            }
            performSegue(withIdentifier: "ShowNewsDetails", sender: (article: article, image: image))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? NewsDetailsViewController, let sender = sender as? (article: Article?, image: UIImage?) {
            controller.newsInfo = sender.article
            if let image = sender.image {
                controller.image = image
            }
        }
    }
    
    private func placeNews(_ news: [Article]) {
        var offset = 0
        if self.news != nil {
            offset = self.news!.count
            self.news!.append(contentsOf: news)
        } else {
            self.news = news
        }
        DispatchQueue.main.sync {
            for it in news.indices {
                let newsPreview = NewsPreviewRow(frame: CGRect(x: 0, y: 0, width: 150, height: 300))
                newsPreview.title.text = news[it].title
                newsPreview.descriptionText.text = news[it].description
                if let urlToImage = news[it].urlToImage, let url = URL(string: urlToImage) {
                    newsPreview.image.load(url: url)
                }
                newsPreview.addTapGesture(target: self, action: #selector(self.handleNewsItemTapped(_:)))
                newsPreview.tag = offset + it
                self.verticalStack.insertArrangedSubview(newsPreview, at: max(0, self.verticalStack.subviews.count - 1))
            }
            self.isLoading = false
            self.newsPage += 1
        }
    }
    
    private func placeHeadlinesNews(_ news: [Article]) {
        topHeadlinesNews = news
        DispatchQueue.main.sync {
            for it in self.topHeadlinesNews!.indices {
                let newsPreview = NewsPreview(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                newsPreview.translatesAutoresizingMaskIntoConstraints = false
                newsPreview.autoresizingMask = [.flexibleWidth]
                newsPreview.title.text = self.topHeadlinesNews![it].title
                if let urlToImage = self.topHeadlinesNews![it].urlToImage, let url = URL(string: urlToImage) {
                    newsPreview.image.load(url: url)
                }
                newsPreview.addTapGesture(target: self, action: #selector(self.handleNewsItemTapped(_:)))
                newsPreview.tag = it
                self.topHeadlinesStack.addArrangedSubview(newsPreview)
                newsPreview.heightAnchor.constraint(equalTo: self.topHeadlinesStack.safeAreaLayoutGuide.heightAnchor, multiplier: 1).isActive = true
            }
        }
    }
}

protocol TapableNewsPreview {
    func addTapGesture(target: UIGestureRecognizerDelegate, action: Selector)
}

extension TapableNewsPreview where Self: UIView {
    func addTapGesture(target: UIGestureRecognizerDelegate, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        tapGesture.delegate = target
        self.addGestureRecognizer(tapGesture)
    }
}

extension NewsPreview: TapableNewsPreview {}
extension NewsPreviewRow: TapableNewsPreview {}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

