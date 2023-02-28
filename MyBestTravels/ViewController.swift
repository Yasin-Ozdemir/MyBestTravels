//
//  ViewController.swift
//  MyBestTravels
//
//  Created by Yasin Özdemir on 27.02.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var commentText: UITextField!
    
    var choosenLocationLatitude = 0.0
    var choosenLocationLongitude = 0.0
    var locationManager = CLLocationManager() // Kullanıcının konumunuyla uğraşabilmek için location manager kullanırız
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self // mapView'in izinkeri verildi
        locationManager.delegate = self // locationmanagerin izinleri verildi
        
        // LOCATION MANAGER AYARLARI
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // konumun kesinlik seviyesini belirledik
        locationManager.requestWhenInUseAuthorization() // kullanıcıdan ne sıklıkla konum izni isteyeceğimizi belirledik
        locationManager.startUpdatingLocation() // konumu almaya başladık
        
        // PIN OLUŞTURMA
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectedLocation(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func selectedLocation( gestureRecognizer: UILongPressGestureRecognizer) { // gesture recognizerı input olarak almamızın sebebi özel fonksiyonlarını kullanmak
        
        if gestureRecognizer.state == .began{
            let touchedPoint = gestureRecognizer.location(in: mapView) // kullanıcının uzun bastığı noktayı aldık
            let touchedLocation = mapView.convert(touchedPoint, toCoordinateFrom: mapView) // noktayı koordinata dönüştürdük
            
            
            let annotation = MKPointAnnotation() // pini oluşturduk
            annotation.coordinate = touchedLocation // pinin koordinatına kullanıcının uzun bastığı noktanın koordinatını atadık
            annotation.title = "Selected"
            mapView.addAnnotation(annotation) // pini haritamıza ekledik
            
            choosenLocationLatitude = annotation.coordinate.latitude
            choosenLocationLongitude = annotation.coordinate.longitude
            
            
        }
    }
   
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { // kullancının konumununu aldıktan sonra haritada göstermek için bu fonk kullanılır
        // KULLANICININ KONUMU LOCATİONS DİZİSİNİN İLK ELEMANININ KOORDİNATLARIDIR!
        let myLocation = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) // kullanıcının                                                                                                            konumunu enlem ve boylam kullanarak kaydettik
        let mySpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1 ) // istediğimiz zoomu oluşturduk
        
        
        let myRegion = MKCoordinateRegion(center: myLocation, span: mySpan) // kullanıcının konumunu ve istediğimiz zoomla birlikte bölge                                                                                        oluşturduk
        mapView.setRegion(myRegion, animated: true) // haritaya şu konumu/bölgeyi göster diyoruz
    }

    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let contex = appDelegate.persistentContainer.viewContext
        
        let travel = NSEntityDescription.insertNewObject(forEntityName: "Travel", into: contex)
        
        travel.setValue(nameText.text, forKey: "name")
        travel.setValue(commentText.text, forKey: "comment")
        travel.setValue(choosenLocationLongitude, forKey: "longitude")
        travel.setValue(choosenLocationLatitude, forKey: "latitude")
        travel.setValue(UUID(), forKey: "id")
        
        do {
            try contex.save()
        }catch {print("Save Error")}
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Save Success"), object: nil)
        
        navigationController?.popViewController(animated: true)
        
    }
    
}

