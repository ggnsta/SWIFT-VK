//
//  FriendListController.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit

class FriendsListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak private var friendsList: UITableView!
    @IBOutlet weak private var searchFriends: UISearchBar!
    private let cellReuseIdentifier = "friendsCell"
    private var provider: FriendsListProviderProtocol?
    private var bioFriends = [Person]()
    private var downloadImageProcess: DownloaderImageProtocol?
    private var filteredData = [Person]()
    private var refreshControl: UIRefreshControl!
    private var currentId: String?
    private var currentName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider = VKProvider()
        downloadImageProcess = DownloaderImage()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        friendsList.addSubview(refreshControl)
        friendsList.allowsSelection = false;
        friendsList.separatorStyle = .none
        
        friendsList.delegate = self
        friendsList.dataSource = self
        searchFriends.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerData()
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // создаем новую ячейку при необходимости или повторно используем старую
        let friend = filteredData[indexPath.row]
        let cell:FriendsListTableViewCell = self.friendsList.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! FriendsListTableViewCell
        cell.set(name: "\(friend.name!) \(friend.surname!)")
        cell.set(activity: (self.filteredData[indexPath.row].isOnline)!)
        downloadImageProcess?.download(imageWithImagePath: friend.avaImgUrl!) { (image) in
            cell.set(avatar: image)
            cell.prepareForReuse()
        }
        return cell
    }
    
    //Swipe to delete and send messages
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { [weak self] (_, indexPath) in
            let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                self?.provider?.delete(friendBy: (self?.filteredData[indexPath.row].id)!)
                self?.registerData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in }))
            self?.present(alert, animated: true, completion: nil)
        }
        let messages = UITableViewRowAction(style: .normal, title: "Messages") { [weak self] (_, indexPath) in
            //go to messages
            self?.currentId = self?.filteredData[indexPath.row].id?.stringValue
            self?.currentName = "\((self?.filteredData[indexPath.row].name)!) \((self?.filteredData[indexPath.row].surname)!)"
            self?.performSegue(withIdentifier: "showChatFromFriends", sender: nil)
        }
        return [delete, messages]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChatViewController
        //destinationVC.chatId = currentId!
        //destinationVC.chatName = currentName!
        destinationVC.setChatId(chatId: currentId!)
        destinationVC.setChatName(chatName: currentName!)
    }
    
    private func registerData() {
        //захват self
        provider?.get(friendsListWith: { [weak self] (friends) in
            self?.bioFriends = friends
            self?.filteredData = friends
            self?.friendsList.reloadData()
        })
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.registerData()
        refreshControl.endRefreshing()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? bioFriends : bioFriends.filter { (item: Person) -> Bool in
            return "\(item.name!) \(item.surname!)".range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        friendsList.reloadData()
    }
}
