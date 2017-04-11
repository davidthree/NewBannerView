//
//  DVMessageModel.swift
//  DVBannerView
//
//  Created by David on 2017/4/5.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import RealmSwift
class DVMessageModel: Object {
    dynamic var id = 0      //新闻ID
    dynamic var sortid = 0 //新闻分类ID
    dynamic var type = 0    //新闻类型
    
    dynamic var title = ""  //新闻标题
    dynamic var titlesub = "" //新闻短标题
    dynamic var newstitle = "" //新闻轮显长标题
    
    dynamic var url = ""    //新闻地址
    dynamic var pic = ""    //新闻图片地址
    dynamic var piclarge = ""   //新闻大图片地址
    dynamic var source = "" //新闻来源
    
    dynamic var date = ""   //新闻日期
    dynamic var datefolder = ""  //新闻日期文件夹名

    dynamic var summary = "" //新闻简介
    dynamic var praise = 0   //新闻点赞数量

    dynamic var ispraise = false //新闻是否点赞
    dynamic var isHomepage = false //是否首页
    dynamic var isBanner = false //是否首页
    dynamic var picmore = ""
    dynamic var iscommend = 0
    dynamic var istop = 0
    override static func primaryKey() -> String?{
        return "id"
    }
}
