//
//  ChatViewController.swift
//  SWIFT-VK
//
//  Created by hs on 13.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//
import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var buttomView: UIView!
    public var chatId: String?
    public var chatName: String?
    private var provider: PrivateChatProviderProtocol?
    private var messages = [PrivateMessage]()
    private let cellReuseIdentifier = "privateMessagesCell"
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    private var isKeyboardHide = true
    private let countMessages = "30"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        provider = VKProvider()
        
        chatTableView.separatorStyle = .none
        navigationItem.title = chatName
        textField.clearButtonMode = .whileEditing
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        registerForKeyboardNotifications()
        startLongPoll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.provider?.markAsRead(messagesBy: self.chatId!)
        self.registerData()
    }
    
    private func startLongPoll() {
        provider?.get(longPollServerWith: { [weak self] in
            self?.updateUI()
        })
    }
    
    private func updateUI() {
        self.provider?.markAsRead(messagesBy: self.chatId!)
        provider?.registration(longPollWith: { [weak self] () in
            self?.addNewElementsToMessagesList(by: "-1", count: "1")
            self?.checkСhangeInMessagesList()
            self?.startLongPoll()
        })
    }
    
    private func registerData() {
        provider?.get(chatMessagesListBy: chatId!, lastMessageId: "-1", count: countMessages, with: { [weak self] (messages) in
            self?.messages = messages
            self?.chatTableView.reloadData()
        })
    }
    
    private func addNewElementsToMessagesList(by id: String, count: String) {
        provider?.get(chatMessagesListBy: chatId!, lastMessageId: id, count: count, with: { [weak self] (messages) in
            if (self?.messages.first?.id != messages.first?.id) || (count == self?.countMessages) {
                if self?.messages.last?.id == messages.last?.id {
                    return
                } else {
                    var messagesToAdd = messages
                    messagesToAdd.remove(at: 0)
                    self?.messages = (count == self?.countMessages) ? ((self?.messages)! + messagesToAdd) : (messages + (self?.messages)!)
                    self?.chatTableView.reloadData()
                }
            }
        })
    }
    
    private func checkСhangeInMessagesList() {
        provider?.get(chatMessagesListBy: chatId!, lastMessageId: "-1", count: countMessages, with: { [weak self] (messages) in
            for index in 0...29 {
                if (messages[exist: index]?.id != self?.messages[exist: index]?.id) || (messages[exist: index]?.isRead != self?.messages[exist: index]?.isRead) {
                    self?.messages[index] = messages[index]
                }
            }
            self?.chatTableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isKeyboardHide {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Copy text to clipboard", style: .default, handler: { [weak self] action in
                    UIPasteboard.general.string = self?.messages[indexPath.row].message
                }))
                alert.addAction(UIAlertAction(title: "Delete message", style: .destructive, handler: { [weak self] action in
                    self?.provider?.delete(messageBy: (self?.messages[indexPath.row].id)!)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            textField.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell:PrivateMessagesListTableViewCell = self.chatTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PrivateMessagesListTableViewCell
        cell.transform = CGAffineTransform(scaleX: 1, y: -1);
        cell.set(textMessage: message.message, isMine: message.isMine, isRead: message.isRead, attachments: message.attachments)
        cell.set(date: message.date, isMine: message.isMine)
        cell.selectionStyle = .none
        cell.prepareForReuse()
        if message.id == messages.last?.id {
            addNewElementsToMessagesList(by: (messages.last?.id.stringValue)!, count: countMessages)
        }
        return cell
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        provider?.send(message: textField.text!, byUserId: chatId!)
        textField.resignFirstResponder()
        textField.text = nil
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func kbWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let kbFrameSize = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        contentScrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
        isKeyboardHide = false
    }
    
    @objc func kbWillHide() {
        contentScrollView.contentOffset = CGPoint.zero
    }
    
    @objc func kbDidHide() {
        isKeyboardHide = true
    }
}

//Index out of range
extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
