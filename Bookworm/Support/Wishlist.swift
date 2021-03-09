//
//  Wishlist.swift
//  Bookworm
//
//  Created by Christina Luong on 3/8/21.
//

import Foundation
class WishListBook {
    let title: String
    let isbn: String
    let authors: [String]
    var publishDate: String
    let bookCover: String
    let bookCoverData: Data
    var edition: String? = ""
 

    init(title: String, isbn: String, authors: [String], publishDate: String, bookCover: String, bookCoverData: Data) {
        self.title = title
        self.isbn = isbn
        self.authors = authors
        self.publishDate = publishDate
        self.bookCover = bookCover
        self.bookCoverData = bookCoverData
    }
}

//class WishListCell{
//    let title: String
//    let authors: String
//    let bookCoverData: Data
//
//    init(title: String, authors: String, bookCoverData: Data) {
//
//        self.title = title
//        self.authors = authors
//        self.bookCoverData = bookCoverData
//    }
//}
