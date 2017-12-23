//
//  NetworkController.swift
//  SupInfo
//
//  Created by Supinfo on 20/12/2017.
//  Copyright © 2017 Supinfo. All rights reserved.
//

import Foundation
import CoreLocation

public class NetworkController {
    static let baseUrl = "http://supinfo.steve-colinet.fr/suptracking/"
    
    
    public static func Connection(Login login:String, Password pass:String) -> User? {
        var user: User? = nil
        print("Debut Connection func")
        let request = NSMutableURLRequest(url: URL(string: self.baseUrl)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let semaphore = DispatchSemaphore(value: 0)
        let postString = "action=login&login=" + login + "&password=" + pass
        request.httpBody = postString.data(using: .utf8)
        let apiRequest = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if(error != nil) {print("Erreur lors de la récupération de l'api : " + error!.localizedDescription)}
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {
                print("statusCode différent de 200 : error \(httpStatus.statusCode)")
                print("Response = \(response)")
            }
            
            
            if( error == nil ){
                do {
                     let json = try JSONSerialization.jsonObject(with: data!,options: [.mutableContainers])
                    
                    
                    guard let itemSuccess = (json as AnyObject) as? [String: Any],
                        let success = itemSuccess["success"] as? Bool
                        else {
                            print("Error lors du décodage JSON")
                            semaphore.signal()
                            return
                    }
                    if success == true{
                            guard let item = (json as AnyObject) as? [String: Any],
                            let person = item["user"] as? [String: Any],
                            let id2 = person["id"] as? Int
                            else {
                                print("Error lors du décodage JSON")
                                semaphore.signal()
                                return
                            }
                        user = User(id: id2, username: person["username"]! as! String, password: person["password"]! as! String, phone: person["phone"]! as! String, lastName: person["lastname"]! as! String, firstName: person["firstname"]! as! String, postalCode: person["postalCode"]! as! String, address: person["address"]! as! String, email: person["email"]! as! String)
                    }
                } catch {
                
                    print(error)
                }
            }
            
            semaphore.signal()
            
        }
        
        apiRequest.resume()
        semaphore.wait(timeout: .distantFuture)
        
        print("Fin Connection func")
        return user
    }
    
    public static func getCarPosition(Login login:String, Password pass:String) -> (Speed: Int,Location: CLLocationCoordinate2D) {
        //return (0,CLLocationCoordinate2D(latitude: 37.786834,longitude: -122.406417))
        var carState:(Speed: Int, Location: CLLocationCoordinate2D)? = nil
        print("Debut getPositionCar func")
        let request = NSMutableURLRequest(url: URL(string: self.baseUrl)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let semaphore = DispatchSemaphore(value: 0)
        let postString = "action=getCarPosition&login=" + login + "&password=" + pass
        request.httpBody = postString.data(using: .utf8)
        let apiRequest = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if(error != nil) {print("Erreur lors de la récupération de l'api : " + error!.localizedDescription)}
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {
                print("statusCode différent de 200 : error \(httpStatus.statusCode)")
                print("Response = \(response)")
            }
            
            if( error == nil ){
                do {
                    let json = try JSONSerialization.jsonObject(with: data!,options: [.mutableContainers])
                    
                    guard let item = (json as AnyObject) as? [String: Any],
                        let car = item["position"] as? [String: Any],
                        let coordonnee = CLLocationCoordinate2DMake(car["latitude"] as! Double, car["longitude"] as! Double) as CLLocationCoordinate2D?
                        else {
                            print("Error lors du décodage JSON")
                            semaphore.signal()
                            return
                    }
                    carState = (Speed: car["speed"] as! Int, Location: coordonnee)
                } catch {
                    
                    print(error)
                }
            }
            
            semaphore.signal()
            
        }
        
        apiRequest.resume()
        semaphore.wait(timeout: .distantFuture)
        
        print("Fin getPositionCar func")
        return carState!
        
    }
    
    public static func sendUserLocation(Login login:String, Password pass:String, Location location:CLLocationCoordinate2D) -> Bool {
        //return false
        var reponse: Bool = false
        print("Debut sendUserLocation func")
        let request = NSMutableURLRequest(url: URL(string: self.baseUrl)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let semaphore = DispatchSemaphore(value: 0)
        let postString = "action=updatePosition&login=" + login + "&password=" + pass + "&latitude=" + String(location.latitude) + "&longitude=" + String(location.longitude)
        request.httpBody = postString.data(using: .utf8)
        let apiRequest = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if(error != nil) {print("Erreur lors de la récupération de l'api : " + error!.localizedDescription)}
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {
                print("statusCode différent de 200 : error \(httpStatus.statusCode)")
                print("Response = \(response)")
            }
            
            if( error == nil ){
                do {
                    let json = try JSONSerialization.jsonObject(with: data!,options: [.mutableContainers])
                    
                    guard let item = (json as AnyObject) as? [String: Any],
                        let succes = item["success"] as? Bool
                        else {
                            print("Error lors du décodage JSON")
                            semaphore.signal()
                            return
                    }
                    reponse = succes
                } catch {
                    
                    print(error)
                }
            }
            
            semaphore.signal()
            
        }
        
        apiRequest.resume()
        semaphore.wait(timeout: .distantFuture)
        
        print("Fin sendUserLocation func")
        return reponse
    }
}
