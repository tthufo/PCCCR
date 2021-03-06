//
//  PC_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Map_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var headerImg: UIImageView!
    
    var dataList: NSMutableArray = [["title": "Thông tin cháy", "img": "ic_fire_infor_press", "category": "1"],
                                    ["title": "Dữ liệu GPS", "img": "ic_fire_gps_press", "category": "2"],
                                    ["title": "Bản đồ dẫn đường", "img": "ic_fire_map_press", "category": "3"],
                                    ["title": "Thông tin nguồn lực", "img": "ic_fire_human_press", "category": "4"],
                                    ["title": "Thông tin xử lý cháy", "img": "ic_fire_process_press", "category": "5"],
                                    ["title": "Tìm kiếm và thống kê", "img": "ic_fire_find_press", "category": "6"],
    ]
    
    @IBAction func didPressMenu() {
        EM_MenuView.init(menuRight: [:]).show { (index, obj, menu) in
            menu!.close()
            print(index)
            switch index {
            case 0 :
                self.navigationController?.pushViewController(PC_Register_ViewController.init(), animated: true)
                break
            case 1 :
                exit(0)
                break
            case 2 :
                self.removeValue("log")
                self.remove("token")
                self.navigationController!.popViewController(animated: true)
                break
            case 3 :
                self.navigationController?.pushViewController(QL_Setting_ViewController.init(), animated: true)
                break
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.withCell("TG_Map_Cell")
        
        Permission.shareInstance()?.initLocation(false, andCompletion: { (permissionType) in
            
        })
        if Information.check == "0" {
            headerImg.image = UIImage(named: "bg_text_dms")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        swipeToPop()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var don = 1
        if NSDate.init().isPastTime("03/06/2020") {
            don = 0
        }
        return dataList.count - don
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int((self.screenWidth() / 2) - 15), height: Int((self.screenHeight() / 3) - 40))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TG_Map_Cell", for: indexPath as IndexPath)
        
        let data = dataList[indexPath.item] as! NSDictionary
        
        let title = self.withView(cell, tag: 12) as! UILabel

        title.text = data.getValueFromKey("title")
        
        let image = self.withView(cell, tag: 11) as! UIImageView
        
        image.image = UIImage(named: "%@".format(parameters: data.getValueFromKey("img")))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = dataList[indexPath.item] as! NSDictionary

        switch indexPath.item {
        case 0, 2, 3, 4:
            let commonList = PC_Common_List_ViewController.init()
            commonList.option = "/GetFirePointList"
            commonList.indexing = indexPath.row
            commonList.titleOption = data.getValueFromKey("title") as NSString?
            self.navigationController?.pushViewController(commonList, animated: true)
            break
        case 1:
//            let statistic = PC_Fire_Alert_ViewController.init()
//            self.navigationController?.pushViewController(statistic, animated: true)
            
            let gps = PC_GPS_ViewController.init()
            self.navigationController?.pushViewController(gps, animated: true)
        break
        case 5:
//            let search = PC_Search_ViewController.init()
//            self.navigationController?.pushViewController(search, animated: true)
            let statistic = PC_Statistic_ViewController.init()
            self.navigationController?.pushViewController(statistic, animated: true)
            break
        default:
            break
        }
        
//        let data = dataList[indexPath.item] as! NSDictionary
//
//        if indexPath.item == 0 {
//            let question = PC_Province_ViewController.init()
//            self.navigationController?.pushViewController(question, animated: true)
//        } else if indexPath.item == 2 {
//            let event = PC_List_Event_ViewController.init()
//            self.navigationController?.pushViewController(event, animated: true)
//        } else if indexPath.item == 3 {
//            let question = TG_Intro_ViewController.init()
//            question.isIntro = false
//            self.navigationController?.pushViewController(question, animated: true)
//        } else if indexPath.item == 4 {
//            let info = PC_Inner_Info_ViewController.init()
//            self.navigationController?.pushViewController(info, animated: true)
//        } else if indexPath.item == 5 {
//            let info = PC_Info_ViewController.init()
//            self.navigationController?.pushViewController(info, animated: true)
//        }
    }
}
