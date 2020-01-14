//
//  Map_Cell.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/14/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import Mapbox

import CoreLocation

import GLKit

class Map_Cell: UITableViewCell {

    @IBOutlet var mapBox: MGLMapView!
      
    @IBOutlet var ava: UIImageView!
    
    @IBOutlet var title: UILabel!

    @IBOutlet var lat: UITextField!

    @IBOutlet var lng: UITextField!

    var tempLocation: [[String:String]]! = []

    var coor = [CLLocationCoordinate2D]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapBox.logoView.isHidden = true
               
        mapBox.attributionButton.isHidden = true
        
        print(tempLocation)
        
        coor.removeAll()
               
               if tempLocation.count != 0 {
                   for dict in tempLocation {
                       coor.append(CLLocationCoordinate2D(latitude: (dict["lat"]! as NSString).doubleValue , longitude: (dict["lng"]! as NSString).doubleValue))
                   }
                   self.perform(#selector(showMarkers), with: nil, afterDelay: 0.5)
               }
    }
    
    override func prepareForReuse() {
        coor.removeAll()

        if tempLocation.count != 0 {
            for dict in tempLocation {
                coor.append(CLLocationCoordinate2D(latitude: (dict["lat"]! as NSString).doubleValue , longitude: (dict["lng"]! as NSString).doubleValue))
            }
            self.perform(#selector(showMarkers), with: nil, afterDelay: 0.5)
        }
    }

    @objc func showMarkers() {
        if let annotations = mapBox.annotations {
            mapBox.removeAnnotations(annotations)
        }
        
        for i in stride(from: 0, to: self.coor.count, by: 1) {
            let marker = MGLPointAnnotation()

            marker.coordinate = self.coor[i]

//            marker.title = information.getValueFromKey("description")
//            marker.subtitle = information.getValueFromKey("level")
            
            mapBox.addAnnotation(marker)
        }

//        mapBox.setVisibleCoordinates(&coor, count: UInt(coor.count), edgePadding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), animated: false)
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

extension Map_Cell: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if annotation is MGLUserLocation {
            var userLocationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "direction_arrow") as? CustomUserLocationAnnotationView2
            
            if userLocationAnnotationView == nil {
                userLocationAnnotationView = CustomUserLocationAnnotationView2(reuseIdentifier: reuseIdentifierForAnnotation(annotation: annotation))
            }

            return userLocationAnnotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        let reuseIdentifier = reuseIdentifierForAnnotation(annotation: annotation)
                
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)
        
        if annotationImage == nil {
            let image = imageForAnnotation(annotation: annotation)
            
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
        }
                
        return annotationImage
    }
    
    func reuseIdentifierForAnnotation(annotation: MGLAnnotation) -> String {
        var reuseIdentifier = "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
        if let title = annotation.title, title != nil {
            reuseIdentifier += title!
        }
        if let subtitle = annotation.subtitle, subtitle != nil {
            reuseIdentifier += subtitle!
        }
        
        return reuseIdentifier
    }
    
    func imageForAnnotation(annotation: MGLAnnotation) -> UIImage {
        return UIImage(named: "ic_fire")!
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

final class CustomUserLocationAnnotationView2: MGLUserLocationAnnotationView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let imageView = UIImageView(image: UIImage(named: "direction_arrow"))
        self.addSubview(imageView)
        self.frame = imageView.frame
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scalesWithViewingDistance = false
        
        layer.contentsScale = UIScreen.main.scale
        layer.contentsGravity = CALayerContentsGravity.center
        
        layer.contents = UIImage(named: "direction_arrow")?.cgImage
    }
}
