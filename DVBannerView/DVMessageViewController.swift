//
//  DVMessageViewController.swift
//  DVBannerView
//
//  Created by David on 2017/3/30.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON
class DVFirstMessageModel: Object {
    dynamic var id = 0
    dynamic var sortid = ""
    dynamic var title = ""
    dynamic var titlesub = ""
    dynamic var type = 0
    dynamic var source = ""
    dynamic var date = ""
    dynamic var datefolder = ""
    dynamic var url = ""
    dynamic var pic = ""
    dynamic var piclarge = ""
    dynamic var picmore = ""
    dynamic var iscommend = 0
    dynamic var istop = 0
    dynamic var summary = ""
    dynamic var praise = 0
    override static func primaryKey() -> String?{
        return "id"
    }
}
class DVMessageModel: Object {
    dynamic var id = 0
    dynamic var sortid = ""
    dynamic var title = ""
    dynamic var titlesub = ""
    dynamic var type = 0
    dynamic var source = ""
    dynamic var date = ""
    dynamic var datefolder = ""
    dynamic var url = ""
    dynamic var pic = ""
    dynamic var piclarge = ""
    dynamic var picmore = ""
    dynamic var iscommend = 0
    dynamic var istop = 0
    dynamic var summary = ""
    dynamic var praise = 0
    override static func primaryKey() -> String?{
        return "id"
    }
}
class DVBannerModel: Object {
    dynamic var newsid = ""
    dynamic var datefolder = ""
    dynamic var praise = 0
    dynamic var title = ""
    dynamic var newstitle = ""
    dynamic var url = ""
    dynamic var pic = ""
    dynamic var summary = ""
    override static func primaryKey() -> String?{
        return "newsid"
    }
}

private let TableViewHeaderHeight:CGFloat = 200.0

class DVMessageViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    typealias callbackFunc = (String) -> Void
    var myFunc: callbackFunc?
    var newMenuListItem: Int = 0
    var messageListArray = [Any]()
    var bannerListArray = [Any]()
    //MARK:懒加载
    lazy var mainTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var bannerView: DVBannerView = {
        let view = DVBannerView.init(viewHeight:TableViewHeaderHeight)
        view.myFunc = {(index) -> Void in
            let model = self.bannerListArray[index] as! DVBannerModel
            self.myFunc!(model.url)
        }
        return view
    }()
    
    
    //MARK:内部方法
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(colorLiteralRed: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        self.setupView()
        self.setupDataBase()
        self.setupData()
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        self.view.addSubview(self.mainTableView)
        self.mainTableView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(0)
            make.top.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
    }
    
    func setupDataBase(){
//        print(realm.configuration.fileURL?.absoluteString)
        var messageFirstItem:Results<DVFirstMessageModel>?
        var messageOtherItem:Results<DVMessageModel>?
        
        if newMenuListItem == 0{
            messageFirstItem = realm.objects(DVFirstMessageModel.self)
        }else{
            messageOtherItem = realm.objects(DVMessageModel.self).filter("sortid = '\(self.newMenuListItem)'")
        }
        //列表
        if newMenuListItem == 0 {
            if (messageFirstItem?.count)! >= 10 {
                for i in 0...9 {
                    let model = messageFirstItem![i]
                    self.messageListArray.append(model)
                }
            }else{
                if messageFirstItem?.count != 0 {
                    for model in messageFirstItem! {
                        self.messageListArray.append(model)
                    }
                }
            }
        }else{
            if (messageOtherItem?.count)! >= 10{
                for i in 0...9 {
                    let model = messageOtherItem![i]
                    self.messageListArray.append(model)
                }
            }else{
                if messageOtherItem?.count != 0 {
                    for model in messageOtherItem! {
                        self.messageListArray.append(model)
                    }
                }
            }
        }
        
        let banneritem = realm.objects(DVBannerModel.self)
        if banneritem.count != 0 {
            for i in banneritem {
                self.bannerListArray.append(i)
            }
            self.bannerView.setBanner(self.bannerListArray)
        }
    }
    
    func setupData(){
        let request = DVNewworkRequest()
        var params = [String:String]()
        if newMenuListItem == 0 {
            params = [:]
        }else
        {
            params["sort"] = "\(newMenuListItem)"
        }
        request.getRequest(urlString: MSG_pathList as String, params:params, success: { (json) in
            self.messageListArray.removeAll()
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
                        self.messageListArray.append(model)
                        try! realm.write {
                            if self.newMenuListItem == 0{
                                realm.create(DVFirstMessageModel.self, value: model, update: true)
                            }else{
                                realm.create(DVMessageModel.self, value: model, update: true)
                            }
                        }
                    }
                }
            }
            
            self.mainTableView.reloadData()
        }) { (error) in
            
        }
        request.getRequest(urlString: MSG_pathSlide, params: [:], success: { (json) in
            
            let banneritem = realm.objects(DVBannerModel.self)
            try! realm.write{
                realm.delete(banneritem)
            }
            if let jsonArray = json.array{
                self.bannerListArray.removeAll()
                for dataDic in jsonArray{
                    let model = DVBannerModel()
                    if let newsid = dataDic["newsid"].string {
                        model.newsid = newsid
                    }
                    if let datefolder = dataDic["datefolder"].string {
                        model.datefolder = datefolder
                    }
                    if let praise = dataDic["praise"].int {
                        model.praise = praise
                    }
                    if let title = dataDic["title"].string {
                        model.title = title
                    }
                    if let newstitle = dataDic["newstitle"].string {
                        model.newstitle = newstitle
                    }
                    if let url = dataDic["url"].string {
                        model.url = url
                    }
                    if let pic = dataDic["pic"].string {
                        model.pic = pic
                    }
                    if let summary = dataDic["summary"].string {
                        model.summary = summary
                    }
                    self.bannerListArray.append(model)
                    try! realm.write{
                        realm.create(DVBannerModel.self, value: model, update: true)
                    }
                }
            }
            self.bannerView.setBanner(self.bannerListArray)
        }) { (error) in
            
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if newMenuListItem==0 {
            return self.bannerView
        }else{
            return UIView.init()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if newMenuListItem==0 {
            return TableViewHeaderHeight
        }else{
            return 0.01
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageListArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.messageListArray[indexPath.row] as! DVMessageModel
        if (self.myFunc != nil){
            self.myFunc!(model.url)
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let initIdentifier = "reuseID"
        var cell:DVMessageTableViewCell! = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as? DVMessageTableViewCell
        if cell == nil {
            cell = DVMessageTableViewCell(style:.default,reuseIdentifier:initIdentifier)
        }
        let model = self.messageListArray[indexPath.row]
        cell.setModel(DVMessageModel(value:model))
            return cell
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
