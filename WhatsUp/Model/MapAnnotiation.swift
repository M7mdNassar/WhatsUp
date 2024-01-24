
import Foundation
import MapKit

class MapAnnotiation: NSObject, MKAnnotation{
    let title: String?
    var coordinate: CLLocationCoordinate2D
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
    
    
}
