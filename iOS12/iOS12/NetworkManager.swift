//
//  NetServiceDetector.swift
//  iOS12
//
//  Created by CXY on 2019/5/7.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit
import Network

struct ServiceConst {
    static let domain = "local."
    static let type = "_camera._udp"
    static let name = "camera"
    static let port: Int32 = 2333
}


class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    private override init() {
        super.init()
    }
    
    private lazy var queue = DispatchQueue.global(qos: .background)
    
    private lazy var sendQueue = DispatchQueue(label: "com.cxy.sendQ")
    
    private var browser: NetServiceBrowser?
    
    private var service: NetService?
    
    private var connection: NWConnection?
    
    private lazy var services = [NetService]()
    
    private var searchFinished: (([NetService])->Void)?
    
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    
    func detectServices(_ finished: (([NetService])->Void)? = nil) {
        queue.async {
            let runloop = RunLoop.current
            let browser = NetServiceBrowser()
            browser.delegate = self
            browser.schedule(in: runloop, forMode: .common)
            browser.searchForServices(ofType: ServiceConst.type, inDomain: ServiceConst.domain)
            runloop.run(until: Date(timeIntervalSinceNow: 30))
            self.browser = browser
        }
        searchFinished = finished
    }
    
    func connectService(_ callback: @escaping (Bool, String?)->Void) {
        let connection = NWConnection(to: NWEndpoint.service(name: ServiceConst.name, type: ServiceConst.type, domain: ServiceConst.domain, interface: nil), using: .udp)
        
        connection.stateUpdateHandler = { (newState) in
            switch(newState) {
            case .ready:
                // Handle connection established
                print("ready")
                
                print(connection.endpoint)
                
                DispatchQueue.main.async {
                    callback(true, nil)
                }
                
            case .waiting(let error):
                // Handle connection waiting for network
                print(error.debugDescription)

                DispatchQueue.main.async {
                    callback(true, error.debugDescription)
                }
                
            case .failed(let error):
                // Handle fatal connection error
                print(error.debugDescription)
                
                DispatchQueue.main.async {
                    callback(true, error.debugDescription)
                }
                
            default:

                break
            }
            
        }
        
        connection.start(queue: queue)
        self.connection = connection
    }
}

extension NetworkManager: NetServiceBrowserDelegate {
    
    // MARK: didFind service
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("----netServiceBrowser didFind", service.domain, service.type, service.name, service.port)
        
        /*
        var inStream: InputStream?, outStream: OutputStream?
        service.getInputStream(&inStream, outputStream: &outStream)
        inputStream?.delegate = self
        outputStream?.delegate = self
        inStream?.schedule(in: RunLoop.current, forMode: .common)
        outStream?.schedule(in: RunLoop.current, forMode: .common)
        inStream?.open()
        outStream?.open()
        inputStream = inStream
        outputStream = outStream
        */
        
        if !services.contains(service) {
            services.append(service)
        }
        service.delegate = self
        service.resolve(withTimeout: 5)
//        service.schedule(in: RunLoop.current, forMode: .common)
        DispatchQueue.main.async {
            self.searchFinished?(self.services)
        }
        
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("----netServiceBrowser didRemove")
    }
}

extension NetworkManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted://stream opened,ready to read&write
            print("")
        case Stream.Event.hasBytesAvailable: //can read bytes
            readData()
        case Stream.Event.hasSpaceAvailable://can write bytes
            print("")
        default:
            print("")
        }
        
    }
    
    fileprivate func readData() {
        guard let inputStream = inputStream else {
            return
        }
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while inputStream.hasBytesAvailable {
            let read = inputStream.read(buffer, maxLength: bufferSize)
            if (read == 0) {
                break
            }
            data.append(buffer, count: read)
        }
        
        var str = String(data: data, encoding: .utf8)
        if let char = str?.last, char == "\0" {
            str?.removeLast()
        }
//        if let msg = str, let callBack = readCallBack {
//            callBack(msg)
//        }
    }
    
    func writeData(string: String) -> Bool {
        let tmp = string.data(using: .utf8)
        if let data = tmp {
            outputStream?.write(Array(data), maxLength: 1024)
        }
        return false
    }
}

extension NetworkManager: NetServiceDelegate {
    
    // MARK: WillResolve
    func netServiceWillResolve(_ sender: NetService) {
        print("----netService willResolve")
    }
    
    // MARK: Resolve Succeed
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("----netService didResolveAddress", sender.name, sender.addresses ?? "", sender.hostName ?? "", sender.addresses?.first ?? "")
        if let data = sender.txtRecordData() {
            let dict = NetService.dictionary(fromTXTRecord: data)
            let info = String(data: dict["node"] ?? Data(), encoding: String.Encoding.utf8)
            print("mac info = ", info ?? "");
        }
    }
    
    // MARK: Resolve Error
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("----netService didNotResolve ", errorDict)
    }
    
    // MARK: ServiceDidStop
    func netServiceDidStop(_ sender: NetService) {
        print("----netServiceDidStop")
    }
    
    // MARK: didUpdateTXTRecord
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("----netService didUpdateTXTRecord")
    }
    
    // MARK:
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        print("----netService didAcceptConnectionWith")
        
    }
    
    // MARK: util 
    func IPFrom(data: Data) -> String {
        let dataIn: NSData = data as NSData
        var storage = sockaddr_storage()
        dataIn.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)
        if Int32(storage.ss_family) == AF_INET {
            let addr4 = withUnsafePointer(to: &storage) {
                $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                    $0.pointee
                }
            }
            let ipString =  String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii)
            print("ip", ipString!)
            return ipString ?? ""
        }
        return ""
    }
    
    //MARK: Send a single frame
    func sendFrame(_ frame: Data) {
        if frame.count <= 0 { return }
        sendQueue.async {
            var tmp = Data(referencing: frame as NSData)
            // add header, first byte equal to length of data
            
            let header = Util.dataFromUint32(UInt32(frame.count))
            tmp = header + tmp
            
            var array = [Data]()
            let mtu = 1000
            
            if frame.count > mtu {
                while !tmp.isEmpty {
                    let data = tmp.prefix(mtu)
                    array.append(data)
                    tmp.removeFirst(data.count)
                }
            } else {
                array.append(tmp)
            }
            
            self.sendFrames(array)
        }
        
    }
    
    //MARK: Hint that multiple datagrams should be sent as one batch
    private func sendFrames(_ frames: [Data]) {
        connection?.batch {
            for frame in frames {
                // The .contentProcessed completion provides sender-side back-pressure
                connection?.send(content: frame, completion: .contentProcessed({ (sendError) in
                    if let sendError = sendError {
                        // Handle error in sending
                        print(sendError.localizedDescription)
                    } else {
                        print("SEND DATA \(frame.count) BYTES")
                    }
                }))
                
            }
        }
    }

}
