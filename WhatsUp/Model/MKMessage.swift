
import Foundation
import MessageKit

class MKMessage : NSObject, MessageType{
    
    var messageId: String
    var kind: MessageKit.MessageKind
    var sentDate: Date
    var mkSender : MKSender
    var sender: MessageKit.SenderType {
        return mkSender
    }
    var senderinitials: String
    var status : String
    var readDate : Date
    var incoming: Bool
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.kind = MessageKind.text(message.message)
        self.sentDate = message.date
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.senderinitials = message.senderinitials
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
    
    
}
