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

import UIKit
import episerver_push_ios_sdk

@available(iOS 10, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Optional recipient data, that should be inserted into the recipient list during initialization ...
        let additionalRecipientData = [ "email": "max.mustermann@episerver.com", "name": "Mustermann" ]
        
        // Declare the handler that is going to be called when a new push message arrives ...
        func pushMessageReceivedHandler(pushMessage: PushMessage) {
            print("Received: \(pushMessage)")
            print("Title: \(pushMessage.title)")
            print("Body: \(pushMessage.body)")
            print("TrackingUrl: \(pushMessage.trackingUrl)")
            print("Data: \(pushMessage.data)")
            
            // Special handling for the deeplinks contained in the push message ...
            if (pushMessage.data["my-deep-link"] != nil) {
                if let customValue = pushMessage.data["my-deep-link"] as? String {
                    print("Custom value \"my-deep-link\": \"\(customValue)\"")
                } else {
                    print("Custom value is not of type String")
                }
            }
            
            // Opened push messages can be tracked optionally. This produces an "open" in Episerver Campaign.
            pushMessage.trackOpen()
        }
        
        PushMessagingDelegate().initPushMessaging(
            application,
            "insert.your.bundle.identifier", // todo Enter the bundle identifier that you exchanged with Episerver customer support
            "Insert-Your-Auth-Token", // todo Enter the auth token for accessing the Episerver REST-API, that your received from Episerver customer support.
            "optional-recipient-id@episerver.com", // todo Optionally enter the id, that should be inserted in the recipient list connected your app. This may e.g. be an email address or a unique id depending on the settings of the recipient list. You may enter nil if the Firebase recipient token is used as the id of the recipient list.
            additionalRecipientData,
            pushMessageReceivedHandler)
        
        return true
    }
}

