

import UIKit

class StatusTableViewController: UITableViewController {

    let statuses = ["Available" , "busy!" , "working.." , "on gym" , "off" , "studying.."]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell")
        cell?.textLabel?.text = statuses[indexPath.row]
        
        let userStatus = User.currentUser?.status //get the status
        
        cell?.accessoryType = cell?.textLabel?.text == userStatus ? .checkmark : .none
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userStatus = tableView.cellForRow(at: indexPath)?.textLabel?.text
        tableView.reloadData()
        
        var user = User.currentUser!
        user.status = userStatus!
        saveUserLocally(user: user)
        FUserListener.shared.saveUserToFierbase(user: user)
        
    }
    
    // for header background
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor(resource: .colorTableView)
        
        return view
    }
    

    

}
