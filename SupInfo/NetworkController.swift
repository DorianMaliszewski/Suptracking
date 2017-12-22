//
//  NetworkController.swift
//  SupInfo
//
//  Created by Supinfo on 20/12/2017.
//  Copyright © 2017 Supinfo. All rights reserved.
//

import Foundation

public class NetworkController {
    static let baseUrl = "http://supinfo.steve-colinet.fr/suptracking/"
    
    
    public static func Connection(Login login:String, Password pass:String){
        print("Debut Connection func")
        let request = NSMutableURLRequest(url: URL(string: self.baseUrl)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "action=login&login=" + login + "&password=" + pass
        request.httpBody = postString.data(using: .utf8)
        let apiRequest = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if(error != nil) {print("Erreur lors de la récupération de l'api : " + error!.localizedDescription)}
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {
                print("statusCode différent de 200 : error \(httpStatus.statusCode)")
                print("Response = \(response)")
            }
            
            let apiResponse = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString \(apiResponse)")
            
            if( error == nil ){
                do {
                     let json = try JSONSerialization.jsonObject(with: data!,options: [.mutableContainers])
                    
                    guard let item = (json as AnyObject) as? [String: Any],
                        let person = item["user"] as? [String: Any],
                        let id2 = person["id"] as? Int
                        else {
                            return
                    }
                    print(person)
                    let user = User(id: id2, username: person["username"]! as! String, password: person["password"]! as! String, phone: person["phone"]! as! String, lastName: person["lastname"]! as! String, firstName: person["firstname"]! as! String, postalCode: person["postalCode"]! as! String, address: person["address"]! as! String, email: person["email"]! as! String)
                } catch {
                
                    print(error)
                }
            }
            
        }
        apiRequest.resume()
        
        print(apiRequest)
    }
}
