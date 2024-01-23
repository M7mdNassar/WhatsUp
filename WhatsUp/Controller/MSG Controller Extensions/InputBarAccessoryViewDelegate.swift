import Foundation
import InputBarAccessoryView

extension MSGViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        updateMicButtonStatus(show: text == "")
        
        if text != ""{
            startTypingIndicator()
        }

        
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        send(text: text, photo: nil, video: nil, audioUrl: nil, location: nil, audioDuration: 0.0)
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
