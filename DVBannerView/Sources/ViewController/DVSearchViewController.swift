//
//  DVSearchViewController.swift
//  DVBannerView
//
//  Created by David on 2017/3/28.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class DVSearchViewController: UIViewController
{
    var listArray = [DVMessageModel]()
    var messageArray = Variable([DVMessageModel()])
    var searchString: String = ""
    let identifier = "searchCell"
    let dispose = DisposeBag()
    let provider = RxMoyaProvider<ApiManager>()
    
    lazy var mainTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.register(DVMessageTableViewCell.self, forCellReuseIdentifier: self.identifier)
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        messageArray.value.removeAll()
        loadMainView()
        loadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension DVSearchViewController {
    func loadMainView() {
        self.view.addSubview(self.mainTableView)
        mainTableView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(0)
            make.top.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
        
        messageArray.asObservable().bindTo(self.mainTableView.rx.items(cellIdentifier: identifier, cellType: DVMessageTableViewCell.self)){
            (row, model, cell) in
            let model = self.messageArray.value[row]
            cell.setModel(model)
            }.disposed(by: dispose)
        
        mainTableView.rx.modelSelected(DVMessageModel.self)
            .subscribe(onNext: {(model) in
                let webview = WebViewViewController()
                webview.url = model.url
                self.navigationController?.pushViewController(webview, animated: true)
            }).disposed(by: dispose)
    }
}
extension DVSearchViewController {
    func loadData() {
        provider.request(.MSG_pathSearch(searchStirng: self.searchString))
            .mapResponseToJSON()
            .subscribe(onNext: { (json) in
                if let dataArray = json["data"].array{
                    if dataArray.count != 0{
                        let praiseDic = json["praise"]
                        for dataDic in dataArray{
                            let model = DVMessageModel.init(dataDic: dataDic)
                            if let praise = praiseDic["\(model.id)"].int {
                                model.praise = praise
                            }
                            self.writeToRealmWithMessageModel(DVMessageModel.self, model: model, sortid:10)
                            self.messageArray.value.append(model)
                        }
                    }
                }
            })
            .disposed(by: dispose)
    }

}
extension DVSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

