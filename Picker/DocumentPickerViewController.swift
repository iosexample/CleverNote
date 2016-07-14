//
//  DocumentPickerViewController.swift
//  Picker
//
//  Created by Dong on 16/7/10.
//  Copyright © 2016年 Dave Krawczyk. All rights reserved.
//

import UIKit

class DocumentPickerViewController: UIDocumentPickerExtensionViewController {
    lazy var fileCoordinator: NSFileCoordinator = {
        let fileCoordinator = NSFileCoordinator()
        fileCoordinator.purposeIdentifier = self.providerIdentifier
        return fileCoordinator
    }()
    
    var notes = [Note]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var extensionWarningLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        notes = Note.getAllNotesInFileSystem()
        print("notes' count:%d", notes.count)
        
        tableView.reloadData()
    }
    

    override func prepareForPresentationInMode(mode: UIDocumentPickerMode) {
        // If the source URL does not have a path extension supported
        // show the extension warning label. Should only apply in
        // Export and Move services
        if let sourceURL = originalURL, pathExtension = sourceURL.pathExtension where pathExtension != Note.fileExtension {
            confirmButton.hidden = true
            extensionWarningLabel.hidden = false
        }
        
        switch mode {
        case .ExportToService:
            // Show confirmation button
            confirmButton.setTitle("Export to CleverNote", forState: .Normal)
        case .MoveToService:
            // Show confirmation button
            confirmButton.setTitle("Move to CleverNote", forState: .Normal)
        case .Open:
            //Show file list
            confirmView.hidden = true
        case .Import:
            //Show file list
            confirmView.hidden = true
        }
    }
}

// MARK: - UITableViewDataSource
extension DocumentPickerViewController: UITableViewDataSource {
    // MARK: - CellIdentifiers
    private enum CellIdentifier: String {
        case NoteCell = "noteCell"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.NoteCell.rawValue,
                                                               forIndexPath: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DocumentPickerViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let note = notes[indexPath.row]
        dismissGrantingAccessToURL(note.fileURL)
    }
}

// MARK: - IBActions
extension DocumentPickerViewController {
    
    @IBAction func confirmButtonTapped(sender: AnyObject) {
        guard let sourceURL = originalURL else {
            return
        }
        
        switch documentPickerMode {
            
        // 1.
        case .MoveToService, .ExportToService:
            guard let fileName = sourceURL.URLByDeletingPathExtension?.lastPathComponent,
                destinationURL = Note.fileUrlForDocumentNamed(fileName) else {
                    return
            }
            
            // 2.
            fileCoordinator.coordinateReadingItemAtURL(sourceURL,
                                                       options: .WithoutChanges,
                                                       error: nil,
                                                       byAccessor: { [weak self] newURL in
                                                        
                                                        // 3.
                                                        do {
                                                            try NSFileManager.defaultManager().copyItemAtURL(sourceURL, toURL: destinationURL)
                                                            
                                                            // 4.
                                                            self?.dismissGrantingAccessToURL(destinationURL)
                                                        } catch _ {
                                                            print("error copying file")
                                                        }
                })
            
        default:
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
