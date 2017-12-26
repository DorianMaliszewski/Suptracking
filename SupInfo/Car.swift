//
//  Car.swift
//  SupInfo
//
//  Created by Supinfo on 25/12/2017.
//  Copyright © 2017 Supinfo. All rights reserved.
//

import Foundation
import CoreLocation


public struct Car {
    
    private var _speed:Int
    private var _location:CLLocationCoordinate2D
    
    public init(){
        self._speed = 0
        self._location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    public init(speed:Int ,location:CLLocationCoordinate2D){
        self._speed = speed
        self._location = location
    }
    
    public var Speed:Int{
        get{
            return _speed
        }
        mutating set{
            self._speed = newValue
        }
    }
    
    public var Location:CLLocationCoordinate2D{
        get{
            return _location
        }
        mutating set{
            self._location = newValue
        }
    }
}
