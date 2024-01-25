

import UIKit

class ChannelFollowTableViewController: UITableViewController {

    // MARK: Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var aboutChanelTextView: UITextView!
    
    // MARK: Variables
    
    var channel : Channel!
    var followDelegate : ChannelFollowTableViewControllerDelegate?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showChannelData()
        configureFollowBarItem()
        navigationItem.largeTitleDisplayMode = .never

    }

    private func showChannelData(){
        self.title = channel.name
        self.nameLabel.text = channel.name
        self.membersLabel.text = "\(channel.memberIds.count) Members"
        self.aboutChanelTextView.text = channel.aboutChannel
        
        if channel.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: channel.avatarLink) { image in
                DispatchQueue.main.async {
                    self.avatarImageView.image = image?.circleMasked

                }
            }
        }else{
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
  
    
    private func configureFollowBarItem(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followChannel))
    }
    
    @objc func followChannel(){
        channel.memberIds.append(User.currentId)
        FChannelListener.shared.saveChannel(channel)
        followDelegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }

}

// i need to notify the table , that channel folloed and move it to my following channels .... but without listener .. i need protocol !
protocol ChannelFollowTableViewControllerDelegate{
    func didClickFollow()
}
