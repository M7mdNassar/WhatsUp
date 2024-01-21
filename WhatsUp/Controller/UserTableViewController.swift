

import UIKit

class UserTableViewController: UITableViewController {

    // MARK: Variable
    
    var allUsers:[User] = []
    var filterdUsers:[User] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        allUsers = [User.currentUser!]
        
//        createDummyUsers()
        downloadAllUsers()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filterdUsers.count : allUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
        let user = searchController.isActive ? filterdUsers[indexPath.row] : allUsers[indexPath.row]
        cell.configureCell(user: user)
      
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = searchController.isActive ? filterdUsers[indexPath.row] : allUsers[indexPath.row]
        showUserProfile(user: user)
        
    }

  

}



extension UserTableViewController{
    func downloadAllUsers(){
        FUserListener.shared.downloadAllUsersFromFirestore { firestoreAllUsers in
            self.allUsers = firestoreAllUsers
            
            self.tableView.reloadData()
        }
    }
    
    // Navigation to profile
    
    func showUserProfile(user: User){
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "profileController") as! ProfileTableViewController
        profileView.user = user
        self.navigationController?.pushViewController(profileView, animated: true)
    }

}

// MARK: UIScrollView Delegate
extension UserTableViewController{
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing {
            self.downloadAllUsers()
            self.refreshControl?.endRefreshing()
        }
    }
}


extension UserTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterdUsers = allUsers.filter({ (user) -> Bool in
            return user.userName.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        
        tableView.reloadData()
    }
    
    
}
