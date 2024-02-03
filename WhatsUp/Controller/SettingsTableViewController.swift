

import UIKit
import ProgressHUD

class SettingsTableViewController: UITableViewController {

    // MARK: Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    // MARK: Life Cycle Table Controller

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView() // hide the cells in footer

    }
    
    override func viewWillAppear(_ animated: Bool) {
        showUserInfo()
    }

    
    // MARK: Actions
    
    @IBAction func tellFriendButton(_ sender: UIButton) {
        print("sex")
    }
    
    @IBAction func termsAndConditionsButton(_ sender: UIButton) {
        print("sex")

    }
    
    @IBAction func logOutButton(_ sender: UIButton) {
        
        FUserListener.shared.logoutUser { error in
            
            if error == nil{
                let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                loginView.modalPresentationStyle = .fullScreen
                
                DispatchQueue.main.async {
                    self.present(loginView, animated: true)
                }
            }
            else{
                ProgressHUD.error(error?.localizedDescription)
            }
            
        }

    }
    
    
    func showUserInfo(){
        if let user = User.currentUser{
            
            userNameLabel.text = user.userName
            statusLabel.text = user.status
            appVersionLabel.text = "App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            if user.avatarLink != ""{
                // TODO download and set the avatar image ... done
                FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
 
    // MARK: Table view Delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor(resource: .colorTableView)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
        
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }
        
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNonzeroMagnitude
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "settingsToEditProfileSegue", sender: self)
        }
                
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
}
