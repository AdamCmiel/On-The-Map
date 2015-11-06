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
    
    static let sharedStore = StudentDataStore()
    
    var session: JSONData? = nil
    var hasUdacitySession: Bool {
        get { return session != nil }
    }
    
    private var backing: [StudentInformation] = []
    
    func merge(data: [JSONData]) -> Self {
        backing = backing + data.map { StudentInformation($0) }
        return self
    }
    
    func sort() -> [StudentInformation] {
        // remove duplicates
        backing = uniq(backing).sort { return $0.updatedAt < $1.updatedAt }
        return backing
    }
    
    func getStudentLocations(completion: [MKAnnotation] -> ()) {
        APIActions.getStudentLocations { [unowned self] result in
            switch result {
            case .Failure:
                fatalError("error getting student locations")
            case .Success(let studentData):
                if let dataToMerge = studentData["results"] as? [JSONData] {
                    let annotations = self.merge(dataToMerge).sort().map { StudentInformationAnnotation($0) }
                    completion(annotations)
                } else {
                    fatalError("could not get studentData results")
                }
            }
            
        }
    }
}

private let dateParser: String -> NSDate? = ({
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return NSDateFormatter.dateFromString(dateFormatter)
})()

struct StudentInformation: Hashable {
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String?
    let objectId: String
    let uniqueKey: String
    let createdAt: NSDate
    let updatedAt: NSDate
    
    init(_ datum: JSONData) {
        let createdAt: NSDate = dateParser(datum["createdAt"]! as! String)!
        let updatedAt: NSDate = dateParser(datum["updatedAt"]! as! String)!
       
        self.firstName = datum["firstName"]! as! String
        self.lastName = datum["lastName"]! as! String
        self.latitude = datum["latitude"]! as! Double
        self.longitude = datum["longitude"]! as! Double
        self.mapString = datum["mapString"]! as! String
        self.mediaURL = datum["mediaUrl"] as? String
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
            return info.mapString
        }
    }
    
    var subtitle: String? {
        get {
            return "\(info.firstName) \(info.lastName)"
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

private func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

// uniq method taken from http://stackoverflow.com/a/25739498
private func uniq<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
    var buffer = [T]()
    var added = Set<T>()
    for elem in source {
        if !added.contains(elem) {
            buffer.append(elem)
            added.insert(elem)
        }
    }
    return buffer
}