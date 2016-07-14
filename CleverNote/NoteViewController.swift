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

class NoteViewController: UIViewController {

  // MARK: - Properties
  var note: Note!

  // MARK: - IBOutlets
  @IBOutlet weak var textView: UITextView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    note.openWithCompletionHandler { [unowned self] success in
      guard success else {
        self.displayAlert(NSLocalizedString("Error", comment: ""),
          message: NSLocalizedString("Error opening note", comment: ""))
        return
      }

      self.title = self.note.title
      self.textView.text = self.note.documentText
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    textView.becomeFirstResponder()
  }
}

// MARK: - IBActions
extension NoteViewController {

  @IBAction func saveButtonTapped(sender: AnyObject) {
    note.documentText = textView.text
    note.saveToURL(note.fileURL, forSaveOperation: .ForOverwriting) { [unowned self] success in
      var title = "Note Saved"
      var message = "Note Saved Successfully"

      if !success {
        title = "Note Not Saved"
        message = "Error Saving Note"
      }

      self.displayAlert(title, message: message)
    }
  }
}

// MARK: - Private
private extension NoteViewController {

  /**
   Helper method to display a fully configured **UIAlertController** to the user

   - parameter title: **UIAlertController's** title text
   - parameter message: **UIAlertController's** message text
   */
  func displayAlert(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .Default, handler: nil))
    presentViewController(alertController, animated: true, completion: nil)
  }
}
