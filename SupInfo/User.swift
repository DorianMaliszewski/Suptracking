//
//  User.swift
//  SupInfo
//
//  Created by Supinfo on 20/12/2017.
//  Copyright © 2017 Supinfo. All rights reserved.
//

import Foundation

public struct User {
    
    private var _id:Int
    private var _username:String
    private var _password:String
    private var _phone:String
    private var _lastName:String
    private var _firstName:String
    private var _postalCode:String
    private var _address:String
    private var _email:String
    
    public init(){
        self._id = 0
        self._username = "username"
        self._password = "password"
        self._phone = "phone"
        self._lastName = "lastName"
        self._firstName = "firstName"
        self._postalCode = "postalCode"
        self._address = "address"
        self._email = "email"
    }
    
    public init(id:Int, username:String, password:String, phone:String, lastName:String, firstName:String, postalCode:String, address:String, email:String){
        self._id = id
        self._username = username
        self._password = password
        self._phone = phone
        self._lastName = lastName
        self._firstName = firstName
        self._postalCode = postalCode
        self._address = address
        self._email = email
    }
    
    public var Id:Int{
        get{
            return _id
        }
        mutating set{
            self._id = newValue
        }
    }
    
    public var UserName:String{
        get{
            return _username
        }
        mutating set{
            self._username = newValue
        }
    }
    
    public var Password:String{
        get{
            return _password
        }
        mutating set{
            self._password = newValue
        }
    }
    
    public var Phone:String{
        get{
            return _phone
        }
        mutating set{
            self._phone = newValue
        }
    }
    
    public var LastName:String{
        get{
            return _lastName
        }
        mutating set{
            self._lastName = newValue
        }
    }
    
    public var FirstName:String{
        get{
            return _firstName
        }
        mutating set{
            self._firstName = newValue
        }
    }
    
    public var PostalCode:String{
        get{
            return _postalCode
        }
        mutating set{
            self._postalCode = newValue
        }
    }
    
    public var Address:String{
        get{
            return _address
        }
        mutating set{
            self._address = newValue
        }
    }
    
    public var Email:String{
        get{
            return _email
        }
        mutating set{
            self._email = newValue
        }
    }
    
}
