import Foundation
import MessageKit
extension MSGViewController: MessagesDisplayDelegate{
    
   
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .label
    }
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let bubbleColorOutgoing = UIColor(named: "colorOutgoingBubble")
        let bubbleColorIncoming = UIColor(named: "colorIncomingBubble")
        return isFromCurrentSender(message: message) ? bubbleColorOutgoing! :bubbleColorIncoming!
    }
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
         
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//                  MARK: For Channel

extension ChannelMSGViewController: MessagesDisplayDelegate{
    
   
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .label
    }
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let bubbleColorOutgoing = UIColor(named: "colorOutgoingBubble")
        let bubbleColorIncoming = UIColor(named: "colorIncomingBubble")
        return isFromCurrentSender(message: message) ? bubbleColorOutgoing! :bubbleColorIncoming!
    }
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
         
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
}
