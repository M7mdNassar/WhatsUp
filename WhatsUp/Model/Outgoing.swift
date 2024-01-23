
import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery


class Outgoing{
    
    class func sendMessage(chatId : String , text:String? , photo:UIImage? , video:Video? , audioUrl: String? , audioDuration: Float = 0.0 , location: String? , memberIds:[String]){
        
        
        let currentUser = User.currentUser!
        
        //1. create local message from the datawe have
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.userName
        message.senderInitials = String(currentUser.userName.first!)
        message.date = Date()
        message.status = kSENT
        
        //2. check message type
        if text != nil {
            sendText(message: message , text: text!, memberIds : memberIds)
        }
        if photo != nil{
            //to do function for send photo
        }
        if video != nil{
            //to do function for send video
        }
        if audioUrl != nil{
            //to do function for send audio
        }
        if location != nil{
            //to do function for send location
        }
        //3. save message locally
        
        //4. save mesage to firebase
        
        
        // MARK: send notifcation
        
        
        //update chatroom
        FChatRoomListener.shared.updateChatRoom(chatRoomId: chatId, lastMessage: message.message)
    }
    
    class func saveMessage(message: LocalMessage , memberIds:[String]){
        RealmManager.shared.save(message)
        
        for memberId in memberIds {
            FMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
    
}


func sendText(message: LocalMessage , text:String , memberIds:[String]){
    
    message.message = text
    message.type = kTEXT
    
    Outgoing.saveMessage(message: message, memberIds: memberIds)
}

