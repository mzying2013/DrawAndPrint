//
//  BaseController.swift
//  WanDD
//
//  Created by Bill liu on 2021/1/17.
//

import UIKit


class BaseController: UIViewController,ViewLayout {
    
    var canPopBack : Bool {
        get{
            return (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
    
    var canDismissBack : Bool {
        get{
            if let nav = navigationController {
                if nav.presentingViewController != nil {
                    return true
                }
            }else{
                if presentingViewController != nil{
                    return true
                }
            }
            
            return false
        }
    }
    
    var navItemTitle : String?
    
    
    //MARK: - Life Cycle
    
    init(navItemTitle : String?=nil) {
        self.navItemTitle = navItemTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //防止覆盖原来设置的有效标题
        if let _title = navItemTitle, !_title.isEmpty{
            navigationItem.title = navItemTitle
        }
        edgesForExtendedLayout = [.left,.bottom,.right]
        view.backgroundColor = UIColor(named: "ControllerBackground")
        
        setupNavigation()
        setupSubViews()
        makeConstraintsSubViews()
    }
    
    //MARK: - ViewLayout
    
    func setupSubViews() {
        
    }
    
    func makeConstraintsSubViews () {
        
    }
    
    func delaySetupSubViews() {
        
    }
    
    func delayMakeConstraintsSubViews() {
        
    }
    
    //MARK: - Override Method
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    
    deinit {
        print("\(type(of: self)) deinit...")
    }
    
    //MARK: - Sub Class
    
    func popGestureRecognizerEnable() -> Bool {
        return true
    }
    
    
    //MARK: - Navigation
    
    func setupNavigation(){
        if canPopBack || canDismissBack {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationItemBack"), style: .plain, target: self, action: #selector(navigationBarButtonItemAction(sender:)))
        }
    }
    
    func back(animated : Bool = true) {
        if canPopBack{
            navigationController?.popViewController(animated: animated)
        } else if canDismissBack{
            self.dismiss(animated: animated, completion: nil)
        }
    }
    
    
    //MARK: - UIControl Action
    
    @objc func navigationBarButtonItemAction(sender : Any){
        back()
    }
    

}
