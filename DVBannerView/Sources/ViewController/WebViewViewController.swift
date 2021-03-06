//
//  WebViewViewController.swift
//  DVBannerView
//
//  Created by David on 2017/3/27.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController,WKNavigationDelegate
{
    var webview = WKWebView()
    var model = DVMessageModel()
    var url:String = ""
    var newsID:Int = 0
    var datefolder:String = "0"
    
    var isparise:Bool = false
    var praise:Int = 0
    
    lazy var bottomView: UIView = {
       let view = UIView.init(frame: CGRect.init(x: 0, y:MainBounds.height - 44, width: MainBounds.width, height:44))
        view.backgroundColor = UIColor.black
        return view
    }()
    
    lazy var paiseBtn: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: 20, y: 5, width:62, height: 32))
        btn.setImage(UIImage.init(named: "zan"), for: .normal)
        btn.addTarget(self, action: #selector(changePaiseBtnState), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupMainView()
        setupDataBase()
        setupData()
        paiseBtnState()
    }
    ///设置WebView
    func setupMainView() {
        self.webview = WKWebView(frame: CGRect.init(x: 0, y:0, width: MainBounds.width, height: MainBounds.height - 44))
        self.webview.navigationDelegate = self
        self.view.addSubview(self.webview)
        self.view.addSubview(self.bottomView)
        self.bottomView.addSubview(self.paiseBtn)
    }
    ///点赞事件
    func rightBtnAction() {
        print("赞")
    }
    ///进入设置点赞状态
    func paiseBtnState() {
        if self.isparise {
            self.paiseBtn.setImage(UIImage.init(named: "zaned"), for: .normal)
            self.paiseBtn.isEnabled = false
        }
    }
    ///点击点赞后事件
    func changePaiseBtnState() {
        self.paiseBtn.setImage(UIImage.init(named: "zaned"), for: .normal)
        self.paiseBtn.isEnabled = false
        
        try! realm.write {
            realm.create(DVMessageModel.self, value:["ispraise": true], update: true)
        }
        self.paiseBtn.setTitle("\(self.praise+1)", for: .normal)
    }
    ///读取数据库，通过ID或者URL查找是否有数据，分两个表
    func setupDataBase() {
        ///通过ID查找
        if self.newsID != 0 {
            let modelResults = realm.objects(DVBannerModel.self).filter("id = '\(self.newsID)'")
            if modelResults.count == 0 {
                let modelResult = realm.objects(DVMessageModel.self).filter("id = '\(self.newsID)'")
                if modelResult.count == 0 {
                    loadDataFromNet()
                }else{
                    if let p = modelResult.first?.praise {
                        self.praise = p
                    }
                    if let ip = modelResult.first?.ispraise{
                        self.isparise = ip
                    }
                    if let url = modelResult.first?.url{
                        self.url = url
                    }
                }
            }else{
                if let p = modelResults.first?.praise {
                    self.praise = p
                }
                if let ip = modelResults.first?.ispraise{
                    self.isparise = ip
                }
                if let url = modelResults.first?.url{
                    self.url = url
                }
            }
        }
        ///通过URL查找
        else if self.url.isEmpty == false{
            let modelResult = realm.objects(DVBannerModel.self).filter("url = '\(self.url)'")
            if modelResult.count == 0 {
                let modelResults = realm.objects(DVMessageModel.self).filter("url = '\(self.url)'")
                if modelResults.count != 0 {
                    if let p = modelResults.first?.praise {
                        self.praise = p
                    }
                    if let ip = modelResults.first?.ispraise{
                        self.isparise = ip
                    }
                }
            }else{
                if let p = modelResult.first?.praise {
                    self.praise = p
                }
                if let ip = modelResult.first?.ispraise{
                    self.isparise = ip
                }
            }
        }
        setupData()
    }
    ///请求数据
    func setupData() {
        self.paiseBtn.setTitle("\(self.praise)", for: .normal)
        let url = NSURL(string: self.url)
        let request = NSURLRequest(url: url as! URL)
        webview.load(request as URLRequest)
    }
    ///请求网络数据
    func loadDataFromNet() {
        let request = DVNewworkRequest()
        request.getRequest(urlString: MSG_pathSearch, params: ["id":"\(newsID)","datefolder":datefolder], success: { (json) in
            if let dataArray = json["data"].array{
                if dataArray.count != 0{
                    let praiseDic = json["praise"]
                    for dataDic in dataArray{
                        let model = DVMessageModel()
                        if let id = dataDic["id"].int{
                            model.id = id
                        }
                        if let sortid = dataDic["sortid"].string{
                            model.sortid = sortid
                        }
                        if let title = dataDic["title"].string{
                            model.title = title
                        }
                        if let titlesub = dataDic["titlesub"].string{
                            model.titlesub = titlesub
                        }
                        if let type = dataDic["type"].int{
                            model.type = type
                        }
                        if let datefolder = dataDic["datefolder"].string{
                            model.datefolder = datefolder
                        }
                        if let url = dataDic["url"].string{
                            model.url = url
                        }
                        if let pic = dataDic["pic"].string{
                            model.pic = pic
                        }
                        if let piclarge = dataDic["piclarge"].string{
                            model.piclarge = piclarge
                        }
                        if let picmore = dataDic["picmore"].string{
                            model.picmore = picmore
                        }
                        if let iscommend = dataDic["iscommend"].int{
                            model.iscommend = iscommend
                        }
                        if let istop = dataDic["istop"].int{
                            model.istop = istop
                        }
                        if let summary = dataDic["summary"].string{
                            model.summary = summary
                        }
                        if let praise = praiseDic["\(model.id)"].int {
                            model.praise = praise
                        }
                        try! realm.write {
                            realm.create(DVMessageModel.self, value:["id":model.id,"sortid":model.sortid,"title":model.title,"titlesub":model.titlesub,"type":model.type,"datefolder":model.datefolder,"url":model.url,"pic":model.pic,"piclarge":model.piclarge,"picmore":model.picmore,"iscommend":model.iscommend,"istop":model.istop,"summary":model.summary,"praise":model.praise], update: true)
                        }
                        self.url = model.url
                        self.praise = model.praise
                        self.setupData()
                    }
                }
            }
            
        }) { (error) in
            
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
