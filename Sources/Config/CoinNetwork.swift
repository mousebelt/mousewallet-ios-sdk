//
//  CoinNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 08/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import PromiseKit
import SwiftyJSON

func sendRequest<T: Mappable>(responseObject: T.Type, url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil) -> Promise<T> {
    
    DDLogDebug("path = \(url)")
    DDLogDebug("method = \(method.rawValue)")
    DDLogDebug("parameters = \(String(describing: parameters))")
    DDLogDebug("headers = \(String(describing: headers))")
    
    return Promise { seal in
        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseJSON() { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data as Any)
                    DDLogDebug("response = \(json)")
                    let resObj = Mapper<T>().map(JSONObject: json.object)
                    let vcoinresObj = resObj as! VCoinResponse
                    
                    if (vcoinresObj.status == 200) {
                        seal.fulfill(resObj!)
                    }
                    else {
                        if (vcoinresObj.data != nil) {
                            if (vcoinresObj.status == 404) {
                                seal.reject(NRLWalletSDKError.responseError(.resourceMissing(vcoinresObj.data!)))
                            }
                            else {
                                seal.reject(NRLWalletSDKError.responseError(.unexpected(vcoinresObj.data!)))
                            }
                        }
                        else {
                            seal.reject(NRLWalletSDKError.responseError(.unexpected(vcoinresObj)))
                        }
                    }
                case .failure(let error):
                    seal.reject(NRLWalletSDKError.responseError(.unexpected(error)))
                }
        }
    }
}


class VCoinResponse: Mappable {
    var msg: String?
    var status: Int?
    var data: Any?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        msg         <- map["msg"]
        status        <- map["status"]
        data        <- map["data"]
    }
}
