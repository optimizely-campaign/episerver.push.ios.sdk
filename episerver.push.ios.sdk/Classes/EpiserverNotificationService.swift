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

open class EpiserverNotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var notificationContent: UNMutableNotificationContent?

    public override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        notificationContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let notificationContent = notificationContent,
            let imageUrlAsString = request.content.userInfo["image"] as? String,
            let imageUrl = URL(string: imageUrlAsString),
            let attachment = try? UNNotificationAttachment(imageUrl: imageUrl) {
                notificationContent.attachments = [attachment];
                contentHandler(notificationContent)
        }
    }
    
    public override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
            let notificationContent = notificationContent {
            contentHandler(notificationContent)
        }
    }
}

extension UNNotificationAttachment {

    convenience init(imageUrl: URL) throws {
        let data = try Data(contentsOf: imageUrl);
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("NotificationAttachment", isDirectory: true)
            .appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true);
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        let fileName = UUID().uuidString + ".png" // seems like some image extension is required for this to work, although the actual extension does not matter
        let tempFile = tempDirectory.appendingPathComponent(fileName)
        try data.write(to: tempFile)
        try self.init(identifier: fileName, url: tempFile, options: nil)
    }
}
