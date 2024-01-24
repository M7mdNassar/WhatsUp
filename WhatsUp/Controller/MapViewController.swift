
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: Variables
    
    var location: CLLocation?
    var mapView: MKMapView!

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        leftBarButtonItem()
        self.title = "Map View"
    }
    
    // MARK: Mehtods
    
    private func configureMapView(){
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        mapView.showsUserLocation = true
        if location != nil{
            mapView.setCenter(location!.coordinate, animated: false)
            //add a notiation
            
            mapView.addAnnotation(MapAnnotiation(title: "User Location", coordinate: location!.coordinate))
        }
        view.addSubview(mapView)
    }

    private func leftBarButtonItem(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))
    }

    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
}
