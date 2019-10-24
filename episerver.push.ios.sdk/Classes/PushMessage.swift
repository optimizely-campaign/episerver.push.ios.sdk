//
//  Copyright (c) 2019 Episerver GmbH.
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UserNotifications

@available(iOS 10, *)
public class PushMessage: CustomStringConvertible {
    
    static var MUTEX: pthread_mutex_t = pthread_mutex_t()
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    public let data: [AnyHashable: Any]
    public let id: String
    public let title: String
    public let body: String
    public let trackingUrl: String
    public let description: String
    var openSuccessfullyTracked: Bool = false
    
    init(_ notification: UNNotification) {
        self.data = notification.request.content.userInfo
        self.id = data["gcm.message_id"] as! String
        let aps = data["aps"] as! Dictionary<String, Any>
        let alert = aps["alert"] as! Dictionary<String, Any>
        self.title = alert["title"] as! String
        self.body = alert["body"] as! String
        self.trackingUrl = data["bm_tracking_url"] as! String
        self.description = "PushMessage(id=\"\(self.id)\",title=\"\(self.title)\",body=\"\(self.body)\")"
    }
    
    public func trackOpen() {
        // The network request might fail if we did this in the foreground
        // while the app was in the background.
        // Therefore we schedule this to be executed in the background.
        DispatchQueue.global(qos: .userInitiated).async {
            pthread_mutex_lock(&PushMessage.MUTEX)
            defer { pthread_mutex_unlock(&PushMessage.MUTEX) }
            if (self.openSuccessfullyTracked || self.id == UserDefaults.standard.string(forKey: "lastTrackedPushMessageId")) {
                print("open already tracked for \(self)")
            } else {
                var httpsUrl = self.trackingUrl
                if httpsUrl.starts(with: "http://") {
                    let index = httpsUrl.index(httpsUrl.startIndex, offsetBy: 4)
                    httpsUrl = "https" + String(httpsUrl[index...])
                }
                let url = URL(string: httpsUrl)!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let response = response as? HTTPURLResponse,
                        error == nil else {
                            print(error?.localizedDescription ?? "Error: Failed to track open.")
                            return
                    }
                    if !(200..<300).contains(response.statusCode) { // check for http errors
                        print("Error: Failed to track open. Received statusCode \(response.statusCode)")
                        print("response = \(response)")
                        return
                    }
                    print("tracked open successfully for \(self)")
                    self.openSuccessfullyTracked = true
                    UserDefaults.standard.set(self.id, forKey: "lastTrackedPushMessageId")
                }
                task.resume()
            }
        }
    }
}

extension PushMessage: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var map: [String:String] = [:]
        for (k,v) in data {
            // Since this method is used to display the message to the user, we only encode the parts of the data that are of type String.
            if let k = k as? String,
                let v = v as? String {
                map[k] = v
            }
        }
        try container.encode(map, forKey: .data)
    }
}
