//
//  Protocol.swift
//  DVBannerView
//
//  Created by David on 2017/4/27.
//  Copyright © 2017年 David. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import Moya
import SwiftyJSON

// public func mapJSON(failsOnEmptyData: Bool = default) -> RxSwift.Observable<Any>
extension Observable {
    public func mapResponseToJSON() -> Observable<JSON> {
        return map { representor in
            guard let response = representor as? Moya.Response else {
                return JSON([""])
            }
               return JSON(response.data)
        }
    }
}
