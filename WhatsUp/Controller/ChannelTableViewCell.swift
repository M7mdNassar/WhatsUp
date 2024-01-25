

import UIKit

class ChannelTableViewCell: UITableViewCell {

    
    // MARK: Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var aboutChannelLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(channel: Channel){
        self.channelNameLabel.text = channel.name
        self.aboutChannelLabel.text = channel.aboutChannel
        self.membersLabel.text = "\(channel.memberIds.count) members"
        self.lastMessageDateLabel.text = timeElapsed(channel.lastMessageDate ?? Date())
        
        if channel.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: channel.avatarLink) { image in
                DispatchQueue.main.async {
                    self.avatarImageView.image = image != nil ? image?.circleMasked : UIImage(named: "avatar")

                }
            }
        }
        else{
            self.avatarImageView.image = UIImage(named: "avatar")
        }
        
    }

}
