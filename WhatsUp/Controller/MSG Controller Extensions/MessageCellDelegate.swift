import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser


extension MSGViewController: MessageCellDelegate{
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.photoItem != nil && mkMessage.photoItem?.image != nil{
                var images = [SKPhoto]()
                var photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                present(browser, animated: true)
            }
            
            
            if mkMessage.videoItem != nil && mkMessage.videoItem?.url != nil{
                
                //player controleler
                
                //player
                    
                let playerComtroller = AVPlayerViewController()
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                playerComtroller.player = player
                
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default , options: .defaultToSpeaker)
                
                present(playerComtroller , animated: true){
                    playerComtroller.player!.play()
                }
            }
            
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.locationItem != nil{
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
}
