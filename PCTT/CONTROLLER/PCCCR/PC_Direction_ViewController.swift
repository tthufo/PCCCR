//
//  QL_Map_ViewController.swift
//  QLDT
//
//  Created by Thanh Hai Tran on 9/12/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

import UIKit

import Mapbox

import CoreLocation


//protocol MapDelegate:class {
//    func didReloadData(data: NSArray, indexing: String)
//}

class PC_Direction_ViewController: UIViewController {

//    weak var delegate: MapDelegate?

    @IBOutlet var mapBox: MGLMapView!
    
    var information: NSDictionary!
    
    var indexing: String!
    
    var tempLocation: [[String:String]] = []

    var progressView: UIProgressView!

    var coor = [CLLocationCoordinate2D]()

    var isMulti: Bool = false
    
    var isTimer: Bool = false
    
    var isForShow: Bool = false
    
    var mutliType: String = "Point"
    
    @IBOutlet var auto: UIButton!
    
    @IBOutlet var delete: UIButton!
    
    @IBOutlet var save: UIButton!
    
    @IBOutlet var countDown: UILabel!

    var timer: Timer!
    
    var count = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapBox.logoView.isHidden = true
        
        mapBox.attributionButton.isHidden = true
        
//        tempLocation = [["lat": self.latLng.getValueFromKey("lat"), "lng": self.latLng.getValueFromKey("lng")], ["lat": information.getValueFromKey("lat"), "lng": information.getValueFromKey("lon")]]
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onMapSingleTapped(recognizer:)))
        
