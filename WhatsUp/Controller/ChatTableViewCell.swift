

import UIKit


class ChatTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    @IBOutlet weak var unreadCounterView: UIView!
    
    
    // MARK: Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadCounterView.layer.cornerRadius = unreadCounterView.frame.height / 2
    }
    
    
    // MARK: Methods
    
    
    func configure(chatRoom : ChatRoom){
        userNameLabel.text = chatRoom.receiverName
        userNameLabel.minimumScaleFactor = 0.9
        lastMessageLabel.text = chatRoom.lastMessage
        lastMessageLabel.minimumScaleFactor = 0.9
        lastMessageLabel.numberOfLines = 2

        if chatRoom.unreadCounter != 0{
            self.unreadCounterLabel.text = "\(chatRoom.unreadCounter)"
            self.unreadCounterView.isHidden = false
        }
        else{
            self.unreadCounterView.isHidden = true
        }
        
        if chatRoom.avatarLink != ""{
            FileStorage.downloadImage(imageUrl: chatRoom.avatarLink) { avatarImage in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
            
        }else{
            self.avatarImageView.image = UIImage(named: "avatar")
        }
        
        self.dateLabel.text = timeElapsed(chatRoom.date ?? Date())
    }

}
