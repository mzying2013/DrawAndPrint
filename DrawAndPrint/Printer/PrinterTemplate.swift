//
//  PrinterTemplate.swift
//  WanDD
//
//  Created by Bill liu on 2021/3/24.
//

import ObjectMapper
import JWBluetoothPrinte

/*
 {
     "data":[
         {
             //空白行
             "type" : 0
         },
         {
             //虚线行
             "type" : 1
         },
         {
             //标题（默认居中）
             "type" : 2,
             "title" : "我是标题"
         },
         {
             //正文
             "type" : 3,
             "title" : "店存",
             "value" : "728",
             //0: 靠左，1：居中，2：靠右 3:左右对齐
             "alignment" : 3
         },
         {
             //图片
             "type" : 4,
             "title" : "签收人"
         }
     ]
 }
 */
struct PrinterRowMappable : Mappable{
    
    enum RowType : Int {
        case newLine
        case dottedLine
        case title
        case content
        case image
    }
    
    ///0: 靠左，1：居中，2：靠右 3:左右对齐
    enum Alignment : Int {
        case left
        case center
        case right
        case alignBothSides
        
        func textAlignment() -> HLTextAlignment{
            switch self {
            case .left:
                return .left
            case .center:
                return .center
            case .right:
                return .right
            default:
                return .left
            }
        }
        
        func shouldAppendText() -> Bool{
            let textAlignments : [Alignment] = [.left, .center, .right]
            return textAlignments.contains(self)
        }
    }
    
    var type : RowType = .newLine
    var title = kDefaultText
    var value = kDefaultText
    var alignment : Alignment = .alignBothSides
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        type <- map["type"]
        title <- map["title"]
        value <- map["value"]
        alignment <- map["alignment"]
    }
    
}




struct PrinterTemplate {
    
    static let kPrinterImageWidth : CGFloat = 200
    
    static func data(rows : [PrinterRowMappable], image : UIImage? = nil) -> Data?{
        let printer = JWPrinter()
        
        rows.forEach {
            switch $0.type {
            case .newLine:
                printer.appendNewLine()
            case .dottedLine:
                printer.appendSeperatorLine()
            case .title:
                printer.appendText($0.title, alignment: .center, fontSize: .titleSmalle)
            case .content:
                if $0.alignment.shouldAppendText() {
                    printer.appendText($0.title + $0.value, alignment: $0.alignment.textAlignment(), fontSize: .titleSmalle)
                }else{
                    // 32，每行 32 个英文字符。
                    let value = $0.value
                    let space = 32 - ($0.title.numberOfChars() + value.numberOfChars())
                    var text: String = $0.title
                    
                    if space <= 0 {
                        // 至少一个空格
                        text += " "
                    } else {
                        for _ in 0..<space {
                            text += " "
                        }
                    }
                    text.append(value)
                    printer.appendText(text, alignment: .left)
                }
            case .image:
                printer.appendText($0.title, alignment: .left, fontSize: .titleSmalle)
                if let _image = image {
                    let __image = _image.withBackground(color: .white)
                    printer.append(__image, alignment: .center, maxWidth: kPrinterImageWidth)
                }
                break
            }
        }
        
        let data = printer.getFinalData()
        return data
    }
    
}
