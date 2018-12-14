//
//  VKProvider.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import Foundation
import VK_ios_sdk

class VKProvider: FriendsListProviderProtocol, MessagesProviderProtocol, PrivateChatProviderProtocol {
    private var ts: NSNumber?
    private var server: String?
    private var key: String?
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    init() {
        serialQueue = DispatchQueue(label: "queue")
    }
    
    // MARK: LongPoll
    public func get(longPollServerWith callBack: @escaping () -> Void) {
        serialQueue.async {
            VKRequest(method: "messages.getLongPollServer", parameters: ["need_pts":"0"]).execute(resultBlock: { [weak self] (response) in
                let json = response?.json as! Dictionary<String, Any>
                self?.ts = json["ts"] as? NSNumber
                self?.key = json["key"] as? String
                self?.server = json["server"] as? String
                DispatchQueue.main.async {
                    callBack()
                }
                }, errorBlock: { (error) in
                    print("ERROR: \(String(describing: error))")
            })
        }
    }
    
    public func registration(longPollWith callBack: @escaping () -> Void) {
        serialQueue.async {
            let url: URL! = URL(string: "https://\(self.server!)?act=a_check&key=\(self.key!)&ts=\(self.ts!.stringValue)&wait=25&mode=2&version=2")
            self.session.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
                DispatchQueue.main.async {
                    callBack()
                }
            }).resume()
        }
    }
    
    // MARK: FriendsList
    public func get(friendsListWith treatmentFriends: @escaping ([Person]) -> Void) {
        serialQueue.async {
            var bioFriends = [Person]()
            VKRequest(method: "friends.get", parameters: ["fields":"photo_50", "order":"hints"]).execute(resultBlock: { (response) in
                let json = response?.json as! Dictionary<String, Any>
                let items = json["items"] as! Array<Dictionary<String, Any>>
                items.forEach {
                    bioFriends.append(Person(id: $0["id"] as? NSNumber,
                                             name: $0["first_name"] as? String,
                                             surname: $0["last_name"] as? String,
                                             avaImgUrl: $0["photo_50"] as? String,
                                             isOnline: $0["online"] as? Bool))
                }
                DispatchQueue.main.async {
                    treatmentFriends(bioFriends)
                }
            }, errorBlock: { (error) in
                print("ERROR: \(String(describing: error))")
            })
        }
    }
    
    public func delete(friendBy id: NSNumber) {
        serialQueue.async {
            VKRequest(method: "friends.delete", parameters: ["user_id":id.stringValue]).execute(resultBlock: { (response) in
                print("Friend \(id.stringValue) was deleted")
            }, errorBlock: { (error) in
                print("ERROR: \(String(describing: error))")
            })
        }
    }
    
    //MARK: MessagesList
    public func get(messagesListWith treatmentMessages: @escaping ([Message]) -> Void) {
        serialQueue.async {
            // get list prev messages
            var conversations = [Message]()
            VKRequest(method: "messages.getConversations", parameters: ["extended":"1"]).execute(resultBlock: { [weak self] (response) in
                let json = response?.json as! Dictionary<String, Any>
                let profiles = json["profiles"] as! Array<Dictionary<String, Any>>
                let items = json["items"] as! Array<Dictionary<String, Any>>
                profiles.forEach {
                    if let gettingMessage = (self?.get(preliminaryMessagesOf: Person(id: $0["id"] as? NSNumber,
                                                                                     name: $0["first_name"] as? String,
                                                                                     surname: $0["last_name"] as? String,
                                                                                     avaImgUrl: $0["photo_50"] as? String,
                                                                                     isOnline: $0["online"] as? Bool),
                                                       and: items)) {
                        conversations = conversations + gettingMessage
                    }
                }
                //sort
                let sortedConversations = conversations.sorted {$0.lastDateMessage.compare($1.lastDateMessage) == .orderedDescending}
                DispatchQueue.main.async {
                    treatmentMessages(sortedConversations)
                }
                }, errorBlock: { (error) in
                    print("Error: \(String(describing: error))")
            })
        }
    }
    
    private func get(preliminaryMessagesOf person: Person, and objects: Array<Dictionary<String, Any>>) -> [Message]? {
        var messages = [Message]()
        for object in objects {
            let lastMessage = object["last_message"] as! Dictionary<String, Any>
            let conversation = object["conversation"] as! Dictionary<String, Any>
            let peer = conversation["peer"] as! Dictionary<String, Any>
            let count = conversation["unread_count"] as? NSNumber
            let textLastMessage: String
            let isSentRead: Bool
            conversation["in_read"] as! NSNumber != conversation["out_read"] as! NSNumber ? (isSentRead = false) : (isSentRead = true)
            if let out = lastMessage["out"] as? Bool {
                out ? (textLastMessage = "You: \(set(textLastMessagesBy: lastMessage))") : (textLastMessage = set(textLastMessagesBy: lastMessage))
            } else {
                textLastMessage = set(textLastMessagesBy: lastMessage)
            }
            if peer["type"] as? String == "user" {
                if person.id == (lastMessage["peer_id"] as! NSNumber) {
                    messages.append(Message(person: person,
                                                       lastMessage: textLastMessage,
                                                       lastDateMessage: lastMessage["date"] as! NSNumber,
                                                       id: peer["id"] as? NSNumber,
                                                       unreadCount: count != nil ? count : 0,
                                                       isSentRead: isSentRead))
                }
            } else {
                if let conversationIds = conversation["chat_settings"] as? Dictionary<String, Any> {
                    let activeIds = conversationIds["active_ids"] as! Array<NSNumber>
                    var photoUrl: String?
                    if let photo = conversationIds["photo"] as? Dictionary<String, Any> {
                        photoUrl = photo["photo_50"] as? String
                    } else {
                        photoUrl = "https://vk.com/images/community_50.png?ava=1"
                    }
                    //nid fix this. mb???
                    if person.id == activeIds.first {
                        messages.append(Message(person: Person(id: activeIds.first!,
                                                                          name: conversationIds["title"] as? String,
                                                                          surname: "",
                                                                          avaImgUrl: photoUrl,
                                                                          isOnline: nil),
                                                           lastMessage: textLastMessage,
                                                           lastDateMessage: lastMessage["date"] as! NSNumber,
                                                           id: peer["id"] as? NSNumber,
                                                           unreadCount: count != nil ? count : 0,
                                                           isSentRead: isSentRead))
                    }
                }
            }
        }
        return messages
    }
    
    private func set(textLastMessagesBy lastMessages: Dictionary<String, Any>) -> String {
        var textLastMessage = lastMessages["text"] as! String
        if textLastMessage == "" {
            if let attachments = lastMessages["attachments"] as? Array<Dictionary<String, Any>> {
                attachments.forEach {
                    switch $0["type"] as! String {
                    case "photo": textLastMessage = "Photo"
                    case "video": textLastMessage = "Video"
                    case "audio": textLastMessage = "Audio"
                    case "doc": textLastMessage = "Document"
                    case "link": textLastMessage = "Link"
                    case "market": textLastMessage = "Market"
                    case "market_album": textLastMessage = "Market album"
                    case "wall": textLastMessage = "Wall post"
                    case "wall_reply": textLastMessage = "Wall reply"
                    case "sticker": textLastMessage = "Sticker"
                    case "gift": textLastMessage = "Gift"
                    default:
                        break
                    }
                    return
                }
            }
        }
        return textLastMessage
    }
    
    private func set(attachmentsBy attachments: Dictionary<String, Any>) -> [AttachmentMessage]? {
        if let attachments = attachments["attachments"] as? Array<Dictionary<String, Any>> {
            var attachmentsToReturn = [AttachmentMessage]()
            attachments.forEach {
                switch $0["type"] as! String {
                case "photo": attachmentsToReturn.append(get(attachmentsBy: "photo", attachment: $0))
                case "video": attachmentsToReturn.append(get(attachmentsBy: "video", attachment: $0))
                case "audio": attachmentsToReturn.append(get(attachmentsBy: "audio", attachment: $0))
                case "doc": attachmentsToReturn.append(get(attachmentsBy: "doc", attachment: $0))
                case "link": attachmentsToReturn.append(get(attachmentsBy: "link", attachment: $0))
                case "market": attachmentsToReturn.append(get(attachmentsBy: "market", attachment: $0))
                case "market_album": attachmentsToReturn.append(get(attachmentsBy: "market_album", attachment: $0))
                case "wall": attachmentsToReturn.append(get(attachmentsBy: "wall", attachment: $0))
                case "wall_reply": attachmentsToReturn.append(get(attachmentsBy: "wall_reply", attachment: $0))
                case "sticker": attachmentsToReturn.append(get(attachmentsBy: "sticker", attachment: $0))
                case "gift": attachmentsToReturn.append(get(attachmentsBy: "gift", attachment: $0))
                default:
                    break
                }
            }
            return attachmentsToReturn
        } else {
            return nil
        }
    }
    
    private func get(attachmentsBy object: String, attachment: Dictionary<String, Any>) -> AttachmentMessage {
        let photo = attachment[object] as! Dictionary<String, Any>
        return AttachmentMessage(text: photo["text"] as? String,
                                 url: photo["photo_130"] as? String,
                                 id: photo["id"] as? NSNumber,
                                 widthImg: photo["width"] as? NSNumber,
                                 heightImg: photo["height"] as? NSNumber)
    }
    
    public func delete(chatBy id: NSNumber) {
        serialQueue.async {
            VKRequest(method: "messages.deleteConversation", parameters: ["peer_id":id.stringValue]).execute(resultBlock: { (response) in
                print("Chat \(id.stringValue) was deleted")
            }, errorBlock: { (error) in
                print("ERROR: \(String(describing: error))")
            })
        }
    }
    
    //MARK: Chat
    public func get(chatMessagesListBy id: String, lastMessageId: String, count: String, with treatmentMessages: @escaping ([PrivateMessage]) -> Void) {
        serialQueue.async {
            var messages = [PrivateMessage]()
            VKRequest(method: "messages.getHistory", parameters: ["user_id":id, "count":count, "rew":"1", "start_message_id":lastMessageId, "offset":"0"]).execute(resultBlock: { [weak self] (response) in
                let json = response?.json as! Dictionary<String, Any>
                let items = json["items"] as! Array<Dictionary<String, Any>>
                items.forEach {
                    let attachments = self?.set(attachmentsBy: $0)
                    messages.append(PrivateMessage(message: $0["body"] as! String,
                                                   date: $0["date"] as! NSNumber,
                                                   isMine: $0["out"] as! Bool,
                                                   isRead: $0["read_state"] as! Bool,
                                                   id: $0["id"] as! NSNumber,
                                                   attachments: attachments) )
                }
                DispatchQueue.main.async {
                    treatmentMessages(messages)
                }
                }, errorBlock: { (error) in
                    print("ERROR: \(String(describing: error))")
            })
        }
    }
    
    public func send(message: String, byUserId id: String) {
        serialQueue.async {
            if message != "" && id != "" {
                VKRequest(method: "messages.send", parameters: ["message":message, "peer_id":id]).execute(resultBlock: { (response) in
                    print("Message was sent!")
                }, errorBlock: { (error) in
                    print("ERROR: \(String(describing: error))")
                })
            }
        }
    }
    
    public func markAsRead(messagesBy id: String) {
        serialQueue.async {
            VKRequest(method: "messages.markAsRead", parameters: ["peer_id":id]).execute(resultBlock: { (response) in
                print("Messages marked as read!")
            }, errorBlock: { (error) in
                print("ERROR: \(String(describing: error))")
            })
        }
    }
    
    public func delete(messageBy id: NSNumber){
        serialQueue.async {
            VKRequest(method: "messages.delete", parameters: ["message_ids":id.stringValue, "delete_for_all":"1"]).execute(resultBlock: { (response) in
                print("Message was deleted!")
            }, errorBlock: { (error) in
                VKRequest(method: "messages.delete", parameters: ["message_ids":id.stringValue, "delete_for_all":"0"]).execute(resultBlock: { (response) in
                    print("Message was deleted!")
                }, errorBlock: { (error) in
                    print("ERROR: \(String(describing: error))")
                })
            })
        }
    }
}
