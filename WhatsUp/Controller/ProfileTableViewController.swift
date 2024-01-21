
import UIKit

class ProfileTableViewController: UITableViewController {
    
    // MARK: Variables
    
    var user:User?
    
    // MARK: Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        setupUI()
        
        
    }
    
    
    func setupUI(){
        
        if user != nil{
            
            navigationItem.title = user?.userName
            self.userNameLabel.text = user?.userName
            self.statusLabel.text = user?.status
            
            if user?.avatarLink != ""{
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }else{
                self.avatarImageView.image = UIImage(named:"avatar")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 5.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let chatId = startChat(sender: User.currentUser!, reciver: user!)
        }
    }
    
}
