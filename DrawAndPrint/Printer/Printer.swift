//
//  Printer.swift
//  WanDD
//
//  Created by Bill liu on 2021/3/21.
//

import Foundation
import LBXPermission
import PromiseKit
import JWBluetoothPrinte


class Printer {
    
    //MARK: - Data
    
//    struct PrintData {
//        ///服务部门
//        var service  = kDefaultText
//        ///餐厅名称
//        var restaurant = kDefaultText
//        ///配送时间
//        var date = kDefaultText
//        ///商品组
//        var goods : [DeliveryGoodsMappable] = []
//        ///店存
//        var restCount : Int = 0
//        ///配送人
//        var account : String {
//            get{
//                let user : User? = UserManager.default.get()
//                return user?.account?.name ?? kDefaultText
//            }
//        }
//        ///交易单号
//        var transactionNumber = kDefaultText
//        ///签名
//        var signature : UIImage?
//
//    }
    
    private class func auth() -> Promise<Bool>{
        return Promise(resolver: { (resolver) in
            LBXPermissionBluetooth.authorize { (granted : Bool, firstTime : Bool) in
                if !granted && !firstTime {
                    LBXPermissionSetting.showAlertToDislayPrivacySetting(withTitle: "Auth_Alert_Title".localized(), msg: "Bluetooth_Auth_Alert_Message".localized(), cancel: "Alert_Cancel".localized(), setting: "SignUp_Completed_Confirm".localized())
                }
                resolver.fulfill(granted)
            }
        })
    }
    
    private class func picker(on view : UIView) -> Promise<Bool> {
        let popView = PickerPrinterDevicePopView()
        popView.show(on: view)
        return popView.actionPromise.promise
    }
    
    private class func sendPrint(data : Data) -> Promise<Void>{
        return Promise { (resolver) in
            let manager = JWBluetoothManage.sharedInstance()
            manager?.sendPrint(data, completion: { (completion, _, error) in
                if completion {
                    resolver.fulfill_()
                }else{
                    resolver.reject(CustomError.message(desc: error ?? ""))
                }
            })
        }
    }
    
    private class func alertForPrintAgain(on view : UIView) -> Promise<Bool> {
        let alert = MessageAlertPopView(message: "Print_Alert_Again".localized())
        alert.show(on: view)
        return alert.actionPromise.promise
    }
    
    
    //MARK: - Public Method
    
    /// - Parameters:
    ///   - view: 弹框父视图
    ///   - http: 模板请求接口
    ///   - image: 签名图片，可以为 nil
    ///   - repeatPrint: 餐厅是否要求再次打印
    /// - Returns: 打印是否成功
    class func print(on view : UIView, http : HTTP, image : UIImage? = nil, repeatPrint : Bool = true) -> Promise<Bool> {
        typealias H = HTTPMappable<PrinterRowMappable>
        
        return firstly{() -> Promise<Bool> in
            return auth()
            
        }.then { (auth) -> Promise<Bool> in
            if auth {
                return picker(on: view)
            }else{
                return Promise(error: CustomError.cancel(desc: ""))
            }
            
        }.then { (action) -> Promise<H> in
            guard action else{
                return Promise(error: CustomError.cancel(desc: ""))
            }
            let promise : Promise<H> = HTTP.request(http)
            return promise
            
        }.then { (data : H) -> Promise<Void> in
            let printData = PrinterTemplate.data(rows: data.dataArray ?? [], image: image)
            if let _printData = printData{
                return sendPrint(data: _printData)
            }else{
                return Promise(error: CustomError.cancel(desc: ""))
            }
            
        }.then { (_) -> Promise<Bool> in
            if repeatPrint {
                return alertForPrintAgain(on: view)
            }else{
                return Promise.value(false)
            }
            
        }.then { (result) -> Promise<Bool> in
            if result {
                return print(on: view, http: http, image: image, repeatPrint: false)
            }else{
                return Promise.value(true)
            }
        }
    }
    
    
}
