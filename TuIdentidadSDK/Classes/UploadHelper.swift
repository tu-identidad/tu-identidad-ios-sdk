//
//  UploadeHelper.swift
//  IdValidation
//
//  Created by TuIdentidad on 11/6/19.
//  Copyright © 2019 TuIdentidad. All rights reserved.
//
import Foundation
import UIKit
import Alamofire

public class UploadHelper{
    
    public static let u_r = "UPLOAD_REQUEST"
    public static let t_r = "THUMBNAIL_REQUEST"
    
    public static func sendINE(ineFront: Data, ineBack: Data, api: String, m: Methods, p: IDValidateOptions){
        var uri = Paths.baseURL!
        let ineFPath = Util.saveImageFile(filename: "ineFront.png", data: ineFront)!
        let ineBPath = Util.saveImageFile(filename: "ineBack.png", data: ineBack)!
        let ineFData = Util.getImageData(filename: ineFPath)
        let ineBData = Util.getImageData(filename: ineBPath)
        switch m {
        case .IDVAL:
            uri += Paths.prefix.auth!
            break
        case .ONLYOCR:
            uri += Paths.prefix.ocr!
            break
        case .INE:
            uri += Paths.prefix.ine! + "?" + "checkInfo=" + String(p.checkInfo) + "&" + "checkQuality=" + String(p.checkQuality) + "&" + "checkPatterns=" + String(p.checkPatterns) + "&" + "checkCurp=" + String(p.checkCurp) + "&" + "checkFace=" + String(p.checkFace)
        break
        }
        let headers: HTTPHeaders = [
            "ApiKey": api,
            "Content-type":"multipart/form-data"
        ]
        let queue = DispatchQueue.main
        queue.async {
            AF.upload(multipartFormData: {
                    multipartFormData in
                    multipartFormData.append(ineFData, withName: "FrontFile", fileName: "FrontFile", mimeType: "application/octet-stream")
                    multipartFormData.append(ineBData, withName: "BackFile", fileName: "BackFile", mimeType: "application/octet-stream")
            }, to: uri , method: .post, headers: headers)
            .uploadProgress{ progress in
                let p = progress.fractionCompleted
                NotificationCenter.default.post(name: Notification.Name(self.u_r), object: self, userInfo: [
                    "type": ProgressType.INE_U_P,
                    "progress": p
                ])
            }.downloadProgress { progress in
                let p = progress.fractionCompleted
                NotificationCenter.default.post(name: Notification.Name(self.u_r), object: self, userInfo: [
                    "type": ProgressType.INE_D_P,
                    "progress": p
                ])
            }.responseDecodable { (response: AFDataResponse<IDValidationINEResponse>) in
                if let validationData = response.value {
                    let validation = IDValidationINE(validation: validationData, ineFront: ineFData, ineBack: ineBData)
                    NotificationCenter.default.post(name: Notification.Name(self.u_r), object: self, userInfo: [
                        "type": ProgressType.INE_RESPONSE,
                        "response": validation
                    ])
                }
            }.responseDecodable { (response: AFDataResponse<IDValidationData>) in
                if let validationData = response.value {
                    let validation = IDValidation(validation: validationData, ineFront: ineFData, ineBack: ineBData)
                    NotificationCenter.default.post(name: Notification.Name(self.u_r), object: self, userInfo: [
                        "type": ProgressType.INE_RESPONSE,
                        "response": validation
                    ])
                }
            }.responseDecodable { (response: AFDataResponse<IDValidationResponse>) in
                if let validation = response.value?.result {
                    NotificationCenter.default.post(name: Notification.Name(self.u_r), object: self, userInfo: [
                        "type": ProgressType.INE_RESPONSE,
                        "response": validation
                    ])
                }
            }.response { (response: AFDataResponse<Data?>) in
                
                var responseData = "{ code: 'server_error', message: 'Connection error, validators server is not available please try again later.' }"
                if let data = response.data {
                    if let stringData = String(data: data, encoding: String.Encoding.utf8) {
                        responseData = stringData
                    }
                }
                NotificationCenter.default.post(name: Notification.Name(self.u_r), object: self, userInfo: [
                    "type": ProgressType.INE_RESPONSE_ERROR,
                    "response": responseData
                ])
            }
        }
    }
    public static func getThumbnail(ineFront: UIImage){
        let uri = Paths.mobileBaseURL! + Paths.prefix.analize!
        let ineFPath = Util.saveImageFile(filename: "ineFront.png", image: ineFront)!
        let ineFData = Util.getImageData(filename: ineFPath)
        
        let headers: HTTPHeaders = [
            "Content-type":"multipart/form-data"
        ]
        let queue = DispatchQueue.main
        queue.async {
            AF.upload(multipartFormData: {
                multipartFormData in
                multipartFormData.append(ineFData, withName: "document", fileName: "document", mimeType: "application/octet-stream")
            }, to: uri, method: .post, headers: headers, interceptor: MyRequestInterceptor())
            .uploadProgress{ progress in
                let p = progress.fractionCompleted
                NotificationCenter.default.post(name: Notification.Name(self.t_r), object: self, userInfo: [
                    "type": ProgressType.THUMB_U_P,
                    "progress": p
                ])
                print("Upload Progress \(progress.fractionCompleted)")
            }.downloadProgress{ progress in
                let p = progress.fractionCompleted
                NotificationCenter.default.post(name: Notification.Name(self.t_r), object: self, userInfo: [
                    "type": ProgressType.THUMB_D_P,
                    "progress": p
                ])
                print("Upload Progress \(progress.fractionCompleted)")
            }.response{ response in
                if let mData = response.data{
                    let stringData = String(data: mData, encoding: String.Encoding.utf8)!
                    NotificationCenter.default.post(name: Notification.Name(self.t_r), object: self, userInfo: [
                        "type": ProgressType.THUMB_RESPONSE,
                        "response": stringData
                    ])
                }
            }
        }
    }
}
public class MyRequestInterceptor: RequestInterceptor {
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 15
        completion(.success(urlRequest))
    }
}
