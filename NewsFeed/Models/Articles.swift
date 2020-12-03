//
//  Article.swift
//  NewsFeed
//
//  Created by Семен Колодин on 01/12/2020.
//  Copyright © 2020 Semen Kolodin. All rights reserved.
//

import Foundation

struct Article: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String?
    let content: String?
    let urlToImage: String?
}
