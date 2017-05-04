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
import RxSwift
import RxCocoa
import RxDataSources
import Moya

let TableViewHeaderHeight:CGFloat = 360.0/640.0 * MainBounds.width

class DVMessageViewController: UIViewController {
    
    typealias callbackFunc = (String) -> Void
    /// 点击返回父视图
    /// * String:点击cell返回的URL
    var myFunc: callbackFunc?
    typealias endSearchFunc = () -> Void
    /// 列表滑动结束搜索
    var endFunc: endSearchFunc?
    /// 是否首页,0是首页
    var sortid: Int = 0
    /// 刷新Index
    var currentIndex: Int = 1
    var messageListArray = [Any]()
    var bannerListArray = [Any]()
    
    var imgURLArray = [String]()
    var imgNameArray = [String]()
    var imgClickURLArray = [String]()
    
    var messageFirstItem:Results<DVMessageModel>?
    var banneritem:Results<DVMessageModel>?
    
    let dispose = DisposeBag()
    let provider = RxMoyaProvider<ApiManager>()
    
    let messageArray = Variable([DVMessageModel()])

    let identifier: String = "DVMessageCell"
    
    override func viewDidDisappear(_ animated: Bool) {
        self.bannerView.solveAHalfOfScrollView()
    }
    //MARK:懒加载
    lazy var mainTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.register(DVMessageTableViewCell.self, forCellReuseIdentifier: self.identifier)
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(DVMessageViewController.headerRefresh))
        tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(DVMessageViewController.footerRefresh))
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

        self.setupView()
        self.setupDataBase()
        self.setupData()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension DVMessageViewController {
    /// 加载Tableview
    func setupView() {
        self.view.backgroundColor = UIColor.init(colorLiteralRed: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.addSubview(self.mainTableView)
        self.mainTableView.frame = CGRect.init(x: 0, y: 0, width: MainBounds.width, height: MainBounds.height-64-30);
        messageArray.value.removeAll()
        messageArray.asObservable().bindTo(self.mainTableView.rx.items(cellIdentifier: self.identifier, cellType: DVMessageTableViewCell.self)){ (row, model, cell) in
            cell.setModel(DVMessageModel(value:model))
            }.disposed(by: dispose)
        
        mainTableView.rx.modelSelected(DVMessageModel.self)
            .subscribe( onNext: { (model) in
                if (self.myFunc != nil){
                    self.myFunc!(model.url)
                }
            }).disposed(by: dispose)
        
        mainTableView.rx.didScroll.subscribe( onNext: {
            if (self.endFunc != nil) {
                self.endFunc!()
            }
        }).disposed(by: dispose)
    }
    
    /// 加载轮播图数据
    func setupBannerViewData(){
        self.bannerView.imageURLGroup = self.imgURLArray
        self.bannerView.imageNameGroup = self.imgNameArray

    }
    
    func headerRefresh() {
        self.currentIndex = 1
        loadListData()
    }
    func footerRefresh() {
        self.currentIndex += 1
        loadListData()
    }

}
extension DVMessageViewController {
    /// 读取数据库
    func setupDataBase(){
        //        print(realm.configuration.fileURL?.absoluteString)
        setupDataBaseForList()
        setupDataBaseForBanner()
        
    }
    /// 读取列表数据库
    func setupDataBaseForList() {
        if sortid == 0{
            messageFirstItem = realm.objects(DVMessageModel.self).filter("isHomepage = true")
        }else{
            messageFirstItem = realm.objects(DVMessageModel.self).filter("sortid = \(self.sortid)")
        }
        //列表 -- 不超过10条
        if (messageFirstItem?.count ?? 0) >= 10 {
            for i in 0...9 {
                let model = messageFirstItem![i]
                self.messageArray.value.append(model)
            }
        }else{
            if (messageFirstItem?.count ?? 0) != 0 {
                for model in messageFirstItem! {
                    self.messageArray.value.append(model)
                }
            }
        }
    }
    /// 读取轮播图数据库
    func setupDataBaseForBanner(){
        if sortid == 0{
            banneritem = realm.objects(DVMessageModel.self).filter("isBanner = true")
            if banneritem?.count != 0 {
                for model in banneritem! {
                    self.imgURLArray.append(model.pic)
                    self.imgNameArray.append(model.title)
                    self.imgClickURLArray.append(model.url)
                }
                setupBannerViewData()
            }
        }
    }
}
extension DVMessageViewController {
    /// 请求数据
    func setupData(){
        loadListData()
        loadBannerData()
    }
    /// 请求列表数据
    func loadListData(){
        provider
            .request(.MSG_pathList(sortid: self.sortid, currentIndex: self.currentIndex))
            .mapResponseToJSON()
            .subscribe( onNext: { (json) in
                self.mainTableView.mj_header.endRefreshing()
                self.mainTableView.mj_footer.endRefreshing()
                DispatchQueue.global().async {
                    //移除数组，防止重复添加
                    if let dataArray = json["data"].array{
                        if dataArray.count != 0{
                            let praiseDic = json["praise"]
                            DispatchQueue.global().sync {
                                if self.currentIndex == 1 {
                                    self.messageArray.value.removeAll()
                                }
                                for dataDic in dataArray{
                                    let model = DVMessageModel.init(dataDic: dataDic)
                                    if let sortid = dataDic["sortid"].int{
                                        let sid = Int(sortid)
                                        model.sortid = sid
                                    }
                                    if let praise = praiseDic["\(model.id)"].int {
                                        model.praise = praise
                                    }
                                    
                                    self.writeToRealmWithMessageModel(DVMessageModel.self, model: model, sortid:self.sortid)
                                    self.messageArray.value.append(model)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.mainTableView.reloadData()
                    }
                }
            })
            .disposed(by: dispose)
    }
    /// 请求轮播图数据
    func loadBannerData(){
        guard self.sortid == 0 else {
            return
        }
        provider
            .request(.MSG_pathSlide)
            .mapResponseToJSON()
            .subscribe( onNext: { (json) in
                if (self.banneritem?.count != 0) {
                    for model in self.banneritem! {
                        try! realm.write {
                            model.isBanner = false
                        }
                    }
                }
                if let jsonArray = json.array{
                    DispatchQueue.global().async {
                        //移除数组，防止重复添加
                        self.imgNameArray.removeAll()
                        self.imgURLArray.removeAll()
                        self.imgClickURLArray.removeAll()
                        for dataDic in jsonArray{
                            let model = DVMessageModel.init(dataDic: dataDic)
                            self.writeToRealmWithMessageModel(DVMessageModel.self, model: model, sortid:self.sortid)
                            self.imgNameArray.append(model.title)
                            self.imgURLArray.append(model.pic)
                            self.imgClickURLArray.append(model.url)
                        }
                        DispatchQueue.main.async {
                            self.setupBannerViewData()
                        }
                    }
                    
                }
            })
            .disposed(by: dispose)
    }
}

extension DVMessageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sortid==0 {
            return self.bannerView
        }else{
            return UIView.init()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sortid==0 {
            return TableViewHeaderHeight
        }else{
            return 0.01
        }
    }
}
