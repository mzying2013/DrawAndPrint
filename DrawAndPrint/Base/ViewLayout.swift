//
//  ViewLayout.swift
//  WanDD
//
//  Created by Bill liu on 2021/1/17.
//

import Foundation

///视图布局
protocol ViewLayout {
    ///子视图添加和设置
    func setupSubViews()
    ///子视图布局
    func makeConstraintsSubViews()
    
    ///延迟的子视图添加和设置，如果视图需要根据返回数据初始化，则建议使用该方法。（需要手动调用）
    func delaySetupSubViews()
    ///延迟的子视图布局，如果视图需要根据返回数据动态布局，则建议使用该方法。（需要手动调用）
    func delayMakeConstraintsSubViews()
    
}


extension ViewLayout {
    
    func delaySetupSubViews(){}
    func delayMakeConstraintsSubViews(){}
    
}

