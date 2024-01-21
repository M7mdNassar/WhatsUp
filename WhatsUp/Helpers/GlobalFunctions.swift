

import Foundation

func fileNameFrom(fileUrl: String) -> String{
    let name = fileUrl.components(separatedBy: "_").last
    
    let name1 = name?.components(separatedBy: "?").first
    let name2 = name1?.components(separatedBy: ".").first
    return name2!
    
}

func timeElapsed(_ date :Date) -> String{
    
    let seconds = Date().timeIntervalSince(date)
    var elapsed = ""
    if seconds < 60 {
        elapsed = "Just Now"
    }
    else if seconds < 60 * 60 {
            let minutes = Int(seconds/60)
            let minText = minutes > 1 ? "mins" : "min"
            elapsed = "\(minutes) \(minText)"
        }
    
    else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        let hourText = hours > 1 ? "hours" : "hour"
        elapsed = "\(hours) \(hourText)"
    }
    else{
        elapsed = "\(date.longDate())"
    }
    return elapsed
}
