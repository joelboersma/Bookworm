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
    
    static var baseUrl = "https://openlibrary.org"
    static let defaultError = ApiError(response: [:])
    
    static func configuration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 60
        return config
    }
    
    static func ApiCall(endpoint: String, completion: @escaping ApiCompletion) {
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
                    print(error)
                    completion(nil, ApiError(response: responseData))
                }
            }
        }.resume()
    }
    
    
    /// Makes an API call at endpoint and calls completion when finished
    static func generic(_ endpoint: String, completion: @escaping ApiCompletion) {
        ApiCall(endpoint: endpoint, completion: completion)
    }
    
    static func search(_ searchText: String, completion: @escaping ApiCompletion) {
        let query: String = searchText.replacingOccurrences(of: " ", with: "+")
        print(query)
        ApiCall(endpoint: "/search.json?q=\(query)", completion: completion)
    }
    
    static func author(_ key: String, completion: @escaping ApiCompletion) {
        if (key.lowercased().hasPrefix("/authors/ol")) {
            ApiCall(endpoint: key, completion: completion)
        }
        else {
            print("Error: Invalid path for author")
        }
    }
    
    // may not need this
    static func works(_ key: String, completion: @escaping ApiCompletion) {
        if (key.lowercased().hasPrefix("/works/ol")) {
            ApiCall(endpoint: key, completion: completion)
        }
        else {
            print("Error: Invalid path for works")
        }
    }
    
    // may not need this
    static func editions(_ key: String, completion: @escaping ApiCompletion) {
        if (key.lowercased().hasPrefix("/books/ol")) {
            ApiCall(endpoint: key, completion: completion)
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
}

