//
//  StudentDataSource.swift
//  On The Map
//
//  Created by Adam Cmiel on 12/12/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class StudentDataStore: NSObject {
    
    static var sharedStore = StudentDataStore()
    private var backing: [StudentInformation] = []
    var data: [StudentInformation] {
        return backing
    }
    
    var firstName: String?
    var lastName: String?
    var udacityKey: String?
    
    private var _session: JSONData?
    
    var session: JSONData? {
        get {
            return validSession() ? _session : nil
        }
        
        set(s) {
            _session = s
            setProperties()
        }
    }
    
    var hasUdacitySession: Bool {
        return session != nil
    }
    
    final private func setProperties() {
        if let key = _session?["account"]?["key"] as? String {
            udacityKey = key
        }
        
        if let key = _session?["_user"]?["first_name"] as? String {
            firstName = key
        }
        
        if let key = _session?["_user"]?["last_name"] as? String {
            lastName = key
        }
    }
    
    final private func validSession() -> Bool {
        
        do {
            if let expirationDateString = _session?["session"]?["expiration"] as? String {
                let expirationDate = try dateParserForUdacityAPIDate(expirationDateString)
                if expirationDate.timeIntervalSinceNow > 0 {
                    return true
                }
            } else {
                print("session has not expiration or is nil")
            }
            
        } catch {
            
            print("could not parse date")
            
        }
        
        print("session expired or nil")
        print(_session)
        _session = nil
        return false
    }
    
    final private func merge(data: [JSONData]) -> Self {
        backing = backing + data.map { StudentInformation($0) }
        return self
    }
    
    enum LocationDataFailingParameter {
        case Success([StudentInformationAnnotation])
        case Failure(NSError)
    }
    
    final func getStudentLocations(completion: LocationDataFailingParameter -> ()) {
        APIActions.getStudentLocations { [unowned self] result in
            switch result {
            case .Failure:
                completion(.Failure(NSError(domain: "could not get studentData results", code: 0, userInfo: nil)))
            case .Success(let studentData):
                if let dataToMerge = studentData["results"] as? [JSONData] {
                    let annotations = self.merge(dataToMerge).backing.map { StudentInformationAnnotation($0) }
                    completion(.Success(annotations))
                } else {
                    completion(.Failure(NSError(domain: "could not get studentData results", code: 0, userInfo: nil)))
                }
            }
            
        }
    }
}

private func dateParser(dateString: String) throws -> NSDate {
    return try dateParser(dateString, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
}

private func dateParserForUdacityAPIDate(dateString: String) throws -> NSDate {
    return try dateParser(dateString, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
}

private func dateParser(dateString: String, dateFormat: String) throws -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    let optionalDate = dateFormatter.dateFromString(dateString)
    if let date = optionalDate {
        return date
    } else {
        throw DateInvalid()
    }
}

private class DateInvalid: ErrorType {}

struct StudentInformation: Hashable {
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String
    let createdAt: NSDate
    let updatedAt: NSDate
    
    init(_ datum: JSONData) {
        var createdAt: NSDate
        var updatedAt: NSDate
        
        do {
            createdAt = try dateParser(datum["createdAt"]! as! String)
            updatedAt = try dateParser(datum["updatedAt"]! as! String)
        } catch {
            createdAt = NSDate()
            updatedAt = NSDate()
        }
       
        self.firstName = datum["firstName"]! as! String
        self.lastName = datum["lastName"]! as! String
        self.latitude = datum["latitude"]! as! Double
        self.longitude = datum["longitude"]! as! Double
        self.mapString = datum["mapString"]! as! String
        self.mediaURL = datum["mediaURL"]! as! String
        self.objectId = datum["objectId"]! as! String
        self.uniqueKey = datum["uniqueKey"]! as! String
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var hashValue: Int {
        get {
            return self.uniqueKey.hash
        }
    }
    
    var name: String? {
        get {
            return "\(self.firstName) \(self.lastName)"
        }
    }
    
}

class StudentInformationAnnotation: NSObject, MKAnnotation {
    let info: StudentInformation
    
    // coordinate must be KVO-able
    @objc var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude)
        }
    }
    
    var title: String? {
        get {
            return info.name
        }
    }
    
    var subtitle: String? {
        get {
            return info.mediaURL
        }
    }
    
    init(_ info: StudentInformation) {
        self.info = info
    }
}

internal func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.uniqueKey == rhs.uniqueKey
}


// comparable extension found at http://stackoverflow.com/a/28109990
private func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

private func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return rhs.compare(lhs) == .OrderedAscending
}
