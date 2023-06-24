//
//  PickerPrinterDevicePopView.swift
//  WanDD
//
//  Created by Bill liu on 2021/3/21.
//

import UIKit
import Reusable
import JWBluetoothPrinte
import PromiseKit

class DeviceCell : BaseLineCell, Reusable {
    
    lazy var choiceButton = UIButton.singleChoice().then{
        $0.isUserInteractionEnabled = false
    }
    
    lazy var iconImageView = UIImageView().then{
        $0.image = UIImage(named: "printer_device")
    }
    
    lazy var nameLabel = UILabel().then{
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = UIColor(named: "Title")
    }
    
    lazy var addressLabel = UILabel().then{
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor(named: "SubTitle")
        $0.textAlignment = .right
    }
    
    //MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override Method
    
    override func setupSubViews() {
        super.setupSubViews()
        contentView.addSubview(choiceButton)
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(addressLabel)
    }
    
    override func makeConstraintsSubViews() {
        super.makeConstraintsSubViews()
        choiceButton.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
            make.leading.equalTo(15)
            make.width.height.equalTo(21)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(choiceButton.snp.trailing).offset(16)
            make.centerY.equalTo(choiceButton)
            make.width.height.equalTo(15)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalTo(iconImageView)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.trailing.equalTo(-18)
            make.centerY.equalTo(nameLabel)
        }
    }
    
}


class PickerPrinterDevicePopView: AlertPopView {

    lazy var tableView = BaseTableView(frame: .zero, style: .plain).then {
        $0.register(cellType: DeviceCell.self)
        $0.delegate = self
        $0.dataSource = self
        $0.estimatedRowHeight =  53
    }
    
    private var dataSource : [CBPeripheral] = [] {
        didSet{
            tableView.reloadData()
            if dataSource.count > 0, !alreadyAutoConnect {
                alreadyAutoConnect = true
                _ = Self.autoConnect().done({ (connected) in
                    if connected {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    override var allowTouchOutsideDismiss: Bool{
        return false
    }
    
    private var alreadyAutoConnect = false
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Self.search {[weak self] (devices : [CBPeripheral]?, error : Error?) in
            if let _error = error {
                self?.contentView.presentMessage(message: _error.localizedDescription)
                return
            }
            self?.dataSource = devices ?? []
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override Method
    
    override func setupSubViews() {
        super.setupSubViews()
        
        titleLabel.text = "Print_Alert_Title".localized()
        cancelButton.setTitle("Alert_Cancel".localized(), for: .normal)
        confirmButton.setTitle("Print_Confirm_Title".localized(), for: .normal)
        
        containView.addSubview(tableView)
    }
    
    override func makeConstraintsSubViews() {
        super.makeConstraintsSubViews()
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            let height = tableView.estimatedRowHeight * 3
            make.height.equalTo(height)
        }
    }
    
    override func dismiss() {
        super.dismiss()
        let manager = JWBluetoothManage.sharedInstance()
        manager?.stopScanPeripheral()
    }
    
    override func confirmButtonAction(sender: UIButton) {
        let manager = JWBluetoothManage.sharedInstance()
        if manager?.stage != .characteristics {
            actionPromise.resolver.reject(CustomError.message(desc: "Print_Message_Preparing".localized()))
            return
        }
        actionPromise.resolver.fulfill(true)
        dismiss()
    }
    
    //MARK: - Connect
    
    private class func search(block : @escaping ([CBPeripheral]?, Error?) -> Void) {
        let manager = JWBluetoothManage.sharedInstance()
        //rssis : [NSNumber]?
        manager?.beginScanPerpheralSuccess({ (devices : [CBPeripheral]?, _) in
            block(devices, nil)
        }, failure: { (status : CBManagerState) in
            block(nil, CustomError.message(desc: ProgressShow.getBluetoothErrorInfo(status)))
        })
    }
    
    private class func autoConnect() -> Promise<Bool>{
        return Promise { (resolver) in
            let manager = JWBluetoothManage.sharedInstance()
            manager?.autoConnectLastPeripheralCompletion({ (_, error) in
                if error == nil{
                    resolver.fulfill(true)
                }else{
                    resolver.reject(error!)
                }
            })
        }
    }
    
    private class func connect(peripherral : CBPeripheral) -> Promise<Void> {
        let promise = Promise<Void> { (resolver) in
            let manager = JWBluetoothManage.sharedInstance()
            manager?.connect(peripherral, completion: { (_, error) in
                if error == nil {
                    resolver.fulfill_()
                }else{
                    resolver.reject(error!)
                }
            })
        }
        let timeout : Promise<Void> = after(seconds: 10).then { () -> Promise<Void> in
            return Promise(error: CustomError.cancel(desc: "Print_Message_Timeout".localized()))
        }
        return race(promise, timeout)
    }

}


extension PickerPrinterDevicePopView : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count == 0 ? 0:1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : DeviceCell = tableView.dequeueReusableCell(for: indexPath)
        let peripherral = dataSource[indexPath.row]
        cell.choiceButton.isSelected = peripherral.state == .connected
        cell.nameLabel.text = peripherral.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripherral = dataSource[indexPath.row]
        _ = firstly { () -> Promise<Void> in
            self.contentView.presentLoading()
            return Promise()
        }.then { () -> Promise<Void> in
            Self.connect(peripherral: peripherral)
        }.done { (_) in
            tableView.reloadData()
        }.ensure {
            self.contentView.dismissLoading()
        }.catch({ (error) in
            self.contentView.presentMessage(message: error.localizedDescription)
        })
    }
    
}
