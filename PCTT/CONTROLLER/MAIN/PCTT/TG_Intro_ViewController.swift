//
//  TG_Intro_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

import WebKit

class TG_Intro_ViewController: UIViewController {

    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var bottom: MarqueeLabel!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var back: UIButton!

    @IBOutlet var gap: NSLayoutConstraint!

    var dataList: NSMutableArray!
    
    @IBOutlet var webView: WKWebView!

    var isIntro: Bool = true
    
    @IBOutlet var headerImg: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Information.check == "0" {
            headerImg.image = UIImage(named: "bg_text_dms")
        }
        
        gap.constant = isIntro ? 0 : 44
        
        dataList = NSMutableArray.init()
        
        bg.image = UIImage(named: "intro_bg")
        
        tableView.withCell("PC_Info_Cell")
        
        if isIntro {
            let link = URL(string:"http://eladmin.gisgo.vn/?cmd=intro")!
            let request = URLRequest(url: link)
            webView.load(request)
        }
        
        webView.isHidden = !isIntro

        back.isHidden = isIntro
        
        titleLabel.isHidden = isIntro
        
        didRequestFAQ()
    }
    
    func didRequestFAQ() {
    LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "faq"),
                                                    "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                    "method":"GET",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                                         
            if (error != nil) || result.getValueFromKey("status") != "OK" {
                self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                return
            }
                    
            self.dataList.addObjects(from: response?.dictionize()["data"] as! [Any])
                        
            self.tableView.reloadData()
        })
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressFAQ() {
       let question = PC_FeedBack_New_ViewController.init()
               
       question.inner = false
       
       self.navigationController?.pushViewController(question, animated: true)
    }
}

extension TG_Intro_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return -1//CGFloat(self.screenWidth() * 9 / 16)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return bg
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"PC_Info_Cell", for: indexPath)
        
        let data = dataList![indexPath.row] as! NSDictionary
        
        
        let image = self.withView(cell, tag: 11) as! UIImageView
        
//        image.imageUrl(url: data.getValueFromKey("image"))
        
        image.image = UIImage(named: "question")
        
        let title = self.withView(cell, tag: 1) as! UILabel
        
        title.text = data["question"] as? String
        
        let imageArrow = self.withView(cell, tag: 15) as! UIImageView
        
        imageArrow.isHidden = false

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let data = dataList![indexPath.row] as! NSDictionary

        let question = TG_Intro_Question_ViewController.init()
        
        question.qInfo = data
        
        self.navigationController?.pushViewController(question, animated: true)
    }
}
