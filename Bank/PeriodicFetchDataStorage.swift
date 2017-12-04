//
//  PeriodicFetchDataStorage.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

class PeriodicFetchDataStorage {
    static let shared = PeriodicFetchDataStorage()
    private init() {}
    
    let institutions = PeriodicFetchDataStore<String, InstitutionResponse>(name: "institutions", endpoint: "institutions/get", requestBody: ["client_id": PlaidManager.shared.info.clientID, "secret": PlaidManager.shared.info.secret, "count": 500, "offset": 0, "options": ["products": ["transactions"]]]) { $0.institutions.map { ($0.id, $0.name) } }
    
    func setup() {
        // Needed to initialize itself, as it is static and therefore lazy, meaning it's variables (the stores) won't be initialized properly.
        print("Set up periodic fetch data storage for usage.")
    }
}

class PeriodicFetchDataStore<Element, Response: PlaidResponse> {
    private let name: String, endpoint: String, requestBody: [String: Any], transform: (Response) -> [(AnyHashable, Element)]
    private var isFetching = false
    private var data: ([AnyHashable: Element], Date)? {
        didSet { NotificationCenter.default.post(name: dataChangedNotification, object: nil) }
    }
    
    init(name: String, endpoint: String, requestBody: [String: Any] = [:], transform: @escaping (Response) -> [(AnyHashable, Element)]) {
        self.name = name
        self.endpoint = endpoint
        self.requestBody = requestBody
        self.transform = transform
        self.loadFromFile()
        self.fetchIfRequired()
    }
    
    var dataChangedNotification: Notification.Name {
        return Notification.Name(rawValue: "PeriodicFetchDataStore-\(name)-DataChangedNotificationName")
    }
    
    // MARK: - Accessing
    
    /// Get the value for the specified key, if loaded and existant.
    func value(for key: AnyHashable) -> Element? {
        return data?.0[key]
    }
    
    /// Whether or not the data store currently has any data.
    var hasData: Bool {
        return data != nil
    }
    
    // MARK: - Loading, Fetching, and Saving
    
    /// Load the existing data from file.
    private func loadFromFile() {
        guard FileManager.default.fileExists(atPath: saveDataURL.path), let json = try? Data(contentsOf: saveDataURL), let decoded = (try? JSONSerialization.jsonObject(with: json, options: [])) as? [String: Any], let data = decoded["data"] as? [AnyHashable: Element], let dateTS = decoded["date"] as? TimeInterval else { return }
        self.data = (data, Date(timeIntervalSinceReferenceDate: dateTS))
    }
    
    /// Check if the periodic data store needs to be fetched again from the server, and do so if necessary.
    func fetchIfRequired() {
        guard requiresFetch else { return }
        print("We need new data from the server for \(name) periodic data store.")
        fetch()
    }
    
    /// Whether or not the data needs to be fetched again from the server.
    private var requiresFetch: Bool {
        // Check if we have data.
        if let (_, date) = data, let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour {
            // If we do, require fetch if its over 24 hours old.
            return diff > 24
        }
        return true
    }
    
    /// Save the existing data to file.
    private func saveToFile() {
        guard let (data, date) = data else { return }
        print("Saving \(name) periodic data store to file...")
        let dict = ["data": data, "date": date.timeIntervalSinceReferenceDate] as [String: Any]
        guard let json = try? JSONSerialization.data(withJSONObject: dict, options: []) else { return }
        if (try? json.write(to: saveDataURL)) != nil {
            print("Saved periodic data store \(name) to file.")
        } else {
            print("Couldn't save periodic data store \(name) to file.")
        }
    }
    
    /// Start fetching this store's data from the server.
    func fetch() {
        func makeRequest(index: Int = 0, data: [(AnyHashable, Element)] = [], completionHandler: @escaping ([(AnyHashable, Element)]) -> Void) {
            var data = data
            print("Starting fetch of data for \(name) periodic data store (index: \(index))...")
            var body = requestBody
            body["offset"] = (body["offset"] as? Int ?? 0) + index * (body["count"] as? Int ?? 1)
            PlaidManager.shared.api.makeRequest(to: endpoint, body: requestBody, type: Response.self) { (response, error) in
                guard error == nil, let response = response else {
                    print("Couldn't fetch data for \(self.name) periodic data store. (index: \(index)):", error?.localizedDescription ?? "no error")
                    return
                }
                data.append(contentsOf: self.transform(response))
                if let total = (response as? PaginatingPlaidResponse)?.total, data.count < total {
                    // If response is paginating and we don't have all the data yet
                    makeRequest(index: index + 1, data: data, completionHandler: completionHandler)
                    return
                }
                completionHandler(data)
            }
        }
        if isFetching { return }
        isFetching = true
        makeRequest { (transformed) in
            var data = [AnyHashable: Element]()
            transformed.forEach { data[$0.0] = $0.1 }
            self.data = (data, Date())
            print("Fetched and temporarily stored fetch data for \(self.name) periodic data store.")
            self.saveToFile()
        }
    }
    
    // MARK: - Convenient Computed Variables
    
    /// The URL at which this store's data is saved at periodically for use later on.
    private var saveDataURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("stored_\(name).json")
    }
}
