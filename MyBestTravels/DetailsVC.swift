//
//  DetailsVC.swift
//  MyBestTravels
//
//  Created by Yasin Özdemir on 27.02.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
class DetailsVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var id = UUID()
    var name = ""
    var  myLatitude = 0.0
    var myLongitude = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        if name != ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let contex = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
            let stringId = id.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@",stringId )
            do{
                let results =  try contex.fetch(fetchRequest)
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        nameLabel.text = name
                    }
                    if let comment = result.value(forKey: "comment") as? String{
                        commentLabel.text = comment
                    }
                    if let latitude = result.value(forKey: "latitude") as? Double{
                        myLatitude = latitude
                    }
                    if let longitude = result.value(forKey: "longitude") as? Double{
                        myLongitude = longitude
                    }
                    
                }
                maps()
                
                
            }catch{print("Fetch Error")}
        }
    }
    
    func maps(){ // haritada gösterme
        // veri tabanından çekilen koordinatları haritada göstermek
        let myLocation = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        let mySpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let myRegion = MKCoordinateRegion(center: myLocation, span: mySpan)
        mapView.setRegion(myRegion, animated: true)
       
        // veri tabanından çekilen yeri pinlemek için
        var myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate.longitude = myLongitude
        myAnnotation.coordinate.latitude = myLatitude
        myAnnotation.title = nameLabel.text
        mapView.addAnnotation(myAnnotation)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { // annotationumuzu özelleştirmek için bu fonksiyonu kullandık
        let reuseId = "myPın"
        var myPın = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        myPın = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        myPın?.canShowCallout = true // annotationa basılınca extra bilgi gösterilen yeri açtık
        
        let navigationButton = UIButton(type: UIButton.ButtonType.detailDisclosure)
        myPın?.rightCalloutAccessoryView = navigationButton // annotationa buton ekledik
        return myPın
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) { // annotaation butonuna basılınca ne olacak ?
        if name != ""{
            let requestLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemark, error in
                if placemark!.count > 0{
                    let newPlacemark = MKPlacemark(placemark: placemark![0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = self.nameLabel.text
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions : launchOptions)
                    
                    
                }
            }
        }
    }

}
