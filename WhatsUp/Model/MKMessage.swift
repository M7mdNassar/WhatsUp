
import Foundation
import MessageKit
import CoreLocation

class MKMessage : NSObject, MessageType{
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var mkSender : MKSender
    var sender: SenderType {
        return mkSender
    }
    var senderInitials: String
    
    var photoItem:PhotoMessage?
    var videoItem : VideoMessage?
    var locationItem: LocationMessage?
    var audioItem: AudioMessage?
    
    var status : String
    var readDate : Date
    var incoming: Bool
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        switch message.type{
        case kTEXT:
            self.kind = MessageKind.text(message.message)
            
        case kPHOTO:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
            
        case kVIDEO:
            let videoItem = VideoMessage(url: nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
            
        case kLOCATION:
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
            
        case kAUDIO:
            let audioItem = AudioMessage(duration: 2.0)
            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
       
            
        default:
            self.kind = MessageKind.text(message.message)
            print("error")
        }
   
        
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
    
    
}
