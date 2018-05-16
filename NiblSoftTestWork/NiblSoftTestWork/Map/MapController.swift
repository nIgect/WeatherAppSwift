//
//  MapController.swift
//  NiblSoftTestWork
//
//  Created by Kiryl Bukinevich on 4/18/18.
//  Copyright © 2018 Kiryl Bukinevich. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import SVProgressHUD

class MapController: UIViewController , CLLocationManagerDelegate , UISearchBarDelegate{
    
    
    
    
    @IBOutlet weak var locationWeatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var mapViewWeather: MKMapView!
    let activityIndicator = UIActivityIndicatorView()
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
    }
    
    //MARK: Get weather by location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapViewWeather.showsUserLocation = true
        locationManager.startUpdatingLocation()
        getWetherByLocation(manager)
        
    }
   
    func getWetherByLocation(_ manager: CLLocationManager){
        guard let currentPosition: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        ServerManager.shared.getWeatherByLocation(lat: currentPosition.latitude, lon: currentPosition.latitude) { (success, response, error) in
            if success {
                guard let  entity = NSEntityDescription.entity(forEntityName: "WeatherRequest", in: CoreDataManager.shared.managedObjectContext) else {return}
                
                let request = WeatherRequest(entity: entity, insertInto: CoreDataManager.shared.managedObjectContext)
                request.date = Date()
                request.weather = response["main"]["temp"].doubleValue
                request.lng = response["coord"]["lon"].doubleValue
                request.lat = response["coord"]["lat"].doubleValue
                request.city = response["name"].stringValue
                CoreDataManager.shared.saveContext()
                
                
                DispatchQueue.main.async {
                    let tempString = NSString(format: "%.f", response["main"]["temp"].doubleValue - 273)
                    self.locationWeatherLabel.text = "You location is \(response["name"].stringValue),\(tempString) C"
                    
                }
            } else {
                print(error)
            }
        }
    }
    
    
    
    @IBAction func searchAction(_ sender: Any) {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
        
    }
    
    //MARK: Get weather by city name
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        SVProgressHUD.show()
        
        ServerManager.shared.getWheather(by: searchBar.text!) { (success, response, error) in
            SVProgressHUD.dismiss()
            if success {
                guard let  entity = NSEntityDescription.entity(forEntityName: "WeatherRequest", in: CoreDataManager.shared.managedObjectContext) else {return}
                
                let request = WeatherRequest(entity: entity, insertInto: CoreDataManager.shared.managedObjectContext)
                request.date = Date()
                request.weather = response["main"]["temp"].doubleValue
                request.lng = response["coord"]["lon"].doubleValue
                request.lat = response["coord"]["lat"].doubleValue
                request.city = response["name"].stringValue
                CoreDataManager.shared.saveContext()
                
                DispatchQueue.main.async {
                    let tempString = NSString(format: "%.f", response["main"]["temp"].doubleValue - 273)
                    self.tempLabel.text = "Weather in \(response["name"].stringValue), \(tempString) C"
                }
            } else {
                print(error)
            }
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        
        
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.red
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequestText = MKLocalSearchRequest()
        searchRequestText.naturalLanguageQuery = searchBar.text
        
        let searchRequest = MKLocalSearch(request: searchRequestText)
        
        searchRequest.start { (response, error) in
            if response == nil{
                print("Error")
            }else{
                let annotation = self.mapViewWeather.annotations
                self.mapViewWeather.removeAnnotations(annotation)
                
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                let currentAnnotation = MKPointAnnotation()
                currentAnnotation.title = searchBar.text
                currentAnnotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapViewWeather.addAnnotation(currentAnnotation)
                
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.mapViewWeather.setRegion(region, animated: true)
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    //MARK: - Map zoom
    func zoomByFactor(factor:Double){
        var region:(MKCoordinateRegion) = self.mapViewWeather.region
        var span:(MKCoordinateSpan) = region.span
        span.latitudeDelta *= factor
        span.longitudeDelta *= factor
        region.span = span
        self.mapViewWeather.region = region
        self.mapViewWeather.setRegion(region, animated: true)
    }
    
    @IBAction func plusZoom(_ sender: Any) {
        zoomByFactor(factor: 0.5)
    }
    @IBAction func minusZoom(_ sender: Any) {
        zoomByFactor(factor: 2)
    }
    //MARK: - Current location
    @IBAction func currentLocation(_ sender: Any) {
        getWetherByLocation(locationManager)
        self.activityIndicator.isHidden = false
        if  mapViewWeather.showsUserLocation == true{
            mapViewWeather.showAnnotations([self.mapViewWeather.userLocation], animated: true)
            self.activityIndicator.isHidden = true
        } else {
            let alert = UIAlertController(title: "Error", message: "GPS must be on", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
