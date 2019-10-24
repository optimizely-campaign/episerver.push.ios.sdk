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

public class Preferences {
    
    public static let shared = Preferences()
    
    private static let DEFAULT_HOST = "push-api.broadmail.de"
    
    private static let HOST = "EPISERVER_HOST"
    private static let FCM_TOKEN = "EPISERVER_FCM_TOKEN"
    private static let BUNDLE_ID = "EPISERVER_BUNDLE_ID"
    private static let AUTH_TOKEN = "EPISERVER_AUTH_TOKEN"
    private static let RECIPIENT_ID = "EPISERVER_RECIPIENT_ID"
    private static let DIRTY = "EPISERVER_DIRTY"
    
    public var dirty: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Preferences.DIRTY)
        }
        set {
            UserDefaults.standard.set(dirty, forKey: Preferences.DIRTY)
        }
    }
    
    public var host: String {
        get {
            return UserDefaults.standard.string(forKey: Preferences.HOST) ?? Preferences.DEFAULT_HOST
        }
        set {
            if newValue != self.host {
                UserDefaults.standard.set(newValue, forKey: Preferences.HOST)
                self.dirty = true
            }
        }
    }
    
    public var fcmToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Preferences.FCM_TOKEN)
        }
        set {
            if newValue != self.fcmToken {
                UserDefaults.standard.set(newValue, forKey: Preferences.FCM_TOKEN)
                self.dirty = true
            }
        }
    }
    
    public var bundleId: String? {
        get {
            return UserDefaults.standard.string(forKey: Preferences.BUNDLE_ID)
        }
        set {
            if newValue != self.bundleId {
                UserDefaults.standard.set(newValue, forKey: Preferences.BUNDLE_ID)
                self.dirty = true
            }
        }
    }
    
    public var authToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Preferences.AUTH_TOKEN)
        }
        set {
            if newValue != self.authToken {
                UserDefaults.standard.set(newValue, forKey: Preferences.AUTH_TOKEN)
                self.dirty = true
            }
        }
    }
    
    public var recipientId: String? {
        get {
            return UserDefaults.standard.string(forKey: Preferences.RECIPIENT_ID)
        }
        set {
            if newValue != self.recipientId {
                UserDefaults.standard.set(newValue, forKey: Preferences.RECIPIENT_ID)
                self.dirty = true
            }
        }
    }
    
    public func resetHost() {
        self.host = Preferences.DEFAULT_HOST
    }
}
