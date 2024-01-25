
import UIKit

class ChannelsTableViewController: UITableViewController {

    // MARK: Variables
    
    var subscribedChannels : [Channel] = []
    var allChannels : [Channel] = []
    var myChannels : [Channel] = []


    // MARK: Outlets
    
    
    @IBOutlet weak var channelsSegment: UISegmentedControl!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Channel"
        navigationItem.largeTitleDisplayMode = .always
        
        //download channels and fill different arrays
        
        downloadAllChannels()
        downloadSubscribedChannels()
        downloadUserChannels()
        
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        
   
    }
    
    
    // MARK: Actions
    
    @IBAction func channelSegmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if channelsSegment.selectedSegmentIndex == 0 {
            return subscribedChannels.count
        }else if channelsSegment.selectedSegmentIndex == 1{
            return allChannels.count
        }else{
            return myChannels.count
        }
    }
    
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell" , for: indexPath) as! ChannelTableViewCell
        
        var channel = Channel()
        
        if channelsSegment.selectedSegmentIndex == 0 {
            channel = subscribedChannels[indexPath.row]
        }else if channelsSegment.selectedSegmentIndex == 1{
            channel = allChannels[indexPath.row]
        }else{
            channel = myChannels[indexPath.row]
        }
        
        cell.configure(channel: channel)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    // MARK: Download Channels
    
    private func downloadAllChannels(){
        FChannelListener.shared.downloadAllChanels { userChannels in
            self.allChannels = userChannels
            
            if self.channelsSegment.selectedSegmentIndex == 1{
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    private func downloadSubscribedChannels(){
        FChannelListener.shared.downloadSubscribedChanels { userSubscribedChannels in
            self.subscribedChannels = userSubscribedChannels
            
            if self.channelsSegment.selectedSegmentIndex == 0{
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    private func downloadUserChannels(){
        FChannelListener.shared.downloadUserChanels { userChannels in
            self.myChannels = userChannels
            if self.channelsSegment.selectedSegmentIndex == 2{
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }
    }

   // MARK: UIScroll View
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl!.isRefreshing{
            self.downloadAllChannels()
            refreshControl!.endRefreshing()
        }
    }

    
    // MARK: Delegate of table
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if channelsSegment.selectedSegmentIndex == 0{
            // show chatt in
        }else if channelsSegment.selectedSegmentIndex == 1{
            //show follow channel view
            showFollowChannelView(channel: allChannels[indexPath.row])
        }else {
            //show edit channel view
            showEditChannelView(channel: myChannels[indexPath.row])
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if channelsSegment.selectedSegmentIndex == 1 || channelsSegment.selectedSegmentIndex == 2 {
            return false
        }
        else{
            return subscribedChannels[indexPath.row].adminId != User.currentId
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            var channelToUnfollow = subscribedChannels[indexPath.row]
            subscribedChannels.remove(at: indexPath.row)
            if let index = channelToUnfollow.memberIds.firstIndex(of: User.currentId){
                channelToUnfollow.memberIds.remove(at: index)
            }
            FChannelListener.shared.saveChannel(channelToUnfollow)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    // MARK: navigation to Edit view
    // i need use the same save view , but with diffrent button
    
    func showEditChannelView(channel: Channel){
        let channelVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saveChannel") as! AddChannelTableViewController
        
        channelVC.channelToEdit = channel
        
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    func showFollowChannelView(channel: Channel){
        let channelVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "followChannel") as! ChannelFollowTableViewController
                
        channelVC.channel = channel
        channelVC.followDelegate = self
        
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
}

extension ChannelsTableViewController: ChannelFollowTableViewControllerDelegate{
    func didClickFollow() {
        self.downloadAllChannels()
    }
    
    
}
