//
//  OpenLibraryAPI.swift
//  Bookworm
//
//  Created by Joel Boersma on 2/26/21.
//

import Foundation

/* APIs to use
 Books: https://openlibrary.org/dev/docs/api/books
   - Works, Editions, ISBN
 Search: https://openlibrary.org/dev/docs/api/search
 Covers: https://openlibrary.org/dev/docs/api/covers
 */

enum BookCoverSize : String {
    case S, M, L
}

enum BookCoverKey : String {
    case ISBN
    case OLID   // Open Library ID for edition
    case ID     // Cover ID
}

struct OpenLibraryAPI {
    
    struct ApiError: Error {
        var message: String
        
        init(_ message: String) {
            self.message = message
        }
    }
    
    typealias ApiCompletion = ((_ response: [String: Any]?, _ error: ApiError?) -> Void)
    
    static let defaultError = ApiError("Network Error")
    
    static func configuration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 60
        return config
    }
    
    static func ApiCall(endpoint: String, completion: @escaping ApiCompletion) {
        let baseUrl = "https://openlibrary.org"
        
        guard let url = URL(string: baseUrl + endpoint) else {
            print("Wrong url")
            return
        }
        
        let session = URLSession(configuration: configuration())
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { data, response, error in
            guard let rawData = data else {
                print("no raw data")
                DispatchQueue.main.async { completion(nil, defaultError) }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: rawData)
            guard let responseData = jsonData as? [String: Any] else {
                print("no response data")
                DispatchQueue.main.async { completion(nil, defaultError) }
                return
            }
            
            DispatchQueue.main.async {
                if error == nil {
                    completion(responseData, nil)
                } else {
                    print(error ?? "unknown error")
                    completion(nil, defaultError)
                }
            }
            
        }.resume()
    }
    
    static func CoverApiCall(endpoint: String, completion: @escaping ApiCompletion) {
        let baseUrl = "https://covers.openlibrary.org"
        
        guard let url = URL(string: baseUrl + endpoint) else {
            print("Wrong url")
            return
        }
        
        let session = URLSession(configuration: configuration())
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { data, response, error in
            guard let rawData = data else {
                print("no raw data")
                DispatchQueue.main.async { completion(nil, defaultError) }
                return
            }
            
            // JPEG data will need to be converted to UIImage within VC
            let responseData: [String: Any] = ["imageData": rawData]
            
            DispatchQueue.main.async {
                if error == nil {
                    completion(responseData, nil)
                } else {
                    print(error ?? "unknown error")
                    completion(nil, defaultError)
                }
            }
            
        }.resume()
    }
    
    static func unwrapInnerKey(fromDictionary dic: [String: Any], forOuterKey key: String) -> String? {
        guard let objects = dic[key] as? [[String: Any]] else {
            print("couldn't find object array: " + key)
            return nil
        }
        guard let firstObject = objects.first else {
            print("couldn't find first object: " + key)
            return nil
        }
        return firstObject["key"] as? String
    }
    
    
    /// Makes an API call at endpoint and calls completion when finished
    static func generic(_ endpoint: String, completion: @escaping ApiCompletion) {
        let jsonEndpoint = endpoint + ".json"
        ApiCall(endpoint: jsonEndpoint, completion: completion)
    }
    
    static func search(_ searchText: String, completion: @escaping ApiCompletion) {
        let query: String = searchText.replacingOccurrences(of: " ", with: "+")
        print(query)
        ApiCall(endpoint: "/search.json?q=\(query)", completion: completion)
    }
    
    /**
    Use an IBSN, Open Library ID, or a cover ID with book cover size S, M, or L.
    response["imageData"] contains JPEG image data, needs to be converted to a UIImage.
     
    Sample code for using image data:
     
         guard let imageData: Data = response["imageData"] as? Data else {
             print("bad image data")
             return
         }
         let image = UIImage(data: imageData)
         let imageView = UIImageView(image: image)
         self.view.addSubview(imageView)
     */
    static func cover(key: BookCoverKey, value: String, size: BookCoverSize, completion: @escaping ApiCompletion) {
        CoverApiCall(endpoint: "/b/\(key.rawValue)/\(value)-\(size.rawValue).jpg", completion: completion)
    }
    
    static func author(_ key: String, completion: @escaping ApiCompletion) {
        if (key.lowercased().hasPrefix("/authors/ol")) {
            let jsonKey = key + ".json"
            ApiCall(endpoint: jsonKey, completion: completion)
        }
        else {
            print("Error: Invalid path for author")
        }
    }
    
    // may not need this
    static func works(_ key: String, completion: @escaping ApiCompletion) {
        if (key.lowercased().hasPrefix("/works/ol")) {
            let jsonKey = key + ".json"
            ApiCall(endpoint: jsonKey, completion: completion)
        }
        else {
            print("Error: Invalid path for works")
        }
    }
    
    // may not need this
    static func editions(_ key: String, completion: @escaping ApiCompletion) {
        if (key.lowercased().hasPrefix("/books/ol")) {
            let jsonKey = key + ".json"
            ApiCall(endpoint: jsonKey, completion: completion)
        }
        else {
            print("Error: Invalid path for editions")
        }
    }
    
    // Should work with both ISBN-10 and ISBN-13
    static func ISBN(_ isbn: String, completion: @escaping ApiCompletion) {
        ApiCall(endpoint: "/isbn/\(isbn).json", completion: completion)
    }
    static func ISBN(_ isbn: Int, completion: @escaping ApiCompletion) {
        ApiCall(endpoint: "/isbn/\(isbn).json", completion: completion)
    }
    
    /*
     if we want all info...
     - title
     - author
     - cover
     - publishing date
     - edition
     - isbn13
     */
    
    
    static func getAllInfoForISBN(_ isbn: String, bookCoverSize: BookCoverSize, completion: @escaping ApiCompletion) {
        var bookInfo: [String: Any] = [:]
        bookInfo["isbn"] = isbn
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            ISBN(isbn) { isbnResponse, isbnError in
                // title, publish date, isbn13
                if let _isbnError = isbnError {
                    // isbn error
                    print(_isbnError)
                }
                else if let _isbnResponse = isbnResponse {
                    bookInfo["title"] = _isbnResponse["title"]
                    bookInfo["publishDate"] = _isbnResponse["publish_date"]
                    
                    // authors
                    if let authorsJson = _isbnResponse["authors"] as? [[String: Any]] {
                        let authorSemaphore = DispatchSemaphore(value: 0)
                        var authorNames: [String] = []
                        // authors info from this api call
                        for a in authorsJson {
                            if let key = a["key"] as? String {
                                DispatchQueue.global(qos: .userInitiated).async {
                                    author(key) { authorResponse, authorError in
                                        if let _authorError = authorError {
                                            // author error
                                            print(_authorError)
                                        }
                                        else if let _authorResponse = authorResponse,
                                                let authorName = _authorResponse["name"] as? String {
                                            authorNames.append(authorName)
                                        }
                                        authorSemaphore.signal()
                                    }
                                }
                            }
                            else {
                                // with the way the api is laid out, this really shouldn't happen
                                authorSemaphore.signal()
                            }
                        }
                        
                        for _ in authorsJson {
                            authorSemaphore.wait()
                        }
                        
                        semaphore.signal()
                    }
                    else {
                        // can't find authors array from editions json
                        
                        // use works key to get author keys???
                        // not yet
                        
                        semaphore.signal()
                    }
                    
                }
                else {
                    // bad isbn response
                }
                
                semaphore.signal()
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            cover(key: .ISBN, value: isbn, size: bookCoverSize) { coverResponse, error in
                // cover
                if let _error = error {
                    // cover error
                    print(_error)
                }
                else if let coverResponse = coverResponse, let imageData = coverResponse["imageData"] as? Data {
                    bookInfo["imageData"] = imageData
                }
                else {
                    // bad response cover
                }
                
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        semaphore.wait()
        semaphore.wait()
        
        completion(bookInfo, nil)
        
    }
    
    static func getAllInfoForISBN(_ isbn: Int, bookCoverSize: BookCoverSize, completion: @escaping ApiCompletion) {
        getAllInfoForISBN("\(isbn)", bookCoverSize: bookCoverSize, completion: completion)
    }
}


