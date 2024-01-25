
import Foundation
import MessageKit

extension MSGViewController: MessagesDataSource{
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        mkMessages.count
    }
    
    
    
    
    // MARK: Cell Top Labels
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section % 3 == 0{
            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayingMessageCount)
            let text = showLoadMore ? "pull to load more": MessageKitDateFormatter.shared.string(from: message.sentDate)
            
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            
            return NSAttributedString(string: text , attributes: [.font : font , .foregroundColor: color])
        }
       return nil
    }
    
    
    // MARK: Cell Botton label
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
         
        if isFromCurrentSender(message: message){
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ?message.status + " " + message.readDate.time() : ""
            
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            return NSAttributedString(string: status , attributes: [.font : font , .foregroundColor: color])

        }
        return nil
    }
    
    
    // MARK: Message Bottom label
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section != mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            
            return NSAttributedString(string:message.sentDate.time() , attributes: [.font : font , .foregroundColor: color])
            
            
        }
        
        return nil
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//                    MARK: For Channel


extension ChannelMSGViewController: MessagesDataSource{
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        mkMessages.count
    }
    
    
    
    
    // MARK: Cell Top Labels
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section % 3 == 0{
            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayingMessageCount)
            let text = showLoadMore ? "pull to load more": MessageKitDateFormatter.shared.string(from: message.sentDate)
            
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            
            return NSAttributedString(string: text , attributes: [.font : font , .foregroundColor: color])
        }
       return nil
    }
    
    
    // MARK: Cell Botton label
    
//    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//         
//        if isFromCurrentSender(message: message){
//            let message = mkMessages[indexPath.section]
//            let status = indexPath.section == mkMessages.count - 1 ?message.status + " " + message.readDate.time() : ""
//            
//            let font = UIFont.boldSystemFont(ofSize: 10)
//            let color = UIColor.darkGray
//            return NSAttributedString(string: status , attributes: [.font : font , .foregroundColor: color])
//
//        }
//        return nil
//    }
    
    
    // MARK: Message Bottom label
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
       
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            
            return NSAttributedString(string:message.sentDate.time() , attributes: [.font : font , .foregroundColor: color])
            
       
    }
}
