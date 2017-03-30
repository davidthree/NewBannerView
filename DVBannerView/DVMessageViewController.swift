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

let realm = try! Realm()
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
    
    private var praiseDic = Dictionary<String,AnyObject>()
    
    private var messageItem:Results<DVMessageModel>?
    private var bannerItem:Results<DVBannerModel>?
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
            let web = WebViewViewController()
            let model = self.bannerItem![index]
            web.url = model.url
            self.navigationController!.pushViewController(web, animated: true)
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
        self.messageItem = realm.objects(DVMessageModel.self)
        self.bannerItem = realm.objects(DVBannerModel.self)
        self.bannerView.setBanner(self.bannerItem!)
    }
    func setupData(){
        
        let request = DVNewworkRequest()
        request.getRequest(urlString: MSG_pathList as String, params:["NewMenuListItem":"0"], success: { (response) in
            self.praiseDic = response["praise"] as! Dictionary<String, AnyObject>
            let dataArray = response["data"] as! [Dictionary<String,AnyObject>]
            for dataDic in dataArray{
                
                let model = DVMessageModel()
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
                    realm.create(DVMessageModel.self, value: model, update: true)
                }
            }
            self.mainTableView.reloadData()
        }) { (error) in
            
        }
        request.getRequestReturnArray(urlString: MSG_pathSlide as String, params: [:], success: { (response) in
            for dataDic in response{
                let model = DVBannerModel()
                model.newsid = dataDic["newsid"] as! String
                model.datefolder = dataDic["datefolder"] as! String
                model.praise = Int(dataDic["praise"] as! NSNumber)
                model.title = dataDic["title"] as! String
                model.newstitle = dataDic["newstitle"] as! String
                model.url = dataDic["url"] as! String
                model.pic = dataDic["pic"] as! String
                model.summary = dataDic["summary"] as! String
                try! realm.write{
                    realm.create(DVBannerModel.self, value: model, update: true)
                }
            }
            self.bannerView.setBanner(self.bannerItem!)
        }) { (error) in
            
        }
        //        print(realm.configuration.fileURL!.absoluteString)
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
        return self.bannerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewHeaderHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageItem!.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let web = WebViewViewController()
        let model = self.messageItem![indexPath.row]
        web.url = model.url
        self.navigationController!.pushViewController(web, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let initIdentifier = "reuseID"
        var cell:DVMessageTableViewCell! = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as? DVMessageTableViewCell
        if cell == nil {
            cell = DVMessageTableViewCell(style:.default,reuseIdentifier:initIdentifier)
        }
        let model = self.messageItem![indexPath.row]
        cell.setModel(model)
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
