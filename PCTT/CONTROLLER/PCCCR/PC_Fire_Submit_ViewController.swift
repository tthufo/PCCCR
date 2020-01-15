//
//  PC_Fire_Alert_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/15/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import JSONKit_NoWarning

import Photos

import PhotosUI

import DKImagePickerController

class PC_Fire_Submit_ViewController: UIViewController, UITextFieldDelegate {

   @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!
    
    var option: NSString!
    
    var indexing: Int = 0
    
    var kb: KeyBoard!

    override func viewDidLoad() {
       super.viewDidLoad()
       
       kb = KeyBoard.shareInstance()
        
        tableView.withCell("Calendar_Cell")
        
        tableView.withCell("Map_Cell")
        
        tableView.withCell("Image_Cell")

        let array: NSArray = [
            ["title":"Tọa độ", "x":"", "y":"", "img": "ic_location", "ident": "Map_Cell"],
            ["title":"Mô tả", "tag":"description", "description":"", "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Ghi chú", "tag":"note", "note":"", "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Mức độ", "status":"", "id": "1", "img": "ic_level", "ident": "Calendar_Cell"],
            ["title":"Ảnh minh họa", "data":"", "id": "1", "img": "ic_pic", "ident": "Image_Cell"],
        ]
        
        dataList = NSMutableArray.init(array: array.withMutable())
        
        self.perform(#selector(reloadData), with: nil, afterDelay: 0.5)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       kb.keyboardOff()
    }
   
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       
       kb.keyboard { (height, isOn) in
           self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOn ? (height - 100) : 0, right: 0)
       }
    }
    
    @objc func reloadData() {
        tableView.reloadData()
    }

    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
     @IBAction func didRequestUpdate() {
        print(self.dataList)
        
//        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":option!,
//                                                    "overrideAlert":"1",
//                                                    "overrideLoading":"1",
//                                                    "postFix":option!,
//                                                    "host":self], withCache: { (cacheString) in
//            if cacheString != "" {
//                self.dataList.removeAllObjects()
//
//                self.dataList.addObjects(from: (((cacheString! as NSString).objectFromJSONString() as! NSDictionary)["array"] as! NSArray) as! [Any] )
//
//                self.tableView.reloadData()
//            }
//        }, andCompletion: { (response, errorCode, error, isValid, object) in
//            let result = response?.dictionize() ?? [:]
//
//            if error != nil {
//                return
//            }
//
//            self.dataList.removeAllObjects()
//
//            self.dataList.addObjects(from: (result["array"] as! NSArray) as! [Any])
//
//            self.tableView.reloadData()
//        })
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        let info = (textField.accessibilityLabel as! NSString).objectFromJSONString() as! NSDictionary
        
        let key = info["key"]
        
        let index = info["index"]
        
        (dataList![index as! Int] as! NSMutableDictionary)[key] = textField.text
    }
    
    func getMenuList() -> [Any] {
        return [
            ["title": "Chưa xác định", "id": "1"],
            ["title": "Có nguy cơ cháy cao", "id": "2"],
            ["title": "Đang cháy ở mức độ nhỏ", "id": "3"],
            ["title": "Đang cháy ở mức độ nguy hiểm", "id": "4"],
            ["title": "Đang cháy ở mức độ cực kỳ nguy hiểm", "id": "5"],
        ]
    }
    
    func getUIImage(asset: PHAsset) -> NSString? {
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img?.imageString() as NSString?
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func didGetImage() {
        let pickerController = DKImagePickerController()

        pickerController.assetType = .allPhotos
        
//        pickerController.sourceType = [.photo, .camera]
        
        pickerController.singleSelect = true
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
           
//           self.dataList.removeAllObjects()
           
           for asset in assets {
               if asset.type == .video {
//                   let resourse = PHAssetResource.assetResources(for: asset.originalAsset!)
//
//                   let url = resourse.first?.originalFilename
//
//                   var sizeOnDisk: Int64? = 0
//
//                   if let resource = resourse.first {
//                     let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
//                     sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
//                   }
//
//                   if Float(sizeOnDisk!) / (1024 * 1024) <= 30 {
//                       PHImageManager.default().requestAVAsset(forVideo: asset.originalAsset!, options: nil, resultHandler: { (asset, mix, nil) in
//                           let myAsset = asset as? AVURLAsset
//                           do {
//                               let videoData = try Data(contentsOf: (myAsset?.url)!)
//                               self.dataList.add(["fileName": url, "file": String(decoding: videoData, as: UTF8.self)])
//                           } catch  {
//                               print("exception catch at block - while uploading video")
//                           }
//                           DispatchQueue.main.async {
//                               self.tableViewFiles.reloadData()
//                           }
//                       })
//                   } else {
//                       self.showToast(url! + " dung lượng lớn hơn 30MB", andPos: 0)
//                   }
               } else {
                  let resourse = PHAssetResource.assetResources(for: asset.originalAsset!)

                  let url = resourse.first?.originalFilename
                                                 
                  (self.dataList[4] as! NSMutableDictionary)["data"] = self.getUIImage(asset: asset.originalAsset!)
                
                  self.tableView.reloadData()
             }
           }
        }

        self.present(pickerController, animated: true) {

        }
    }
}

