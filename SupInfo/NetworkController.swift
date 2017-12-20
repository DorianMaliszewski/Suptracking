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
                var json: Any
                do {
                    json = try JSONSerialization.jsonObject(with: data!)
                    
                    guard let item = (json as AnyObject) as? [String: Any],
                        let person = item["user"] as? [String: Any] else {
                            return
                    }
                    
                    print(person["id"]!)
                } catch {
                
                    print(error)
                }
            }
            
        }
        apiRequest.resume()
        
        print(apiRequest)
    }
}
