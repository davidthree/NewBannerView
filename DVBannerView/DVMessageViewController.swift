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
    var bannerIDArray: [String] = [""]
    var praiseDic: Dictionary<String,AnyObject> = [:]
    var messageFirstPageItem: Results<DVFirstMessageModel>?
    var messageItem: Results<DVMessageModel>?
    var bannerItem: Results<DVBannerModel>?
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
            let model = self.bannerItem![index]
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
        if newMenuListItem == 0{
            self.messageFirstPageItem = realm.objects(DVFirstMessageModel.self)
        }else{
            self.messageItem = realm.objects(DVMessageModel.self).filter("sortid = '\(self.newMenuListItem)'")
        }

        self.bannerItem = realm.objects(DVBannerModel.self)
        self.bannerView.setBanner(self.bannerItem!)
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
        request.getRequest(urlString: MSG_pathList as String, params:params, success: { (response) in
            let model = DVMessageModel()
            self.praiseDic = response["praise"] as! Dictionary<String, AnyObject>
            let dataArray = response["data"] as! [Dictionary<String,AnyObject>]
            for dataDic in dataArray{
                model.id = Int(dataDic ["id"] as! NSNumber)
                model.sortid = dataDic["sortid"] as! String
                model.title = dataDic["title"] as! String
                model.titlesub = dataDic["titlesub"] as! String
                model.type = Int(dataDic["type"] as! NSNumber)
                model.source = dataDic["source"] as! String
                model.date = dataDic["date"] as! String
                model.datefolder = dataDic["datefolder"] as! String
                model.url = dataDic["url"] as! String
                model.pic = dataDic["pic"] as! String
                model.piclarge = dataDic["piclarge"] as! String
                model.picmore = dataDic["picmore"] as! String
                model.iscommend = Int(dataDic["iscommend"] as! NSNumber)
                model.istop = Int(dataDic["istop"] as! NSNumber)
                model.summary = dataDic["summary"] as! String
                model.praise = Int(self.praiseDic["\(model.id)"] as! NSNumber)
                
                try! realm.write {
                    if self.newMenuListItem == 0{
                        realm.create(DVFirstMessageModel.self, value: model, update: true)
                    }else{
                        realm.create(DVMessageModel.self, value: model, update: true)
                    }
                    
                }
            }
            self.mainTableView.reloadData()
        }) { (error) in
            
        }
        request.getRequestReturnArray(urlString: MSG_pathSlide as String, params: [:], success: { (response) in
            try! realm.write{
                realm.delete(self.bannerItem!)
            }
            for dataDic in response{
                let model = DVBannerModel()
                if let newsid = dataDic["newsid"] as? String {
                    model.newsid = newsid
                }
                model.datefolder = dataDic["datefolder"] as! String
                model.praise = Int(dataDic["praise"] as! NSNumber)
                model.title = dataDic["title"] as! String
                model.newstitle = dataDic["newstitle"] as! String
                model.url = dataDic["url"] as! String
                model.pic = dataDic["pic"] as! String
                model.summary = dataDic["summary"] as! String
                self.bannerIDArray.append(model.newsid)
                try! realm.write{
                    realm.create(DVBannerModel.self, value: model, update: true)
                }
            }
            self.bannerView.setBanner(self.bannerItem!)
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
        if newMenuListItem == 0 {
            return messageFirstPageItem?.count ?? 0
        }else{
            return self.messageItem?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model = DVMessageModel()
        if newMenuListItem == 0 {
            model = DVMessageModel(value: self.messageFirstPageItem![indexPath.row])
        }else{
            model = self.messageItem![indexPath.row]
        }
        self.myFunc!(model.url)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let initIdentifier = "reuseID"
        var cell:DVMessageTableViewCell! = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as? DVMessageTableViewCell
        if cell == nil {
            cell = DVMessageTableViewCell(style:.default,reuseIdentifier:initIdentifier)
        }
        if newMenuListItem == 0 {
            let model = self.messageFirstPageItem![indexPath.row]
            cell.setModel(DVMessageModel(value:model))
        }else{
            let model = self.messageItem![indexPath.row]
            cell.setModel(model)
        }
        
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
