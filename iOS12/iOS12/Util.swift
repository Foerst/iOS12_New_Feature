//
//  TLVUtil.swift
//  JimuMagnetic
//
//  Created by CXY on 2019/4/11.
//  Copyright © 2019年 ubt. All rights reserved.
//

import Foundation

class Util: NSObject {
    class func dataFromUint8(_ value: UInt8) -> Data {
        var byteArray: [UInt8] = [0]
        byteArray[0] = value & 0xff
        return Data(byteArray)
    }
    
    class func dataFromUint16(_ value: UInt16) -> Data {
        var byteArray: [UInt8] = [0, 0]
        byteArray[0] = UInt8(value >> 8 & 0xff)
        byteArray[1] = UInt8(value & 0xff)
        return Data(byteArray)
    }
    
    class func dataFromUint32(_ value: UInt32) -> Data {
        var byteArray: [UInt8] = [0, 0, 0, 0]
        
        byteArray[3] = UInt8(value & 0xff)
        byteArray[2] = UInt8(value >> 8 & 0xff)
        byteArray[1] = UInt8(value >> 16 & 0xff)
        byteArray[0] = UInt8(value >> 24 & 0xff)
        
        return Data(byteArray)
        
        /*var bigEndian = value.bigEndian
         let count = MemoryLayout<UInt32>.size
         let bytePtr = withUnsafePointer(to: &bigEndian) {
         $0.withMemoryRebound(to: UInt8.self, capacity: count) {
         UnsafeBufferPointer(start: $0, count: count)
         }
         }
         let xxArray = Array(bytePtr)
         print(xxArray)
         return Data(bytes: xxArray)*/
    }
    
    class func dataFromString(_ value: String) -> Data {
        var tempString = String(value)
        tempString.append("\0")
        let data: Data = value.data(using: .utf8)!
        return data
    }
    
    class func uint8FromData(_ data: Data) -> UInt8 {
        var byteArray: [UInt8] = [0]
        let bytePtr = UnsafeMutableBufferPointer<UInt8>(start: &byteArray, count: byteArray.count)
        _ = data.copyBytes(to: bytePtr)
        
        return UInt8(bytePtr[0]) & 0xff
    }
    
    class func uint16FromData(_ data: Data) -> UInt16 {
        var byteArray: [UInt8] = [0, 0]
        let bytePtr = UnsafeMutableBufferPointer<UInt8>(start: &byteArray, count: byteArray.count)
        _ = data.copyBytes(to: bytePtr)
        
        return (UInt16((bytePtr[1] & 0xff)) << 0) + (UInt16((bytePtr[0] & 0xff)) << 8)
    }
    
    class func uint32FromData(_ data: Data) -> UInt32 {
        var byteArray: [UInt8] = [0, 0, 0, 0]
        let bytePtr = UnsafeMutableBufferPointer<UInt8>(start: &byteArray, count: byteArray.count)
        _ = data.copyBytes(to: bytePtr)
        
        var result: UInt32 = (UInt32((bytePtr[3] & 0xff)) << 0)
        result += (UInt32((bytePtr[2] & 0xff)) << 8)
        result += (UInt32((bytePtr[1] & 0xff)) << 16)
        result += (UInt32((bytePtr[0] & 0xff)) << 24)
        
        return result
    }
    
    class func stringFromData(_ data: Data) -> String {
        guard data.count == 0 else {
            return String(data: data, encoding: .utf8)!
        }
        return String()
    }
    
    class func uint8ArrayFromData(_ data: Data) -> [UInt8] {
        return [UInt8](data)
    }
    
    
    private class func isValidHex(_ asciiHex:String) -> Bool{
        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)
        
        let found = regex.firstMatch(in: asciiHex, options: [], range: NSMakeRange(0, asciiHex.count))
        if found == nil || found?.range.location == NSNotFound || asciiHex.count % 2 != 0 {
            return false
        }
        
        return true
    }
    
    class func UInt8ArrayFromAsciiHexString(_ hexString: String) -> [UInt8]? {
        let trimmedString = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
        
        if(isValidHex(trimmedString)){
            var data = [UInt8]()
            var index = 0
            while index < trimmedString.count {
                
                let start = trimmedString.index(trimmedString.startIndex, offsetBy: index);
                let finish = trimmedString.index(trimmedString.startIndex,offsetBy: index+1);
                let range = start...finish
                let byteString = trimmedString[range]
                
                let byte = UInt8(byteString.withCString { strtoul($0, nil, 16) })
                data.append(byte)
                
                index = index+2;
            }
            
            return data
        }
        return nil
    }
    
    public class func asciiHexStringFromUInt8Array(_ array: [UInt8]) -> String {
        let strings = array.map { (item) -> String in
            return String(format: "%02X", item)
        }
        return strings.joined(separator: " ")
    }
    
    public class func asciiHexStringFromData(_ data: Data) -> String {
        return asciiHexStringFromUInt8Array(uint8ArrayFromData(data))
    }
}


extension Range where Bound == Int {
    func contains(otherRange: Range<Int>) -> Bool {
        return contains(otherRange.lowerBound) && contains(otherRange.upperBound-1)
    }
}
