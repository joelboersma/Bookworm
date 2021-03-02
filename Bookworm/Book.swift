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
