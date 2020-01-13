//
//  PC_Statistic_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/13/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import AVHexColor

class PC_Statistic_ViewController: ViewPagerController {

    var controllers: NSMutableArray!

    var titles = ["Tìm kiếm", "Thống kê"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        self.delegate = self
        
        self.topHeight = IS_IPHONE_X() ? "104" : "84"
        
        controllers = NSMutableArray()
        
        

    
        
        let form = PC_Search_ViewController()
        
        controllers.add(form)
        
        
        
        let map = PC_Summary_ViewController()
                
        controllers.add(map)
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func modelLabel(index: Int) -> UILabel {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.text = titles[index]
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }
}

extension PC_Statistic_ViewController: ViewPagerDelegate, ViewPagerDataSource {
    func numberOfTabs(forViewPager viewPager: ViewPagerController!) -> UInt {
        return UInt(titles.count)
    }
    
    func viewPager(_ viewPager: ViewPagerController!, viewForTabAt index: UInt) -> UIView! {
        return modelLabel(index: Int(index))
    }
    
    func viewPager(_ viewPager: ViewPagerController!, contentViewControllerForTabAt index: UInt) -> UIViewController! {
        return (controllers[Int(index)] as! UIViewController)
    }
    
    func viewPager(_ viewPager: ViewPagerController!, didChangeTabTo index: UInt) {
        for view in viewPager.tabsView.subviews {
            for tab in view.subviews {
                if (tab as AnyObject).isKind(of: UILabel.self) {
                    (tab as! UILabel).textColor = (viewPager.tabsView.subviews.index(of: view) as! Int) != index ? UIColor.lightGray : UIColor.green
                }
            }
        }
    }
    
    func viewPager(_ viewPager: ViewPagerController!, valueFor option: ViewPagerOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == .tabWidth {
            return CGFloat((Int(self.screenWidth()) / titles.count))
        } else if option == .tabHeight {
            return 50
        } else if option == .tabLocation {
            return 1
        }
        
        return value
    }
    
    func viewPager(_ viewPager: ViewPagerController!, colorFor component: ViewPagerComponent, withDefault color: UIColor!) -> UIColor! {
        
        if component == .indicator {
            return UIColor.green
        } else if component == .tabsView {
            return UIColor.clear
        } else if component == .content {
            return UIColor.darkGray
        }
        
        return color
    }
}
