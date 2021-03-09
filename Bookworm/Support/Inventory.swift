//
//  Inventory.swift
//  Bookworm
//
//  Created by Christina Luong on 3/9/21.
//

import Foundation
class InventoryBook {
    let title: String
    let isbn: String
    let authors: [String]
    var publishDate: String
    let bookCover: String
    let bookCoverData: Data
    let condition: String
    var edition: String? = ""


    init(title: String, isbn: String, authors: [String], publishDate: String, bookCover: String, bookCoverData: Data, condition: String) {
        self.title = title
        self.isbn = isbn
        self.authors = authors
        self.publishDate = publishDate
        self.bookCover = bookCover
        self.bookCoverData = bookCoverData
        self.condition = condition
    }
}