extension PC_Fire_Submit_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = dataList[indexPath.row] as! NSDictionary

        return data.getValueFromKey("ident") == "Calendar_Cell" ? UITableView.automaticDimension : 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataList[indexPath.row] as! NSDictionary

        let cell  = tableView.dequeueReusableCell(withIdentifier: data.getValueFromKey("ident"), for: indexPath)
                
        let ava = self.withView(cell, tag: 11) as! UIImageView

        ava.image = UIImage.init(named: data.getValueFromKey("img"))


        let contentRight = self.withView(cell, tag: 12) as! UILabel

        contentRight.text = data.getValueFromKey("title")

        
        
        if data.getValueFromKey("ident") == "Calendar_Cell" {
            let input = self.withView(cell, tag: 14) as! UITextField

            input.delegate = self
            
            input.text = data.getValueFromKey(data.getValueFromKey("tag"))

            input.isHidden = data.getValueFromKey("input") == ""
            
            input.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)

            input.accessibilityLabel = (["key":data.getValueFromKey(data.getValueFromKey("tag")), "index": indexPath.row] as! NSDictionary).jsonString()
            
            
            
            
            
            let button = self.withView(cell, tag: 15) as! UIButton

            button.widthConstaint?.constant = 0
            
            
            
            
            
            let menu = self.withView(cell, tag: 16) as! DropButton
            
            menu.isHidden = data.getValueFromKey("input") != ""
            
            menu.action(forTouch: [:]) { (objc) in
                menu.didDropDown(withData: self.getMenuList()) { (objc) in
                    if objc != nil {
                        let title = ((objc as! NSDictionary)["data"] as! NSDictionary)["title"]
                        
                        let id = ((objc as! NSDictionary)["data"] as! NSDictionary)["id"]
                               
                        (self.dataList[indexPath.row] as! NSMutableDictionary)["id"] = id
                        
                        menu.setTitle((title as! String), for: .normal)
                    }
                }
            }
        }
        if data.getValueFromKey("ident") == "Map_Cell" {
            (cell as! Map_Cell).tempLocation = [["lat": self.latLng.getValueFromKey("lat"), "lng": self.latLng.getValueFromKey("lng")]]


            let x = self.withView(cell, tag: 14) as! UITextField

//            x.text = data.getValueFromKey("x")

            x.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)

            x.accessibilityLabel = (["key":"x", "index": indexPath.row] as! NSDictionary).jsonString()


            let y = self.withView(cell, tag: 15) as! UITextField

//            y.text = data.getValueFromKey("y")

            y.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)

            y.accessibilityLabel = (["key":"y", "index": indexPath.row] as! NSDictionary).jsonString()
        }
        
        if data.getValueFromKey("ident") == "Image_Cell" {

            let image = self.withView(cell, tag: 18) as! UIImageView

            if ((self.dataList[indexPath.row] as! NSMutableDictionary)["data"] as! String) != "" {
                image.image = ((self.dataList[indexPath.row] as! NSMutableDictionary)["data"] as! String).stringImage()
            }
            
            image.action(forTouch: [:]) { (objc) in
                self.didGetImage()
            }
        }
                
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
    }
}
