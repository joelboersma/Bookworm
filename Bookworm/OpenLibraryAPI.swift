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
        var code: String
        
        init(response: [String: Any]) {
            self.message = (response["error_message"] as? String) ?? "Network error"
            self.code = (response["error_code"] as? String) ?? "network_error"
        }
    }
    
    typealias ApiCompletion = ((_ response: [String: Any]?, _ error: ApiError?) -> Void)
    
    static let defaultError = ApiError(response: [:])
    
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
                    completion(nil, ApiError(response: responseData))
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
                    completion(nil, ApiError(response: responseData))
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
        
        ISBN(isbn) { isbnResponse, error in
            // title, publish date, isbn13
            if let unwrappedError = error {
                completion(bookInfo, unwrappedError)
                return
            }
            
            guard let isbnResponse = isbnResponse else {
                print("bad response ISBN")
                completion(bookInfo, ApiError(response: [:]))
                return
            }
            
            bookInfo["title"] = isbnResponse["title"]
            bookInfo["publishDate"] = isbnResponse["publish_date"]
            
            guard let authorKey = unwrapInnerKey(fromDictionary: isbnResponse, forOuterKey: "authors") else {
                print("couldn't get key for author")
                completion(bookInfo, ApiError(response: [:]))
                return
            }
            
            author(authorKey) { authorResponse, error in
                // author
                if let unwrappedError = error {
                    completion(bookInfo, unwrappedError)
                    return
                }
                guard let authorResponse = authorResponse else {
                    print("bad response author")
                    completion(bookInfo, ApiError(response: [:]))
                    return
                }
                
                guard let authorName = authorResponse["name"] else {
                    print("no author")
                    completion(bookInfo, ApiError(response: [:]))
                    return
                }
                bookInfo["author"] = authorName
                
                cover(key: .ISBN, value: isbn, size: bookCoverSize) { coverResponse, error in
                    // cover
                    if let unwrappedError = error {
                        completion(bookInfo, unwrappedError)
                        return
                    }
                    guard let coverResponse = coverResponse else {
                        print("bad response cover")
                        completion(bookInfo, ApiError(response: [:]))
                        return
                    }
                    print(coverResponse)
                    
                    guard let imageData = coverResponse["imageData"] as? Data else {
                        print("bad cover image data")
                        completion(bookInfo, ApiError(response: [:]))
                        return
                    }
                    
                    bookInfo["imageData"] = imageData
                    
                    completion(bookInfo, nil)
                }
            }
        }
    }
    
    static func getAllInfoForISBN(_ isbn: Int, bookCoverSize: BookCoverSize, completion: @escaping ApiCompletion) {
        getAllInfoForISBN("\(isbn)", bookCoverSize: bookCoverSize, completion: completion)
    }
}
