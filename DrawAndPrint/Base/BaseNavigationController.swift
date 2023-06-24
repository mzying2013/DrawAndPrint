//
//  BaseNavigationController.swift
//  MMovie
//
//  Created by Bill liu on 2020/10/26.
//

import UIKit


class PopGestureRecognizer : NSObject, UIGestureRecognizerDelegate {
    
    //MARK: - Life Cycle
    weak var nav : UINavigationController?
    
    init(nav : UINavigationController) {
        self.nav = nav
        super.init()
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        guard (nav?.viewControllers.count ?? 0) > 1 else {
            return false
        }
        
        let last = nav?.viewControllers.last
        if let base = last as? BaseController {
            return base.popGestureRecognizerEnable()
        }
        
        return true
    }
    
    
}


class BaseNavigationController: UINavigationController {
    
    lazy var pop : PopGestureRecognizer = {
        return PopGestureRecognizer(nav: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "ControllerBackground")
        interactivePopGestureRecognizer?.delegate = pop
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count >= 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

}
