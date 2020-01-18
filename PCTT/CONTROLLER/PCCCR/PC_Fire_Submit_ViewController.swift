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

import DatePickerDialog

class PC_Fire_Submit_ViewController: UIViewController, UITextFieldDelegate {

   @IBOutlet var tableView: UITableView!

    @IBOutlet var backButton: UIButton!

    var dataList: NSMutableArray!
    
    var option: NSString!
    
    var infor: NSDictionary!

    var indexing: Int = 0
    
    var kb: KeyBoard!
    
    var isGPS: Bool = false

    override func viewDidLoad() {
       super.viewDidLoad()
       
        kb = KeyBoard.shareInstance()
        
        tableView.withCell("Calendar_Cell")
        
        tableView.withCell("Map_Cell")
        
        tableView.withCell("Image_Cell")

        let dateNow = NSDate.init()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let multi: NSArray = [
            ["title":"Tên", "tag":"note", "note":"", "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Thời gian bắt đầu cháy", "tag":"start", "start": formatter.string(from: dateNow as Date), "input":"1", "img": "ic_time", "ident": "Calendar_Cell"],
            ["title":"Mô tả", "tag":"description", "description":infor.getValueFromKey("description"), "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Tọa độ", "x":infor.getValueFromKey("lat"), "y":infor.getValueFromKey("lon"), "img": "ic_location", "ident": "Map_Cell"]
        ]
        
        let gps: NSArray = [
            ["title":"Tọa độ", "x":infor.getValueFromKey("lat"), "y":infor.getValueFromKey("lon"), "img": "ic_location", "ident": "Map_Cell"],
            ["title":"Mô tả", "tag":"description", "description":infor.getValueFromKey("description"), "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Ghi chú", "tag":"note", "note":"", "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Mức độ", "level":infor.getValueFromKey("level"), "id": self.levelId(level: infor.getValueFromKey("level")), "img": "ic_level", "ident": "Calendar_Cell"],
        
            ["title":"Ảnh minh họa", "data":"", "img": "ic_pic", "ident": "Image_Cell"],
        ]
        
        let array: NSArray = [
            ["title":"Tọa độ", "x":infor.getValueFromKey("lat"), "y":infor.getValueFromKey("lon"), "img": "ic_location", "ident": "Map_Cell"],
            ["title":"Mô tả", "tag":"description", "description":infor.getValueFromKey("description"), "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Ghi chú", "tag":"note", "note":"", "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Mức độ", "level":infor.getValueFromKey("level"), "id": self.levelId(level: infor.getValueFromKey("level")), "img": "ic_level", "ident": "Calendar_Cell"],
            
            ["title":"Thời gian bắt đầu cháy", "tag":"start", "start":infor.getValueFromKey("time_added"), "input":"1", "img": "ic_time", "ident": "Calendar_Cell"],
            ["title":"Đám cháy kết thúc", "tag":"end", "end":"", "check":"0", "input":"1", "img": "ic_time", "ident": "Calendar_Cell"],
                       
            ["title":"Diện tích thiệt hại", "tag":"area", "area":"", "input":"1", "img": "ic_area", "ident": "Calendar_Cell"],
            ["title":"Loại cây thiệt hại", "tag":"tree", "tree":"", "input":"1", "img": "ic_tree2", "ident": "Calendar_Cell"],
            ["title":"Ảnh minh họa", "data":"", "img": "ic_pic", "ident": "Image_Cell"],
        ]
        
        dataList = NSMutableArray.init(array: option != nil ? multi.withMutable() : isGPS ? gps.withMutable() : array.withMutable())
        
        self.perform(#selector(reloadData), with: nil, afterDelay: 0.5)
        
        backButton.setTitle(isGPS || option != nil ? "QUAY LẠI" : "NHẬP LẠI", for: .normal)
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
        if isGPS {
            LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"CreateFirePoint",
                                                        "lon": (dataList[0] as! NSDictionary).getValueFromKey("y"),
                                                        "lat": (dataList[0] as! NSDictionary).getValueFromKey("x"),
                                                        "description": (dataList[1] as! NSDictionary).getValueFromKey("description"),
                                                        "level_id": (dataList[3] as! NSDictionary).getValueFromKey("id"),
                                                        "note": (dataList[2] as! NSDictionary).getValueFromKey("note"),
                                                        "image_base64": (dataList[4] as! NSDictionary).getValueFromKey("data"),
                                                        "overrideAlert":"1",
                                                        "overrideLoading":"1",
                                                        "postFix":"CreateFirePoint",
                                                        "host":self], withCache: { (cacheString) in
            }, andCompletion: { (response, errorCode, error, isValid, object) in
                let result = response?.dictionize() ?? [:]

                if error != nil {
                    self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
                    return
                }

                self.showToast("Cập nhật thành công", andPos: 0)

                self.navigationController?.popViewController(animated: true)
            })
        } else {
            LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"UpdateFIrePoint",
                                                        "id": infor.getValueFromKey("id"),
                                                        "lon": (dataList[0] as! NSDictionary).getValueFromKey("y"),
                                                        "lat": (dataList[0] as! NSDictionary).getValueFromKey("x"),
                                                        "description": (dataList[1] as! NSDictionary).getValueFromKey("description"),
                                                        "level_id": (dataList[3] as! NSDictionary).getValueFromKey("id"),
                                                        "note": (dataList[2] as! NSDictionary).getValueFromKey("note"),
                                                        "time_updated": (dataList[4] as! NSDictionary).getValueFromKey("start"),
                                                        "is_finished": (dataList[5] as! NSDictionary).getValueFromKey("check") == "0" ? false : true,
                                                        "time_finished": (dataList[5] as! NSDictionary).getValueFromKey("end"),
                                                        "destruction_area": (dataList[6] as! NSDictionary).getValueFromKey("area"),
                                                        "destruction_tree_type": (dataList[7] as! NSDictionary).getValueFromKey("tree"),
                                                        "image_base64": (dataList[8] as! NSDictionary).getValueFromKey("data"),
                                                        "overrideAlert":"1",
                                                        "overrideLoading":"1",
                                                        "postFix":"UpdateFIrePoint",
                                                        "host":self], withCache: { (cacheString) in
            }, andCompletion: { (response, errorCode, error, isValid, object) in
                let result = response?.dictionize() ?? [:]

                if error != nil {
                    self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
                    return
                }

                self.showToast("Cập nhật thành công", andPos: 0)

                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    @IBAction func didReset() {
        if isGPS || option != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            print(self.dataList)
        }
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        let info = (textField.accessibilityLabel as! NSString).objectFromJSONString() as! NSDictionary
        
        let key = info["key"]
        
        let index = info["index"]
        
        (dataList![index as! Int] as! NSMutableDictionary)[key] = textField.text
    }
    
