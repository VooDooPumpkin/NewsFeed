//
//  NewsApiService.swift
//  NewsFeed
//
//  Created by Семен Колодин on 01/12/2020.
//  Copyright © 2020 Semen Kolodin. All rights reserved.
//

import Foundation

struct NewsResponse: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]
}

struct FailedResponse: Codable {
    let status: String?
    let code: String?
    let message: String?
}

enum NewsEndpoint {
    case topHeadLines (country: String)
    case everything (source: String)
    
    func path() -> String {
        switch self {
        case .topHeadLines:
            return "/top-headlines"
        case .everything:
            return "/everything"
        }
    }
}

class NewsApiService {
    static private var baseUrl = "https://newsapi.org/v2"
    static private var apiKey = "338778baef424c439432e93f1fe91274"
    
    
    func getArticles(from endpoint: NewsEndpoint, perPage: Int = 10, page: Int = 1,  handleError: @escaping (String) -> Void, handleSuccess: @escaping (NewsResponse) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        var urlComponents: URLComponents?
        urlComponents = URLComponents(string: NewsApiService.baseUrl + endpoint.path())
        guard urlComponents != nil else {
            handleError("Incorrect url")
            return
        }
        
        urlComponents!.queryItems = [URLQueryItem]()
        urlComponents!.queryItems?.append(URLQueryItem(name: "apiKey", value: NewsApiService.apiKey))
        urlComponents!.queryItems?.append(URLQueryItem(name: "pageSize", value: String(perPage)))
        urlComponents!.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
        switch endpoint {
        case let .topHeadLines(country):
            urlComponents!.queryItems?.append(URLQueryItem(name: "country", value: country))
        case let .everything(source):
            urlComponents!.queryItems?.append(URLQueryItem(name: "sources", value: source))
        }
        
        
        if let url = urlComponents?.url {
            dataTask = defaultSession.dataTask(with: url) { data, resp, error in
                if let error = error {
                    handleError(error.localizedDescription)
                    return
                }
                if let resp = resp as? HTTPURLResponse, let data = data {
                    let decoder = JSONDecoder()
                    if resp.statusCode == 200 {
                        if let json = try? decoder.decode(NewsResponse.self, from: data) {
                            handleSuccess(json)
                            return
                        }
                    } else {
                        if let error = try? decoder.decode(FailedResponse.self, from: data) {
                            handleError(error.message ?? "")
                            return
                        }
                    }
                }
            }
        }
        dataTask?.resume()
    }
}
