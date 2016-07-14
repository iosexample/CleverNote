/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

enum DocumentError : ErrorType {
  case RuntimeError(String)
}

class Note: UIDocument {

  // MARK: - Static-Properties
  static let fileExtension = "txt"

  static let appGroupIdentifier = "group.com.magicalboy.CleverNote"
  
  // MARK: - Properties
  var documentText: String?
  var title: String!

  // MARK: - Overridden Instance Methods
  override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
    guard let data = contents as? NSData where contents.length > 0 else { return }

    documentText = String(data: data, encoding: NSUTF8StringEncoding)
  }
  
  override func contentsForType(typeName: String) throws -> AnyObject {
    documentText = documentText ?? ""

    guard let documentData = documentText?.dataUsingEncoding(NSUTF8StringEncoding) else {
      throw DocumentError.RuntimeError("Unable to convert String to data")
    }

    return documentData
  }
}

// MARK: - Static-Methods
extension Note {

  // Creates a note with a title/filename
  static func createNote(noteTitle: String) -> Note? {
    guard let fileURL = fileUrlForDocumentNamed(noteTitle) else { return nil }

    let noteDocument = Note(fileURL: fileURL)
    noteDocument.title = noteTitle

    return noteDocument
  }

  // Given an array of filenames, return an array of notes from the file system
  static func arrayOfNotesFromArrayOfFileNames(fileNames: [String]) -> [Note] {
    var notes: [Note] = []
    
    for fileName in fileNames {
      let noteTitle = fileName.stringByReplacingOccurrencesOfString(".txt", withString: "")
      
      guard let note = createNote(noteTitle) else { continue }
      notes.append(note)
    }
    return notes
  }
  
  // Returns all notes in file system
  static func getAllNotesInFileSystem() -> [Note] {
    guard let localDocumentsDirectory = appGroupContainerURL(),
      localDocumentsDirectoryPath = localDocumentsDirectory.path else {
        return []
    }

    let localDocuments: [AnyObject]?
    do {
      localDocuments = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(localDocumentsDirectoryPath)
    } catch _ {
      print("error accessing contents from directory")
      localDocuments = nil
    }
    
    guard let fileNames = localDocuments as? [String] else { return[] }

    return arrayOfNotesFromArrayOfFileNames(fileNames)
  }
  
  // Returns the file URL for the file to be saved at
  static func fileUrlForDocumentNamed(name: String) -> NSURL? {
    guard let baseURL = appGroupContainerURL() else { return nil }

    let protectedName: String
    if name.isEmpty {
      protectedName = "Untitled"
    } else {
      protectedName = name
    }

    return baseURL.URLByAppendingPathComponent(protectedName)
      .URLByAppendingPathExtension(fileExtension)
  }
  
  static func appGroupContainerURL() -> NSURL? {
    let fileManager = NSFileManager.defaultManager()
    guard let groupPath = fileManager.containerURLForSecurityApplicationGroupIdentifier(appGroupIdentifier)
      else {
        return nil
    }
    
    let storagePathUrl = groupPath.URLByAppendingPathComponent("File Provider Storage")
    guard let storagePath = storagePathUrl.path else {
      return nil
    }
    
    if !fileManager.fileExistsAtPath(storagePath) {
      do {
        try fileManager.createDirectoryAtPath(storagePath, withIntermediateDirectories: false,
                                              attributes: nil)
      }
      catch let error as NSError {
        print("error creating filepath: \(error)")
        return nil
      }
    }
    
    print(storagePathUrl)
    return storagePathUrl
  }
  
  
//  static func localDocumentsDirectoryURL() -> NSURL? {
//    guard let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else { return nil }
//    
//    let localDocumentsDirectoryURL = NSURL(fileURLWithPath: documentPath)
//    print(localDocumentsDirectoryURL)
//    return localDocumentsDirectoryURL
//  }
}


