//
//  WebViewViewController.swift
//  DVBannerView
//
//  Created by David on 2017/3/27.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

class WebViewViewController: UIViewController
{
    let request = DVNewworkRequest()
    var webview = WKWebView()
    var model = DVMessageModel()
    var url:String = ""
    var newsID:Int = 0
    var datefolder:String = "0"
    var isparise = Variable(Bool())
    var praise:Int = 0
    
    var fromWhichDatabase:String = ""
    
    let dispose = DisposeBag()
    
    lazy var bottomView: UIView = {
       let view = UIView.init(frame: CGRect.init(x: 0, y:MainBounds.height - 44, width: MainBounds.width, height:44))
        view.backgroundColor = UIColor.black
        return view
    }()
    
    lazy var paiseBtn: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: 20, y: 5, width:62, height: 32))
        btn.setImage(UIImage.init(named: "zan"), for: .normal)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let item = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(backToPrevious))
        self.navigationItem.leftBarButtonItem = item;
        // Do any additional setup after loading the view.
        setupMainView()
        setupDataBase()
        setupData()
        paiseBtnState()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension WebViewViewController {
    func backToPrevious() {
        if self.webview.canGoBack {
            self.webview.goBack()
        }else{
            self.navigationController!.popViewController(animated: true)
        }
    }
    ///点赞事件
    func rightBtnAction() {
        print("赞")
    }
    ///进入设置点赞状态
    func paiseBtnState() {
        self.paiseBtn.setTitle("\(self.praise)", for: .normal)
        self.paiseBtn.setImage(UIImage.init(named: "zan"), for: .normal)
        self.paiseBtn.isEnabled = true
        
        if self.isparise.value {
            self.paiseBtn.setImage(UIImage.init(named: "zaned"), for: .normal)
            self.paiseBtn.isEnabled = false
        }
    }
}
extension WebViewViewController {
    ///设置WebView
    func setupMainView() {
        self.webview = WKWebView(frame: CGRect.init(x: 0, y:0, width: MainBounds.width, height: MainBounds.height - 44))
        self.webview.navigationDelegate = self
        self.webview.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webview)
        self.view.addSubview(self.bottomView)
        self.bottomView.addSubview(self.paiseBtn)
        
        paiseBtn.rx.controlEvent( .touchUpInside).subscribe(onNext: {
            self.paiseBtn.setImage(UIImage.init(named: "zaned"), for: .normal)
            self.paiseBtn.isEnabled = false
            self.loadUploadPaise()
            try! realm.write {
                realm.create(DVMessageModel.self, value:["id":self.newsID,"ispraise": true,"praise": self.praise+1], update: true)
            }
            self.paiseBtn.setTitle("\(self.praise+1)", for: .normal)
        }).disposed(by: dispose)
    }
}
extension WebViewViewController {
    ///读取数据库，通过ID或者URL查找是否有数据
    func setupDataBase() {
        ///通过ID查找
        if self.newsID != 0 {
            let modelResults = realm.objects(DVMessageModel.self).filter("id = \(self.newsID)")
            if modelResults.count == 0 {
                loadDataFromNet()
            }else{
                if let p = modelResults.first?.praise {
                    self.praise = p
                }
                if let ip = modelResults.first?.ispraise{
                    self.isparise.value = ip
                }
                if let url = modelResults.first?.url{
                    self.url = url
                }
            }
        }
        ///通过URL查找
        else if self.url.isEmpty == false{
            let modelResults = realm.objects(DVMessageModel.self).filter("url = '\(self.url)'")
            if let p = modelResults.first?.praise {
                self.praise = p
            }
            if let ip = modelResults.first?.ispraise{
                self.isparise.value = ip
            }
            if let id = modelResults.first?.id{
                self.newsID = id
            }
        }
    }
}
extension WebViewViewController {
    ///请求数据
    func setupData() {
        let url = NSURL(string: self.url)
        let request = NSURLRequest(url: url as! URL)
        webview.load(request as URLRequest)
    }
    
    ///请求网络数据
    func loadUploadPaise() {
        request.getRequest(urlString: MSG_pathParise, params: ["id":self.newsID], success: { (json) in
            print(json)
        }) { (error) in
            print(error)
        }
    }
    
    func loadDataFromNet() {
        request.getRequest(urlString: MSG_pathSearch, params: ["id":"\(newsID)","datefolder":datefolder], success: { (json) in
            if let dataArray = json["data"].array{
                if dataArray.count != 0{
                    let praiseDic = json["praise"]
                    for dataDic in dataArray{
                        let model = DVMessageModel.init(dataDic: dataDic)
                        if let praise = praiseDic["\(model.id)"].int {
                            model.praise = praise
                        }
                        self.writeToRealmWithMessageModel(DVMessageModel.self, model: model, sortid:model.sortid)
                        self.url = model.url
                        self.praise = model.praise
                        self.setupData()
                    }
                }
            }
            
        }) { (error) in
            
        }
    }
}
extension WebViewViewController:WKNavigationDelegate {

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url{
            if let host = url.host{  //获取域名
                print(host.lowercased())
            }
            print("url + \(url)")
            
            
            let stringArray = url.absoluteString.components(separatedBy: "/")
            let date = stringArray[6]
            let index = stringArray.last?.index((stringArray.last?.startIndex)!, offsetBy: 6)
            let did = stringArray.last?.substring(to: index!)
            
            self.datefolder = date
            self.newsID = Int(did!)!
            setupDataBase()
            paiseBtnState()
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }

}
