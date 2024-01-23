
import Foundation
import MessageKit

class Incoming{
    
    var messageViewController: MessagesViewController
    
    init(messageViewController: MessagesViewController) {
        self.messageViewController = messageViewController
    }
    
    func createMKMessage (localMessage : LocalMessage) -> MKMessage{
        
        let mKmessage = MKMessage(message: localMessage)
        return mKmessage
    }
}