//        mapBox.addGestureRecognizer(tap)
        
        if self.getValue("offline") == nil {
            self.addValue("0", andKey: "offline")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
        
        self.reloadType()
    }

    @IBAction func didPressGoBack() {
        if timer != nil {
            timer.invalidate()
            
            timer = nil
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reloadType () {
        isMulti = self.mutliType != "Point"
        
//        auto.isHidden = !isMulti
        
//        delete.isHidden = !isMulti
                
        tempLocation = [["lat": self.latLng.getValueFromKey("lat"), "lng": self.latLng.getValueFromKey("lng")], ["lat": information.getValueFromKey("lat"), "lng": information.getValueFromKey("lon")]]

        coor.removeAll()
        
        if tempLocation.count != 0 {
            for dict in tempLocation {
                coor.append(CLLocationCoordinate2D(latitude: (dict["lat"]! as NSString).doubleValue , longitude: (dict["lng"]! as NSString).doubleValue))
            }
            if self.getValue("offline") == "1" {
                self.perform(#selector(showMarkers), with: nil, afterDelay: 0.5)
            } else {
                didPressLocation()
            }
        } else {
            didPressLocation()
        }
        
//        save.isHidden = isForShow
        getDistance()
    }
    
    func resetCount() {
        let minutes = self.getObject("timer")["time"]
        
        count = Int(minutes as! NSNumber) * 60
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
        super.viewWillDisappear(animated)
        
        self.hideSVHUD()
    }
    
    func endTimer() {
        if !isForm() {return}
        
        if timer != nil {
            timer.invalidate()
            
            timer = nil
        }
    }
    
    @objc func update() {
        
        if(count == 0) {
            
            let marker = MGLPointAnnotation()
            
            marker.title = ""
            
            marker.subtitle = ""
            
            marker.coordinate = latLng()
            
            mapBox.addAnnotation(marker)
            
            coor.append(latLng())
            
            tempLocation.append(["lat":"%f".format(parameters: latLng().latitude), "lng":"%f".format(parameters: latLng().longitude)])
            
            if self.mutliType == "Polyline" {
                let myTourline = MGLPolyline(coordinates: &self.coor, count: UInt(self.coor.count))
                
                mapBox.addAnnotation(myTourline)
                
                if tempLocation.count >= 2 {
                    self.updateLocation()
                }
            } else {
                let myTourline = MGLPolygon(coordinates: &self.coor, count: UInt(self.coor.count))
                
                mapBox.addAnnotation(myTourline)
                
                if tempLocation.count >= 3 {
                    self.updateLocation()
                }
            }
            
            resetCount()

            timer.invalidate()
            
            timer = nil
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(update), userInfo: nil, repeats: true)
        }
        
        let minutes = String(count / 60)
        let seconds = String(count % 60)
        countDown.text = (Int(minutes)! < 10 ? "0" : "") + minutes + ":" + (Int(seconds)! < 10 ? "0" : "") + seconds
        count -= 1
    }
    
    func getDistance() {
        let locA = CLLocation(latitude: ("%f".format(parameters: latLng().latitude) as NSString).doubleValue, longitude: ("%f".format(parameters: latLng().longitude) as NSString).doubleValue)

        let locB = CLLocation(latitude: ("%@".format(parameters: information.getValueFromKey("lat")) as NSString).doubleValue, longitude: ("%@".format(parameters: information.getValueFromKey("lon")) as NSString).doubleValue)

        let distance = locA.distance(from: locB)
        
        countDown.text = String(format: " %.f m ", distance)
    }
    
    @objc func showMarkers() {
        
        if let annotations = mapBox.annotations {
            mapBox.removeAnnotations(annotations)
        }
        
//        for cor in self.coor {
        for i in stride(from: 0, to: self.coor.count, by: 1) {
            let marker = MGLPointAnnotation()

            marker.coordinate = self.coor[i]
            
            if i != 0 {
                marker.title = information.getValueFromKey("description")
                marker.subtitle = information.getValueFromKey("level")
            } else {
                marker.title = ""
                marker.subtitle = ""
            }
            
            marker.accessibilityLabel = i == 0 ? "" : "fire"

            mapBox.addAnnotation(marker)
        }

        if isMulti {
            if self.mutliType == "Polyline" {
                let myTourline = MGLPolyline(coordinates: &self.coor, count: UInt(self.coor.count))
                
                mapBox.addAnnotation(myTourline)
            } else {
                let myTourline = MGLPolygon(coordinates: &self.coor, count: UInt(self.coor.count))
                
                mapBox.addAnnotation(myTourline)
            }
        }

        mapBox.setVisibleCoordinates(&coor, count: UInt(coor.count), edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), animated: false)
        
        if timer != nil {
            timer.invalidate()
            
            timer = nil
        }
                        
        timer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector:#selector(reloadType), userInfo: nil, repeats: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.hideSVHUD()
    }
    
    func startOfflinePackDownload() {
        
        let region = MGLTilePyramidOfflineRegion(styleURL: mapBox.styleURL, bounds: mapBox.visibleCoordinateBounds, fromZoomLevel: mapBox.zoomLevel, toZoomLevel: 16)
        
        let userInfo = ["name": "My Offline Pack"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        
        MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                // The pack couldn’t be created for some reason.
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            pack!.resume()
        }
    }
    
    @objc func offlinePackProgressDidChange(notification: NSNotification) {

        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: .default)
                let frame = view.bounds.size
                progressView.frame = CGRect(x: frame.width / 4, y: frame.height * 0.75, width: frame.width / 2, height: 10)
                //view.addSubview(progressView)
            }
            
            progressView.progress = progressPercentage
            
            self.showSVHUD("Đang tải bản đồ offline, bạn vui lòng chờ (chỉ tải 1 lần duy nhất)", andProgress: progressPercentage)
            
            if completedResources == expectedResources {
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
                print("Offline pack “\(userInfo["name"] ?? "unknown")” completed: \(byteCount), \(completedResources) resources")
                self.hideSVHUD()
                self.addValue("1", andKey: "offline")
                if tempLocation.count != 0 {
                    self.perform(#selector(showMarkers), with: nil, afterDelay: 0.5)
                }
            } else {
                print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    @objc func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
            self.hideSVHUD()
        }
    }
    
    @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
            self.hideSVHUD()
        }
    }
    
    @objc func onMapSingleTapped(recognizer: UITapGestureRecognizer)
    {
        let viewLocation: CGPoint = recognizer.location(in: mapBox)
        
        if(mapBox.annotations != nil)
        {
            for annotation in mapBox.annotations!
            {
                if(annotation.isKind(of: MGLAnnotation.self))
                {
                    return
                }
            }
        }
        
        if let annotations = mapBox.annotations {
            if !isMulti {
                mapBox.removeAnnotations(annotations)
            }
        }
        
        let mapLocation: CLLocationCoordinate2D = mapBox.convert(viewLocation, toCoordinateFrom: mapBox)
        
        let marker = MGLPointAnnotation()
        
        marker.title = ""
        
        marker.subtitle = ""
        
        marker.coordinate = CLLocationCoordinate2D(latitude: mapLocation.latitude , longitude: mapLocation.longitude)
        
        mapBox.addAnnotation(marker)
        
        if !isMulti {
            coor.removeAll()
            
            tempLocation.removeAll()
        }
        
        coor.append(CLLocationCoordinate2D(latitude: mapLocation.latitude , longitude: mapLocation.longitude))

        tempLocation.append(["lat":"%f".format(parameters: mapLocation.latitude), "lng":"%f".format(parameters: mapLocation.longitude)])
        
        if isMulti {
            if self.mutliType == "Polyline" {
                let myTourline = MGLPolyline(coordinates: &self.coor, count: UInt(self.coor.count))
                
                mapBox.addAnnotation(myTourline)
                
                if tempLocation.count >= 2 {
                    self.updateLocation()
                }
            } else {
                let myTourline = MGLPolygon(coordinates: &self.coor, count: UInt(self.coor.count))
                
                mapBox.addAnnotation(myTourline)
                
                if tempLocation.count >= 3 {
                    self.updateLocation()
                }
            }
        } else {
            self.updateLocation()
        }
    }
    
    func updateLocation() {
        if !isForm() {return}
        
//        ((self.topMost() as! QL_Form_New_ViewController).controllers.firstObject as! QL_Crash_ViewController).updateLocation(data: ["tempLocation":self.tempLocation, "type":self.mutliType])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didPressBack() {
        
        if isMulti {
            if self.mutliType == "Polyline" {
                if tempLocation.count < 2 {
                    self.showToast("Tọa độ cần chọn ít nhất 2 điểm", andPos: 0)
                    
                    return
                }
            } else {
                if tempLocation.count < 3 {
                    self.showToast("Tọa độ cần chọn ít nhất 3 điểm", andPos: 0)
                    
                    return
                }
            }
        }
        
//        delegate?.didReloadData(data: tempLocation as NSArray, indexing: self.indexing)
        
        self.dismiss(animated: true) {
            if self.timer != nil {
                self.timer.invalidate()
                
                self.timer = nil
            }
        }
    }
    
    func latLng() -> CLLocationCoordinate2D {
       let currentCorr = Permission.shareInstance().currentLocation()
        
        return CLLocationCoordinate2D(latitude: (currentCorr!["lat"]! as! NSNumber).doubleValue , longitude: (currentCorr!["lng"]! as! NSNumber).doubleValue)
    }
    
    @IBAction func didPressLocation() {
        mapBox.setCenter(latLng(), zoomLevel: 15, animated: false)
    }
    
    @IBAction func didPressTimer() {
        
        self.countDown.isHidden = self.isTimer
        
        if !isTimer {
            resetCount()

            if timer != nil {
                timer.invalidate()
                
                timer = nil
            }
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(update), userInfo: nil, repeats: true)
        } else {
            if timer != nil {
                timer.invalidate()
                
                timer = nil
            }
            
            countDown.text = "00:00"
        }
        
        self.isTimer = !self.isTimer
    }
    
    @IBAction func didPressClear() {
        if let annotations = mapBox.annotations {
            mapBox.removeAnnotations(annotations)
        }
        
        coor.removeAll()
        
        tempLocation.removeAll()
        
        self.updateLocation()
    }
    
    func isForm() -> Bool {
        return true// (self.topMost().isKind(of: QL_Form_New_ViewController.self))
    }
}

