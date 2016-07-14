//
//  FileProvider.swift
//  PickerFileProvider
//
//  Created by Dong on 16/7/10.
//  Copyright © 2016年 Dave Krawczyk. All rights reserved.
//

import UIKit

class FileProvider: NSFileProviderExtension {

    var fileCoordinator: NSFileCoordinator {
        let fileCoordinator = NSFileCoordinator()
        fileCoordinator.purposeIdentifier = self.providerIdentifier()
        return fileCoordinator
    }

    override init() {
        super.init()
        
        self.fileCoordinator.coordinateWritingItemAtURL(self.documentStorageURL(), options: NSFileCoordinatorWritingOptions(), error: nil, byAccessor: { newURL in
            // ensure the documentStorageURL actually exists
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(newURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // Handle error
            }
        })
    }

    override func providePlaceholderAtURL(url: NSURL, completionHandler: ((error: NSError?) -> Void)?) {
        // Should call writePlaceholderAtURL(_:withMetadata:error:) with the placeholder URL, then call the completion handler with the error if applicable.
        let fileName = url.lastPathComponent!
    
        let placeholderURL = NSFileProviderExtension.placeholderURLForURL(self.documentStorageURL().URLByAppendingPathComponent(fileName))
    
        // TODO: get file size for file at <url> from model
        let fileSize = 0
        let metadata = [NSURLFileSizeKey: fileSize]
        do {
            try NSFileProviderExtension.writePlaceholderAtURL(placeholderURL, withMetadata: metadata)
        } catch {
            // Handle error
        }

        completionHandler?(error: nil)
    }

    override func startProvidingItemAtURL(url: NSURL, completionHandler: ((error: NSError?) -> Void)?) {
        // Should ensure that the actual file is in the position returned by URLForItemWithIdentifier, then call the completion handler
        
        guard let fileData = NSData(contentsOfURL: url) else {
            // NOTE: you would generate an NSError to supply to the completionHandler
            completionHandler?(error: nil)
            return
        }

        do {
            _ = try fileData.writeToURL(url, options: NSDataWritingOptions())
        } catch let error as NSError {
            // Handle error
            print("error writing file to URL")
            completionHandler?(error: error)
        }
    }


    override func itemChangedAtURL(url: NSURL) {
        // Called at some point after the file has changed; the provider may then trigger an upload

        // TODO: mark file at <url> as needing an update in the model; kick off update process
        NSLog("Item changed at URL %@", url)
    }

    override func stopProvidingItemAtURL(url: NSURL) {
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.

        do {
            _ = try NSFileManager.defaultManager().removeItemAtURL(url)
        } catch {
            // Handle error
        }
        self.providePlaceholderAtURL(url, completionHandler: { error in
            // TODO: handle any error, do any necessary cleanup
        })
    }

}
