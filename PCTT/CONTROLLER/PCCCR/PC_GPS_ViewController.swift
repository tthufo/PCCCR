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

import GLKit

//protocol MapDelegate:class {
//    func didReloadData(data: NSArray, indexing: String)
//}

class PC_GPS_ViewController: UIViewController {

//    weak var delegate: MapDelegate?

    @IBOutlet var mapBox: MGLMapView!
    
    var indexing: String!
    
    var tempLocation: [[String:String]] = []

    var progressView: UIProgressView!

    var coor = [CLLocationCoordinate2D]()

    var isMulti: Bool = false
    
    var isTimer: Bool = false
    
    var inPolyline: Bool = false
    
    var inPolygon: Bool = false

    var mutliType: String = "Point"
    
    @IBOutlet var addPoint: UIButton!
    
    @IBOutlet var addLine: UIButton!
    
    @IBOutlet var addPolygon: UIButton!
    
    @IBOutlet var addFire: UIButton!

    @IBOutlet var countDown: UILabel!

    var timer: Timer!
    
    var count = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapBox.logoView.isHidden = true
        
        mapBox.attributionButton.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onMapSingleTapped(recognizer:)))
        
        mapBox.addGestureRecognizer(tap)
        
        if self.getValue("offline") == nil {
            self.addValue("0", andKey: "offline")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
        
        self.reloadType()
    }

    func reloadType () {
        isMulti = self.mutliType != "Point"
        
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
    }
    
    @IBAction func didPressGoBack() {
        if self.timer != nil {
            self.timer.invalidate()
            
            self.timer = nil
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressAddPoint() {
        self.isMulti = false
        self.mutliType = "Point"
        removeAll()
        let submit = PC_Fire_Submit_ViewController()
        submit.isGPS = true
        submit.infor = ["lat": self.latLng().latitude, "lon": self.latLng().longitude, "description": "", "level": "Chưa xác định"]
        self.navigationController?.pushViewController(submit, animated: true)
    }
    
    @IBAction func didPressAddLine() {
        if inPolyline {
            processUpdate()
            return
        }
        DropAlert.shareInstance()?.alert(withInfor: ["title":"Thông báo", "cancel":"Tự động", "message":"Bắt đầu cập nhật đường cháy. \n - Chọn [Tự động] ứng dụng sẽ tự thêm vị trí GPS vào đường. \n - Chọn [Bằng tay] để tự chọn đường, ấn nút [+] để thêm điểm trên bản đồ. \n - Ấn nút [Cập nhật đường] lần nữa để kết thúc.", "buttons":["Bằng tay"]], andCompletion: { (index, objc) in
            self.isMulti = true
            self.mutliType = "Polyline"
            self.removeAll()
            if index == 0 {
                self.addFire.isHidden = false
            } else {
                self.didPressTimer()
            }
            self.inPolyline = true
            self.inPolygon = false
        })
    }
    
    @IBAction func didPressAddPolygon() {
        if inPolygon {
            processUpdate()
            return
        }
        DropAlert.shareInstance()?.alert(withInfor: ["title":"Thông báo", "cancel":"Tự động", "message":"Bắt đầu cập nhật vùng cháy. \n - Chọn [Tự động] ứng dụng sẽ tự thêm vị trí GPS vào đường. \n - Chọn [Bằng tay] để tự chọn đường, ấn nút [+] để thêm điểm trên bản đồ. \n - Ấn nút [Cập nhật vùng] lần nữa để kết thúc.", "buttons":["Bằng tay"]], andCompletion: { (index, objc) in
            self.isMulti = true
            self.mutliType = "Polygon"
            self.removeAll()
            if index == 0 {
                self.addFire.isHidden = false
            } else {
                self.didPressTimer()
            }
            self.inPolygon = true
            self.inPolyline = false
        })
    }
    
    @IBAction func didPressAddFirePoint() {
      
        let marker = MGLPointAnnotation()
        
        marker.title = ""
        
        marker.subtitle = ""
        
        marker.accessibilityLabel = "fire"
        
        marker.coordinate = CLLocationCoordinate2D(latitude: self.latLng().latitude , longitude: self.latLng().latitude)
        
        mapBox.addAnnotation(marker)
        
        coor.append(CLLocationCoordinate2D(latitude: self.latLng().latitude , longitude: self.latLng().longitude))

        tempLocation.append(["lat":"%f".format(parameters: self.latLng().latitude), "lng":"%f".format(parameters: self.latLng().longitude)])
        
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
    
    func resetCount() {
        let minutes = 1//self.getObject("timer")["time"]
        
        count = Int(minutes as! NSNumber) * 5
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
    
    @objc func showMarkers() {
        if let annotations = mapBox.annotations {
            mapBox.removeAnnotations(annotations)
        }

        for cor in self.coor {
            let marker = MGLPointAnnotation()

            marker.coordinate = cor

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
    
    func removeAll() {
        if let annotations = mapBox.annotations {
           mapBox.removeAnnotations(annotations)
       }
        
        coor.removeAll()
        
        tempLocation.removeAll()
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
    
    func processUpdate() {
        
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
        
        if self.timer != nil {
             self.timer.invalidate()
             
             self.timer = nil
         }
        
        DropAlert.shareInstance()?.alert(withInfor: ["title":"Thông báo", "cancel":"Hủy bỏ", "message":"Kết thúc cập nhật" + (mutliType == "Polygon" ? " vùng " : " đường ") + "cháy \n - Bạn có muốn cập nhật" +  (mutliType == "Polygon" ? " vùng " : " đường ") + "cháy này ko?", "buttons":["Cập nhật"]], andCompletion: { (index, objc) in
            if index == 0 {
                var pointing: [[String:String]] = []

                for dict in self.tempLocation {
                    pointing.append(["x": dict["lat"]!, "y": dict["lng"]!])
                }
                
               let multi = PC_Fire_Submit_ViewController()
               multi.infor = ["points": pointing]
               multi.option = (self.mutliType == "Polygon" ? "CreatePolygon" : "CreateLine")
               self.navigationController?.pushViewController(multi, animated: true)
            } else {
                
            }
            self.inPolygon = false
            
            self.inPolyline = false
            
            self.isTimer = false
            
            self.countDown.isHidden = true
            
            self.addFire.isHidden = true
            
            self.removeAll()
        })
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
        return false //(self.topMost().isKind(of: QL_Form_New_ViewController.self))
    }
}

extension PC_GPS_ViewController: MGLMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        if (self.getValue("offline") != nil) && self.getValue("offline") == "0" {
            startOfflinePackDownload()
        }
        
        mapBox.showsUserLocation = true
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if annotation is MGLUserLocation {
            var userLocationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "direction_arrow") as? CustomUserLocationAnnotationView3
            
            if userLocationAnnotationView == nil {
                userLocationAnnotationView = CustomUserLocationAnnotationView3(reuseIdentifier: reuseIdentifierForAnnotation(annotation: annotation))
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
        return UIImage(named: (annotation as! MGLPointAnnotation).accessibilityLabel == "fire" ? "marker_fire" : "marker_fire")!
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

final class CustomUserLocationAnnotationView3: MGLUserLocationAnnotationView {
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