    func levelId(level: String) -> String {
        for dict in getMenuList() {
            if (dict as! NSDictionary).getValueFromKey("title") == level {
                return (dict as! NSDictionary).getValueFromKey("id")
            }
        }
        return ""
    }
    
    func getMenuList() -> [Any] {
        return [
            ["title": "Chưa xác định", "id": "1"],
            ["title": "Có nguy cơ cháy cao", "id": "2"],
            ["title": "Đang cháy ở mức độ nhỏ", "id": "3"],
            ["title": "Đang cháy ở mức độ nguy hiểm", "id": "4"],
            ["title": "Đang cháy ở mức độ cực kỳ nguy hiểm, có nguy cơ lan ra diện rộng", "id": "5"],
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
                
        pickerController.singleSelect = true
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
                      
           for asset in assets {
               if asset.type == .video {

               } else {
                  let resourse = PHAssetResource.assetResources(for: asset.originalAsset!)

                  let url = resourse.first?.originalFilename
                                                 
                  (self.dataList[self.dataList.count - 1] as! NSMutableDictionary)["data"] = self.getUIImage(asset: asset.originalAsset!)
                
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
            
            input.accessibilityLabel = (["key": data.getValueFromKey("tag"), "index": indexPath.row] as! NSDictionary).jsonString()

            input.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
            
            
            
            
            
            let button = self.withView(cell, tag: 15) as! UIButton

            button.widthConstaint?.constant = data.response(forKey: "start") || data.response(forKey: "end") ? 35 : 0
            
            button.action(forTouch: [:]) { (objc) in
                       
               DatePickerDialog(showCancelButton: false).show("Chọn thời gian " + (data.response(forKey: "start") ? "bắt đầu" : "kết thúc"), doneButtonTitle: "Chọn", datePickerMode: .dateAndTime) {
                   (date) -> Void in
                   if let dt = date {
                       let formatter = DateFormatter()
                       formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                       (self.dataList[indexPath.row] as! NSMutableDictionary)[data.getValueFromKey("tag")] = formatter.string(from: dt)
                       tableView.reloadData()
                   }
               }
           }
            
            
            let checkEnd = self.withView(cell, tag: 22) as! UIButton

            checkEnd.widthConstaint?.constant = data.response(forKey: "end") ? 35 : 0
            
            checkEnd.action(forTouch: [:]) { (objc) in
                (self.dataList[indexPath.row] as! NSMutableDictionary)["check"] = (self.dataList[indexPath.row] as! NSMutableDictionary).getValueFromKey("check") == "0" ? "1" : "0"

                checkEnd.setImage(UIImage(named: (self.dataList[indexPath.row] as! NSMutableDictionary).getValueFromKey("check") == "0" ? "check_in" : "check_ac"), for: .normal)
                
                self.tableView.reloadData()
            }
            
            
            
            let menu = self.withView(cell, tag: 16) as! DropButton
            
            menu.setTitle(data.getValueFromKey("level"), for: .normal)

            menu.isHidden = data.getValueFromKey("input") != ""
            
            menu.action(forTouch: [:]) { (objc) in
                menu.didDropDown(withData: self.getMenuList()) { (objc) in
                    if objc != nil {
                        let title = ((objc as! NSDictionary)["data"] as! NSDictionary)["title"]
                        
                        let id = ((objc as! NSDictionary)["data"] as! NSDictionary)["id"]
                               
                        (self.dataList[indexPath.row] as! NSMutableDictionary)["id"] = id
                        
                        (self.dataList[indexPath.row] as! NSMutableDictionary)["level"] = title

                        menu.setTitle((title as! String), for: .normal)
                    }
                }
            }
        }
        if data.getValueFromKey("ident") == "Map_Cell" {
            (cell as! Map_Cell).tempLocation = [["lat": data.getValueFromKey("x"), "lng": data.getValueFromKey("y")]]


            let x = self.withView(cell, tag: 14) as! UITextField

            x.text = data.getValueFromKey("x")

            x.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)

            x.accessibilityLabel = (["key":"x", "index": indexPath.row] as! NSDictionary).jsonString()


            let y = self.withView(cell, tag: 15) as! UITextField

            y.text = data.getValueFromKey("y")

            y.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)

            y.accessibilityLabel = (["key":"y", "index": indexPath.row] as! NSDictionary).jsonString()
            
            let stack = self.withView(cell, tag: 100) as! UIView

            for v in stack.subviews {
                v.heightConstaint?.constant = 0
                v.isHidden = true
            }
            
            stack.heightConstaint!.constant = 0
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
