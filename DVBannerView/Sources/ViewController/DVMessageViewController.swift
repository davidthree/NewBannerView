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

private let TableViewHeaderHeight:CGFloat = 360.0/640.0 * MainBounds.width

class DVMessageViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    typealias callbackFunc = (String) -> Void
    /// 点击返回父视图
    /// * String:点击cell返回的URL
    var myFunc: callbackFunc?
    typealias endSearchFunc = () -> Void
    /// 列表滑动结束搜索
    var endFunc: endSearchFunc?
    /// 是否首页,0是首页
    var newMenuListItem: Int = 0
    var currentIndex: Int = 0
    var messageListArray = [Any]()
    var bannerListArray = [Any]()
    
    var imgURLArray = [String]()
    var imgNameArray = [String]()
    var imgClickURLArray = [String]()
    
    //MARK:懒加载
    lazy var mainTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var bannerView: DVBannerView = {
        let view = DVBannerView.init(frame:CGRect.init(x: 0, y: 0, width: MainBounds.width, height: TableViewHeaderHeight))
        view.myFunc = {(index) -> Void in
            self.myFunc!(self.imgClickURLArray[index])
        }
        return view
    }()
    
    
    //MARK:内部方法
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(colorLiteralRed: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupView()
        self.setupDataBase()
        self.setupData()
        // Do any additional setup after loading the view.
    }
    /// 加载Tableview
    func setupView() {
        self.view.addSubview(self.mainTableView)
        self.mainTableView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(0)
            make.top.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
    }
    /// 读取数据库
    func setupDataBase(){
//        print(realm.configuration.fileURL?.absoluteString)
        setupDataBaseForList()
        setupDataBaseForBanner()
        
    }
    /// 读取列表数据库
    func setupDataBaseForList() {
        var messageFirstItem:Results<DVFirstMessageModel>?
        var messageOtherItem:Results<DVMessageModel>?
        
        if newMenuListItem == 0{
            messageFirstItem = realm.objects(DVFirstMessageModel.self)
        }else{
            messageOtherItem = realm.objects(DVMessageModel.self).filter("sortid = '\(self.newMenuListItem)'")
        }
        //列表
        if newMenuListItem == 0 {
            if (messageFirstItem?.count ?? 0) >= 10 {
                for i in 0...9 {
                    let model = messageFirstItem![i]
                    self.messageListArray.append(model)
                }
            }else{
                if (messageFirstItem?.count ?? 0) != 0 {
                    for model in messageFirstItem! {
                        self.messageListArray.append(model)
                    }
                }
            }
        }else{
            if (messageOtherItem?.count ?? 0) >= 10{
                for i in 0...9 {
                    let model = messageOtherItem![i]
                    self.messageListArray.append(model)
                }
            }else{
                if (messageOtherItem?.count ?? 0) != 0 {
                    for model in messageOtherItem! {
                        self.messageListArray.append(model)
                    }
                }
            }
        }
    }
    /// 读取轮播图数据库
    func setupDataBaseForBanner(){
        if newMenuListItem == 0{
            let banneritem = realm.objects(DVBannerModel.self)
            if banneritem.count != 0 {
                for model in banneritem {
                    self.imgURLArray.append(model.pic)
                    self.imgNameArray.append(model.title)
                    self.imgClickURLArray.append(model.url)
                }
                setupBannerViewData()
            }
        }
    }
    /// 加载轮播图数据
    func setupBannerViewData(){
        self.bannerView.imageURLGroup = self.imgURLArray
        self.bannerView.imageNameGroup = self.imgNameArray
    }
    /// 请求数据
    func setupData(){
        loadListData()
        loadBannerData()
    }
    /// 请求列表数据
    func loadListData(){
        let request = DVNewworkRequest()
        var params = [String:String]()
        if newMenuListItem == 0 {
            params = [:]
        }else{
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
                                self.writeToRealmWithMessageModel(DVFirstMessageModel.self, model: model)
                            }
                        self.writeToRealmWithMessageModel(DVMessageModel.self, model: model)
                        }
                    }
                }
            }
            
            self.mainTableView.reloadData()
        }) { (error) in
            
        }
        
    }
    /// 请求轮播图数据
    func loadBannerData(){
        guard self.newMenuListItem == 0 else {
            return
        }
        let request = DVNewworkRequest()
        request.getRequest(urlString: MSG_pathSlide, params: [:], success: { (json) in
            
            let banneritem = realm.objects(DVBannerModel.self)
            try! realm.write{
                realm.delete(banneritem)
            }
            if let jsonArray = json.array{
                self.imgNameArray.removeAll()
                self.imgURLArray.removeAll()
                self.imgClickURLArray.removeAll()
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
                    try! realm.write{
                        realm.create(DVBannerModel.self, value: model, update: true)
                    }
                    self.imgNameArray.append(model.title)
                    self.imgURLArray.append(model.pic)
                    self.imgClickURLArray.append(model.url)
                    self.setupBannerViewData()
                }
            }
        }) { (error) in
            
        }
        
    }
    /// 更新Realm数据库
    /// - Parameters:
    ///     - modelObject:  表名
    ///     - model:  DVMessageModel模型
    func writeToRealmWithMessageModel(_ modelObject: Object.Type,model: DVMessageModel){
        realm.create(modelObject, value: ["id":model.id,"sortid":model.sortid,"title":model.title,"titlesub":model.titlesub,"type":model.type,"datefolder":model.datefolder,"url":model.url,"pic":model.pic,"piclarge":model.piclarge,"picmore":model.picmore,"iscommend":model.iscommend,"istop":model.istop,"summary":model.summary,"praise":model.praise], update: true)
    }
    
    //MARK: -tableviewDelegate
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.endFunc != nil) {
            self.endFunc!()
        }
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
