
import UIKit

class ChannelsTableViewController: UITableViewController {

    // MARK: Outlets
    
    
    @IBOutlet weak var channelsSegment: UISegmentedControl!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Channel"
        navigationItem.largeTitleDisplayMode = .always

   
    }
    
    // MARK: Actions
    
    @IBAction func channelSegmentChanged(_ sender: UISegmentedControl) {
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

   

}
