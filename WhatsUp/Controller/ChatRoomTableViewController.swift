
import UIKit

class ChatRoomTableViewController: UITableViewController {

    // MARK: Variables
    
    var allChatRooms :[ChatRoom] = []
    var filterdChatRooms : [ChatRoom] = []
    let searchController = UISearchController(searchResultsController: nil)

    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadChatRooms()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        

    }
    
    // MARK: Actions
    
    @IBAction func composeBarButton(_ sender: UIBarButtonItem) {
        
        let userView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersView") as! UserTableViewController
        self.navigationController?.pushViewController(userView, animated: true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? filterdChatRooms.count : allChatRooms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for : indexPath) as! ChatTableViewCell
//        
//        let chatRoom = ChatRoom(id: "123", chatRoomId: "123", senderId: "123", senderName: "Mohammad", receiverId: "123", receiverName: "Oday", date: Date(), memberIds: [""], lastMessage: "Hello , how are u ?", unreadCounter: 1, avatarLink: "")
        
        let chatRoom = searchController.isActive ? filterdChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        
        cell.configure(chatRoom: chatRoom)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: Tbale View Delegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let chatRoom = searchController.isActive ? filterdChatRooms[indexPath.row] : allChatRooms[indexPath.row]
            
            FChatRoomListener.shared.deleteChatRoom(chatRoom: chatRoom)
            
            if searchController.isActive{
                self.filterdChatRooms.remove(at: indexPath.row)
            }else{
                self.allChatRooms.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatRoomObject = searchController.isActive ? filterdChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        
        goToChat(chatRoomObject)
        
    }
    
    func downloadChatRooms(){
        FChatRoomListener.shared.downloadChatRooms { allFBChatRooms in
            self.allChatRooms = allFBChatRooms
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    
    
    
    func goToChat(_ chatRoom :ChatRoom){
        
        
        // i can not ensure the other user kkep the room and not delete it, 
        // so , i need create method like startChat in helper and here call it
        restartChat(chatRoomId: chatRoom.id, memberIds: chatRoom.memberIds)
        let chatView = MSGViewController(chatId: chatRoom.id, recipientId: chatRoom.receiverId, recipientName: chatRoom.receiverName)
        navigationController?.pushViewController(chatView, animated: true)
        
    }
}



extension ChatRoomTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterdChatRooms = allChatRooms.filter({ (chatRoom) -> Bool in
            return chatRoom.receiverName.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        
        tableView.reloadData()
    }
    
    
}
