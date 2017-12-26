//
//  AccueilViewController.swift
//  SupInfo
//
//  Created by Supinfo on 11/12/2017.
//  Copyright © 2017 Supinfo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SystemConfiguration

class AccueilViewController: UIViewController, CLLocationManagerDelegate {

    /**
        La vue de la map
    */
    @IBOutlet weak var mapView: MKMapView!
    
    /**
        le manager pour la Location
    */
    private let locationManager = CLLocationManager()
    
    /**
        l'état de la voiture
    */
    private var carState: Car? = nil
    
    /**
        L'utilisateur courant
    */
    public var user: User = User()
    
    /**
        Le timer qui va executer une fonction toutes les minutes
    */
    private var timerMinute: Timer = Timer()
    
    /**
        Le timer qui va executer une fonction au bout d'une heure
    */
    private var timerHour: Timer = Timer()
    
    /**
        le flag nous permettant de savoir si le timer est lancé ou non
    */
    private var timerHourIsOn: Bool = false
    
    /**
        le flag nous permettant de savoir si la timer à tourner pendant une heure
    */
    private var anHourSinceUpdate: Bool = false
    
    /**
        La marque de la voiture sur la carte
    */
    private var carAnnotation = MKPointAnnotation()
    
    /**
       La distance maximale par rapport à la voiture si elle est en mouvement
    **/
    private var maxDistance: Double =  0.1
    
    /**
        Permet de récupérer la position du téléphone et d'afficher la region correspondante
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Récupère la position
        let location = locations[0]
        
        //Defini le zoom à afficher
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //Position de l'utilisation
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //La region à afficher avec la position et le zoom défini
        let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
        
        mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //On affecte un titre et un sous-titre à la marque de la voiture
        carAnnotation.title = "My Car"
        carAnnotation.subtitle = "There is your car"
        self.mapView.addAnnotation(carAnnotation)
        
        updateStatus()
        //On lance le timer minute
        self.timerMinute = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: {
            timer in self.updateStatus()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewC: ViewController = storyBoard.instantiateViewController(withIdentifier: "Principal") as! ViewController
        self.present(viewC, animated: true, completion: nil)
    }
    

    /**
            Function fired when the timerMinute end. Update all information of the application
    */
    private func updateStatus(){
        
            //On envoi les coordonnées de l'utilisateur
       let userLocation: CLLocationCoordinate2D = self.mapView.userLocation.coordinate
       if(NetworkController.sendUserLocation(Login: user.UserName, Password: user.Password, Location: userLocation)){
           //Si on a réussi on relance notre timer à l'heure
            print("Send user location SUCCESS : Resetting TimerHour")
            self.timerHour.invalidate()
            self.timerHourIsOn = false
            launchTimerHour()
            print("TimerHour resetted")
       }
       else{
           //Si on a pas réussi à mettre à jour la position de l'utilisateur alors on on verifie que notre timerHour est lancé
           print("Can't send user location")
           checkTimerHour()
       }
        
        
        if !isInternetAvailable() {
            print("Pas de connecion internet")
            let alert = UIAlertController(title: "Warning", message: "The Internet is not available", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            //On récupère l'état de la voiture
            self.carState = NetworkController.getCarPosition(Login: self.user.UserName, Password: self.user.Password)
            //On vérifie qu'on à bien récupérer un truc
            if(self.carState != nil){
                print("Retrieving carState SUCCESS")
                carAnnotation.coordinate = (self.carState?.Location)!
                self.carState?.Speed != 0 ?
                    //Si la voiture est en mouvement
                    checkUserLocation() :
                    //Si la voiture est à l'arrêt
                    checkTimerHour()
            }
            else{
                print("Error carState is nil")
            }
        }
    }
    
    /**
        Check if the user has updated his location less than one hour or if he's near the car otherwise launch the alarm
    */
    private func checkUserLocation(){
        if(anHourSinceUpdate){
            //Ici on déclenche l'alarme alerte rouge la voiture bouge
            print("The car is moving and the user's location has not been updated since a hour")
            launchAlarm()
        }
        else if(!userInAreaOfCar()){
            print("The car is moving but the user is far from it : ALERT !!!")
            launchAlarm()
        }
        else{
            print("The car is moving but the user is in the area and his position has been updated less than one hour")
        }
    }
    
    /**
        Check if the timer is already started otherwise start it
    */
    private func checkTimerHour(){
        if(!self.timerHourIsOn){
            print("TimerHour is not already started")
            launchTimerHour()
            print("TimerHour started")
        }
        else{
            print("TimerHour already started")
        }
    }
    
    /**
        Event fired when one hour is spent and the user's location is unknown or not up to date
    */
    private func fireAnHourSinceUserLocationUpdate() -> Void{
        self.anHourSinceUpdate = true
    }
    
    /**
        Launch the alarm
    */
    private func launchAlarm(){
        self.anHourSinceUpdate = false;
        let alert = UIAlertController(title: "Alerte !", message: "Votre voiture est en mouvement alors que vous n'êtes pas dans le périmètre définit", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Return true if the user is in the area of the car otherwise return false. The max distance form the car is definied by self.maxDistance
    */
    private func userInAreaOfCar() -> Bool {
        //On récupère les coordonnée de l'utilisateur et de la voiture
        let userLocation = self.mapView.userLocation.coordinate
        let carLocation = self.carState!.Location
        
        //Basé sur les coordonée polaire pour trouver la distance d'un point 2D a partir de son origine : p = sqr(x*x + y*y)
        let x = abs(userLocation.longitude - carLocation.longitude)
        let y = abs(userLocation.latitude - carLocation.latitude)
        let distance = sqrt(pow(x, 2) + pow(y, 2))
        
        //Si la distance est supérieur à la distance maximum on retourne faux sinon vrai
        if(distance > self.maxDistance){
            print("The user is not in the car's area")
            return false
        }
        else{
            print("The user is in the car's area")
            return true
        }
    }
    
    // Vérifie la connection internet
    func isInternetAvailable() -> Bool {
        print("Vérifiaction de la connection")
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    
    /**
        Check if the timerHour is already started otherwise start it
    */
    private func launchTimerHour(){
        self.timerHourIsOn = true
        self.timerMinute = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: {
            timer in
            self.updateStatus()
        })
    }
    

}
