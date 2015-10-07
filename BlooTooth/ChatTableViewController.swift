//
//  ChatTableViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 10/6/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

class ChatTableCell: UITableViewCell {
    @IBOutlet weak var senderNameLabel: UILabel?
    @IBOutlet weak var messageLabel: UILabel?
}

class ChatTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var clientsConnectedLabel: UILabel?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var responseTextField: UITextField?
    @IBOutlet weak var sendButton: UIButton?
    @IBOutlet weak var textEntryView: UIView?
    @IBOutlet weak var textEntryConstraint: NSLayoutConstraint?

    typealias ChatResponse = (senderName: String, contents: String)
    var conversation: [ChatResponse] = [ChatResponse]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.statusLabel?.text = "Waiting for Connections..."
        self.clientsConnectedLabel?.text = "0 clients connected"

        addToConversation("Server", message: "CQ, CQ, CQ", reload: false)
        addToConversation("Client 1", message: "I've got you 5 by 5", reload: false)
        addToConversation("Server", message: "Roger")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Notification Callbacks
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.textEntryConstraint?.constant = keyboardFrame.size.height
        })
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.textEntryConstraint?.constant = 0
        })
    }

    // MARK: - Button Methods
    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func sendButtonTapped(sender: UIButton) {
        sendChatResponse()
    }

    // MARK: - UITextFieldDelegate Methods
    func textFieldDidEndEditing(textField: UITextField) {
        sendChatResponse()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.responseTextField?.resignFirstResponder()
        return true
    }

    // MARK: - Chat Methods
    func sendChatResponse() -> Bool {
        if let response = self.responseTextField?.text {
            if response == "" {
                return false
            }
            addToConversation("Server", message: response)
            self.responseTextField?.text = ""
            return true
        }
        return false
    }

    func addToConversation(sender: String, message: String, reload: Bool = true) {
        conversation.insert(ChatResponse(senderName: sender, contents: message), atIndex: 0)
        if reload == true {
            self.tableView?.reloadData()
        }
    }

    func messageForIndex(index: Int) -> ChatResponse? {
        if self.conversation.count >= index {
            return self.conversation[index]
        }
        return nil
    }

    // MARK: - UITableViewDataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversation.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("btChatMessage") as! ChatTableCell) ?? ChatTableCell()

        if let message = messageForIndex(indexPath.row) {
            cell.senderNameLabel?.text = "\(message.senderName):"
            cell.messageLabel?.text = message.contents
        }
        return cell
    }

}
