
import Foundation
import UIKit
import ProgressHUD
import FirebaseStorage

let storage = Storage.storage()

class FileStorage{
    
    
    // MARK:Images
    
    class func uploadImage (_ image: UIImage , directory: String , completion: @escaping (_ documentLink: String?) -> Void){
        
        // 1. create folder on firestore
        let storageRef = storage.reference(forURL: kSTORAGEFILE).child(directory)
        
        //2. convert image to data
        let imageData = image.jpegData(compressionQuality: 0.5)
        
        //3. put the data into firebase and retrive the link
        var task:StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { metaData, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil{
                print("Error uploading image \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
            
        })
        //4. observe the persentage upload
        task.observe(StorageTaskStatus.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            
            ProgressHUD.progress(CGFloat(progress))
        }
        
    }
    
    // download
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        guard let documentUrl = URL(string: imageUrl) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsPath(path: imageFileName) {
            // file exists locally
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                completion(contentsOfFile)
            } else {
                print("Could not convert local image")
                completion(UIImage(named: "avatar"))
            }
        } else {
            // download from Firebase
            let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
            
            downloadQueue.async {
                if let data = try? Data(contentsOf: documentUrl) {
                    FileStorage.saveFileLocally(fileData: data as NSData, fileName: imageFileName)
                    DispatchQueue.main.async {
                        completion(UIImage(data: data))
                    }
                } else {
                    print("No document found in the database")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    
    // MARK: download video
    
    
    class func downloadVideo(videoUrl: String, completion: @escaping (_ isReadyToPlay: Bool , _ videoFileName: String) -> Void) {
        
        
        
        let videoFileName = fileNameFrom(fileUrl: videoUrl) + ".mov"
        
        if fileExistsPath(path: videoFileName) {
            completion(true , videoFileName)
            
        } else {
            
            if videoUrl != ""{
                
                let documentUrl = URL(string: videoUrl)
                let downloadQueue = DispatchQueue (label: "imageDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                        DispatchQueue.main.async {
                            completion(true , videoFileName)
                        }
                    }
                    
                }
                
            }
            else {
                print("No document found in the database")
                
            }
        }
    }


    // MARK: uplaod Video
    
    class func uploadVideo (_ video: NSData , directory: String , completion: @escaping (_ videoLink: String?) -> Void){
        
        // 1. create folder on firestore
        let storageRef = storage.reference(forURL: kSTORAGEFILE).child(directory)
        
        //2. put the data into firebase and retrive the link
        var task:StorageUploadTask!
        
        task = storageRef.putData(video as Data, metadata: nil, completion: { metaData, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil{
                print("Error uploading image \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
            
        })
        //4. observe the persentage upload
        task.observe(StorageTaskStatus.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            
            ProgressHUD.progress(CGFloat(progress))
        }
        
    }
    
    
    // save file locally
    class func saveFileLocally(fileData: NSData , fileName: String){
        let docUrl = getDocumentURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
}

// MARK: Helpers


func getDocumentURL() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
}


func fileInDocumentsDirectory(fileName: String) -> String{
    return getDocumentURL().appendingPathComponent(fileName).path
    
}

func fileExistsPath(path: String) -> Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
