
import Foundation
import MessageKit
import CoreLocation

class Incoming{
    
    var messageViewController: MessagesViewController
    
    init(messageViewController: MessagesViewController) {
        self.messageViewController = messageViewController
    }
    
    func createMKMessage (localMessage : LocalMessage) -> MKMessage{
        
        let mKmessage = MKMessage(message: localMessage)
        
        if localMessage.type == kPHOTO{
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mKmessage.photoItem = photoItem
            mKmessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { image in
                
                mKmessage.photoItem?.image = image
                self.messageViewController.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kVIDEO{
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { thumbnil in
                FileStorage.downloadVideo(videoUrl: localMessage.videoUrl) { (readyToPlay, fileName) in
                    
                    let videoLink = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                    let videoItem = VideoMessage(url:videoLink)
                    
                    mKmessage.videoItem = videoItem
                    mKmessage.kind = MessageKind.video(videoItem)
                    
                    mKmessage.videoItem?.image = thumbnil
                    self.messageViewController.messagesCollectionView.reloadData()
                }
            }
        }
        
        
        if localMessage.type == kLOCATION{
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mKmessage.kind = MessageKind.location(locationItem)
        }
        
        
        if localMessage.type == kAUDIO{
            let audioItem = AudioMessage(duration: Float(localMessage.audioDuration))
            mKmessage.audioItem = audioItem
            mKmessage.kind = MessageKind.audio(audioItem)
            
            FileStorage.downloadAudio(audioUrl: localMessage.audioUrl) { fileName in
                
                let audioURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                mKmessage.audioItem?.url = audioURL
            }
            self.messageViewController.messagesCollectionView.reloadData()
        }
        
        
        return mKmessage
    }
}






























