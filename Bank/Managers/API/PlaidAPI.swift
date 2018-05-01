//
//  PlaidAPI.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

class PlaidAPI {
    let rootServerURL: String, clientID: String, secret: String
    let debugEnabled = true
    
    init(rootServerURL: String, clientID: String, secret: String) {
        self.rootServerURL = rootServerURL
        self.clientID = clientID
        self.secret = secret
    }
    
    func makeAuthedRequest<T: PlaidResponse>(to endpoint: String, body: [String: Any] = [:], type: T.Type, completionHandler: @escaping (T?, Error?) -> Void) {
        guard let accessToken = PlaidManager.shared.accessToken else { completionHandler(nil, nil); return }
        var body = body
        body["client_id"] = clientID
        body["secret"] = secret
        body["access_token"] = accessToken
        makeRequest(to: endpoint, body: body, type: type, completionHandler: completionHandler)
    }
    
    func makeRequest<T: PlaidResponse>(to endpoint: String, body: [String: Any], type: T.Type, completionHandler: @escaping (T?, Error?) -> Void) {
        guard let url = URL(string: rootServerURL + endpoint) else { completionHandler(nil, nil); return }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil, let data = data else { completionHandler(nil, error); return }
            if self.debugEnabled {
                print("Request to:", endpoint, "Received:", (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: AnyObject] ?? "non-JSON response")
            }
            if let response = ErrorResponse.decode(from: data) {
                completionHandler(nil, PlaidError(response: response))
                return
            }
            guard let response = type.decode(from: data) else { completionHandler(nil, error); return }
            completionHandler(response, nil)
        }.resume()
    }
}
