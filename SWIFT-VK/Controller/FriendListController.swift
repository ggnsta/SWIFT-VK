//
//  FriendListController.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit

class FriendListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    @IBOutlet weak var FriendList: UITableView!
    private var provider: FriendsListProviderProtocol?
    private var bioFriends = [Person]()
    private var filteredData = [Person]()
    private var refreshControl: UIRefreshControl!
    private var currentId: String?
    private var currentName: String?
    private let cellReuseIdentifier = "friendsCell"
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // создаем новую ячейку при необходимости или повторно используем старую
        let friend = filteredData[indexPath.row]
        let cell:FriendsListTableViewCell = self.FriendList.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! FriendsListTableViewCell
        cell.set(name: "\(friend.name!) \(friend.surname!)")
        cell.set(activity: (self.filteredData[indexPath.row].isOnline)!)
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        provider = VKProvider()
        refreshControl = UIRefreshControl()
        FriendList.addSubview(refreshControl)
        FriendList.allowsSelection = false;
        FriendList.separatorStyle = .none
        
        FriendList.delegate = self
        FriendList.dataSource = self
       
        // Do any additional setup after loading the view.
    }
    
   
}
