//
//  ViewController.swift
//  DrawAndPrint
//
//  Created by bill on 2023/6/24.
//

import UIKit
import UberSignature
import SnapKit
import Then

class ViewController: BaseController {
    lazy var subController : SignatureDrawingViewController = {
        let controller = SignatureDrawingViewController()
        return controller
    }()
    lazy var printButton = UIButton(type: .custom).then { (v: UIButton) in
        v.setImage(UIImage(systemName: "printer"), for: .normal)
    }
    
    override func setupSubViews() {
        super.setupSubViews()
        
        addChild(subController)
        view.addSubview(subController.view)
        subController.didMove(toParent: self)
        view.addSubview(printButton)
    }
    override func makeConstraintsSubViews() {
        super.makeConstraintsSubViews()
        subController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        printButton.snp.makeConstraints { make in
            make.top.equalTo(printButton.superview!.safeAreaLayoutGuide.snp.top).offset(16)
            make.trailing.equalTo(-16)
        }
    }
}

