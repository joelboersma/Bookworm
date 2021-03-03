//
//  Book.swift
//  Bookworm
//
//  Created by Joel Boersma on 3/1/21.
//

import Foundation

class Book {
    /*
     if we want all info...
     - title
     - author
     - cover
     - publishing date
     - edition??? (isbn already kinda does that)
     - isbn13
     */
    
    let title: String
    let isbn: String
    let authors: [String]
    
    var publishDate: String?
    var coverImageS: Data? = nil
    var coverImageM: Data? = nil
    var coverImageL: Data? = nil
    
    init(title: String, isbn: String, authors: [String], publishDate: String?) {
        self.title = title
        self.isbn = isbn
        self.authors = authors
        self.publishDate = publishDate
    }
}

class BookCell {
    /*
     if we want all info...
     - title
     - author
     - condition
     - location
     - buyer/seller
     - post date
     - cover
     - publishing date
     - edition??? (isbn already kinda does that)
     - isbn13
     */
    
    let title: String
    //let isbn: String
    //let authors: [String]
    let condition: String
    let location: String
    let buyerSeller: String
    let postDate: String
    let bookCover: String
    let userDescription: String

    //var publishDate: String?
    //var coverImage: Data? = nil
    
    
    init(title: String, condition: String, location: String, buyerSeller: String, postDate: String, bookCover: String, userDescription: String) {
        self.title = title
        self.condition = condition
        self.location = location
        self.buyerSeller = buyerSeller
        self.postDate = postDate
        self.bookCover = bookCover
        self.userDescription = userDescription
    }
    
}
