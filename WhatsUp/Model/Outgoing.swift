
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
            //function for send photo
            sendPhoto(message: message, photo: photo!, memberIds: memberIds)
        }
        if video != nil{
            //function for send video
            sendVideo(message: message, video: video!, memberIds: memberIds)
        }
        if audioUrl != nil{
            //function for send audio
            sendAudio(message: message, audioFileName: audioUrl!, audioDuration: audioDuration, memberIds: memberIds)
        }
        if location != nil{
            //function for send location
            sendLocation(message: message, memberIds: memberIds)
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

func sendPhoto(message: LocalMessage , photo:UIImage , memberIds:[String]){
    
    message.message = "Photo Message"
    message.type = kPHOTO
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessage/Photo/" + "\(message.chatRoomId)" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(photo, directory: fileDirectory) { imageURL in
        
        if imageURL != nil{
            message.pictureUrl = imageURL!
            Outgoing.saveMessage(message: message, memberIds: memberIds)
        }
    }
}


func sendVideo(message:LocalMessage , video: Video , memberIds:[String]){
    message.message = "Video Message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessage/Photo/" + "\(message.chatRoomId)" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessage/Video/" + "\(message.chatRoomId)" + "_\(fileName)" + ".jpg"
    
    let editor = VideoEditor()
    editor.process(video: video) { processedVideo, videoUrl in
        if let tempPath = videoUrl {
            
            let thumbnail = videoThumbnail(videoURL: tempPath)
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData , fileName: fileName)
                
                FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) { imageLink in
                    
                    if imageLink != nil {
                        let videoData = NSData(contentsOfFile: tempPath.path)
                        FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                        FileStorage.uploadVideo(videoData!, directory: videoDirectory) { videoLink in
                            
                            message.videoUrl = videoLink ?? ""
                            message.pictureUrl = imageLink ?? ""
                            Outgoing.saveMessage(message: message, memberIds: memberIds)

                        }
                    }
                }
            }
        }
        
    }


func sendLocation(message: LocalMessage , memberIds: [String]){
    let currentLocation = LocationManager.shared.currentLocation
    
    message.message = "Location Message"
    message.type = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    Outgoing.saveMessage(message: message, memberIds: memberIds)
}

func sendAudio(message: LocalMessage , audioFileName: String , audioDuration : Float , memberIds:[String]){
    
    message.message = "Audio message"
    message.type = kAUDIO
    
    
    let fileDirectory = "MediaMessage/Audio/" + "\(message.chatRoomId)" + "_\(audioFileName)" + ".m4a"
    
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { audioLink in
        if audioLink != nil{
            message.audioUrl = audioLink ?? ""
            message.audioDuration = Double(audioDuration)
            
            Outgoing.saveMessage(message: message, memberIds: memberIds)
            
        }
    }

    
    
    
    
    
    
    
    
    
}