extension PC_Direction_ViewController: MGLMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        if (self.getValue("offline") != nil) && self.getValue("offline") == "0" {
            startOfflinePackDownload()
        }
        
        mapBox.showsUserLocation = true
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if annotation is MGLUserLocation {
            var userLocationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "direction_arrow") as? CustomUserLocationAnnotationView1
            
            if userLocationAnnotationView == nil {
                userLocationAnnotationView = CustomUserLocationAnnotationView1(reuseIdentifier: reuseIdentifierForAnnotation(annotation: annotation))
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

        var imageName = ""
            if let title = annotation.title, title != nil {
           switch title! {
           case "":
               imageName = "trans"
           default:
               imageName = "ic_fire"
           }
       }
            
        print(imageName)
        
       return UIImage(named: imageName)!
//        return UIImage(named: (annotation as! MGLPointAnnotation).accessibilityLabel == "" ? "trans" : "ic_fire")!
    }
    
    func imageForAnnotationArrow(annotation: MGLAnnotation) -> UIImage {
        return UIImage(named: "direction_arrow")!
    }
    
    func imageForAnnotationTrans(annotation: MGLAnnotation) -> UIImage {
        return UIImage(named: "trans")!
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

final class CustomUserLocationAnnotationView1: MGLUserLocationAnnotationView {
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
