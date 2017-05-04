//
//  DVRequest.swift
//  DVBannerView
//
//  Created by David on 2017/4/27.
//  Copyright © 2017年 David. All rights reserved.
//

import Foundation
import Moya

enum ApiManager {
    case MSG_pathList(sortid: Int, currentIndex: Int)
    case MSG_pathNews
    case MSG_pathParise(newsid: Int)
    case MSG_pathSearch(searchStirng: String)
    case MSG_pathSlide
}

extension ApiManager: TargetType {
    var baseURL: URL {
        return URL.init(string: "https://lb.7m.com.cn/news/mobi/interface/")!
    }
    
    var path: String {
        switch self {
        case .MSG_pathList(_, _):
            return "list.php"
        case .MSG_pathNews:
            return "news.php"
        case .MSG_pathParise(_):
            return "praise.php"
        case .MSG_pathSearch(_):
            return "search.php"
        case .MSG_pathSlide:
            return "slide.php"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .MSG_pathList(let sortid, let currentIndex):
            return ["sort":"\(sortid)","page":"\(currentIndex)"]
        case .MSG_pathNews:
            return nil
        case .MSG_pathParise(let newsid):
            return ["id":newsid]
        case .MSG_pathSearch(let searchString):
            return ["keyword":searchString]
        case .MSG_pathSlide:
            return nil
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        return .request
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
}
