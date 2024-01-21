

import UIKit

class UserTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
  
    func configureCell(user: User){
        self.userNameLabel.text = user.userName
        self.statusLabel.text = user.status
        
        if user.avatarLink != ""{
            FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }
        else{
            self.avatarImageView.image = UIImage(named: "avatar")
        }
     
        
        
    }
  

}
