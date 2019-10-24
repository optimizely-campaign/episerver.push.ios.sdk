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

import UserNotifications
import FirebaseCore
import FirebaseMessaging

@available(iOS 10, *)
open class PushMessagingDelegate: UIResponder {
    
    var additionalRecipientData: [String: Any] = [:]
    var pushMessageReceivedHandler: ((PushMessage) -> Void)? = nil
    
    /**
     Initializes Episerver push messaging.
     
     - parameters:
        - application: The UIApplication received in the application method as a method argument.
        - bundleId: The bundle identifier of your application.
                    This is one of the values you should have passed to Episerver Customer Success.
                    In the Android world this would be the package name of your application.
        - authToken: The authentication token received from Episerver Customer Success.
                     This is used to call to the Episerver REST-API.
        - recipientId: The optional recipient id of the owner of the phone, where the application is installed.
                       This value may be nil depending on the configuration of the recipient list.
        - additionalRecipientData: Optional additional data of the recipient.
                                   This may be nil or a map where the keys correspond to the fields of your recipient list.
                                   The type of the values should match the type of the corresponding fields of the recipient list or simply be of type String
                                   which will be converted to the correct type on the receiver side.
        - pushMessageReceivedHandler: This callback will be called any time a push message arrives. Here you can react to the arrival of the push messge.
     
     
      This method is supposed to be called in the application method of the UIApplication.
      If necessary it fetches a registration token from Firebase.
      The token is sent to Episerver along with the recipientId and additionalRecipientData,
      which subscribes the recipient to the recipient list that is configured for the application.
      Note, that the subscription is not necessarily performed every time this method is called,
      but only, if the registration token received from Firebase has changed since the last call.
     */
    public func initPushMessaging(_ application: UIApplication, _ bundleId: String, _ authToken: String, _ recipientId: String?, _ additionalRecipientData: [String: Any]?, _ pushMessageReceivedHandler: @escaping (PushMessage) -> Void) {
        Preferences.shared.bundleId = bundleId
        Preferences.shared.authToken = authToken
        if let recipientId = recipientId {
            Preferences.shared.recipientId = recipientId
        }
        if let additionalRecipientData = additionalRecipientData {
            self.additionalRecipientData = additionalRecipientData
        }
        self.pushMessageReceivedHandler = pushMessageReceivedHandler
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        print("initialized push messaging")
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

@available(iOS 10, *)
extension PushMessagingDelegate : UNUserNotificationCenterDelegate {
    
    // The method will be called on the delegate only if the application is in the foreground.
    // If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented.
    // The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list.
    // This decision should be based on whether the information in the notification is otherwise visible to the user.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("received message while app is in foreground")
        self.pushMessageReceivedHandler?(PushMessage(notification)) ?? print("no handler registered")
        // Change this to your preferred presentation option
        // completionHandler([]) would not present the notification
        completionHandler([.alert, .badge, .sound])
    }
    
    // The method will be called on the delegate when the user responded to a notification displayed by opening the application,
    // dismissing the notification or choosing a UNNotificationAction.
    // The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("user responded to message")
        self.pushMessageReceivedHandler?(PushMessage(response.notification)) ?? print("no handler registered")
        completionHandler()
    }
}

@available(iOS 10, *)
extension PushMessagingDelegate : MessagingDelegate {
    
    fileprivate func register(_ authToken: String, _ bundleId: String, _ fcmToken: String) {
        // Send Firebase token to Episerver ...
        let host = Preferences.shared.host
        print("Sending Firebase token to Episerver host \(host) ...")
        let url = URL(string: "https://" + host + "/rest/push/register/v2?authenticationToken=" + authToken)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var json: [String: Any] = [
            "recipientId": fcmToken,
            "packageName": bundleId,
            "additionalRecipientData": self.additionalRecipientData,
        ]
        
        if let recipientId = Preferences.shared.recipientId {
            json["oldRecipientId"] = recipientId
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
            }
            if !(200..<300).contains(response.statusCode) { // check for http errors
                print("Error: Failed to send Firebase token to Episerver. Received statusCode \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            Preferences.shared.dirty = false
        }
        
        task.resume()
    }
    
    // This callback is fired at each app startup and whenever a new token is generated.
    open func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase token: \(fcmToken)")
        Preferences.shared.fcmToken = fcmToken
        if Preferences.shared.dirty {
            // send token to Episerver ...
            if let authToken = Preferences.shared.authToken {
                if let bundleId = Preferences.shared.bundleId {
                    register(authToken, bundleId, fcmToken)
                } else {
                    print("Error: Cannot send Firebase token to Episerver, because bundle id is not set.")
                }
            } else {
                print("Error: Cannot send Firebase token to Episerver, because auth token is not set.")
            }
        }
    }
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

