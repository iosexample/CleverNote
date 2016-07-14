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

class NotesTableViewController: UITableViewController {

  // MARK: - Properties
  var notes = [Note]()
  let noteSegueIdentifier = "noteSegue"
  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    return formatter
  }()

  // MARK: - View Life Cycle
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    refreshNoteList()
  }

  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard segue.identifier == noteSegueIdentifier else {
      return
    }
    
    let noteViewController = segue.destinationViewController as! NoteViewController
    let noteDocument = sender as! Note
    noteViewController.note = noteDocument
  }
}

// MARK: - Internal
extension NotesTableViewController {

  func refreshNoteList() {
    notes = Note.getAllNotesInFileSystem()
    tableView.reloadData()
  }
}

// MARK: - IBActions
extension NotesTableViewController {

  @IBAction func addButtonTapped(sender: AnyObject) {

    let alertController = UIAlertController(title: "Add Note", message: "Please enter a title for your new note", preferredStyle: .Alert)
    alertController.addTextFieldWithConfigurationHandler { textField in
      textField.placeholder = "Note Title"
    }
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
    
    let okayAction = UIAlertAction(title: "Okay", style: .Default) { action in
      guard let noteTitle = alertController.textFields?.first?.text else {
        return
      }
        
      guard let note = Note.createNote(noteTitle) else {
        return
      }

      note.saveToURL(note.fileURL, forSaveOperation: .ForCreating) { [unowned self] (success) -> Void in
        guard success else {
          print("Save unsuccessful")
          return
        }
        
        self.performSegueWithIdentifier(self.noteSegueIdentifier, sender: note)
        self.notes.append(note)
      }
    }

    alertController.addAction(okayAction)
    presentViewController(alertController, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource
extension NotesTableViewController {
  
  // MARK: - CellIdentifiers
  private enum CellIdentifier: String {
    case NoteCell = "noteCell"
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notes.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.NoteCell.rawValue, forIndexPath: indexPath)
    let noteDocument = notes[indexPath.row]
    cell.textLabel?.text = noteDocument.title
    return cell
  }
}

// MARK: - UITableViewDelegate
extension NotesTableViewController {

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let noteDocument = notes[indexPath.row]
    performSegueWithIdentifier(noteSegueIdentifier, sender: noteDocument)
  }
}
