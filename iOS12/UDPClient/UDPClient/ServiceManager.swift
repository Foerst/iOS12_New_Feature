//
//  ServiceManager.swift
//  UDPClient
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


class ServiceManager: NSObject {
    
    static let shared = ServiceManager()
    
    private override init() {
        super.init()
    }
    
    private lazy var queue = DispatchQueue.global(qos: .background)
    
    // serial queue
    private lazy var recvQueue = DispatchQueue(label: "recvQueue")
    
    var onReceiveData: ((Data?)->Void)?
    
    private lazy var txtRecord: Data = {
        let dictData = "hello world".data(using: String.Encoding.utf8)!
        let data = NetService.data(fromTXTRecord: ["node": dictData])
        return data
    }()
    
    func publishService(_ callback: ((Bool)->Void)? = nil){
        
        do {
            let listener = try NWListener(using: .udp)
            
            // Advertise a Bonjour service
            listener.service = NWListener.Service(name: ServiceConst.name, type: ServiceConst.type, domain: ServiceConst.domain, txtRecord: txtRecord)
            
            listener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("service ready")
                    DispatchQueue.main.async {
                        callback?(true)
                    }
                    
                case .failed(_):
                    DispatchQueue.main.async {
                        callback?(false)
                    }
                    
                default:
                    break
                }
            }
            
            listener.newConnectionHandler = { newConnection in
                
                newConnection.start(queue: self.recvQueue)
                
                newConnection.stateUpdateHandler = { (newState) in
                    switch(newState) {
                    case .ready:
                        // Handle connection established
                        print("connection ready")
                        
                        self.readHeader(connection: newConnection, headerLength: 4)
                        
                    case .waiting(let error):
                        // Handle connection waiting for network
                        print(error.debugDescription)

                    case .failed(let error):
                        // Handle fatal connection error
                        print(error.debugDescription)
                        
                    default:
                        
                        break
                    }
                    
                }
                   
            }
            
            listener.start(queue: queue)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    // MARK: parse header
    func readHeader(connection: NWConnection, headerLength: Int) {
        // Read exactly the length of the header
        connection.receive(minimumIncompleteLength: headerLength, maximumLength: headerLength)
        { (data, contentContext, isComplete, error) in
            if let error = error {
                // Handle error in reading
                print(error.localizedDescription)
            } else {
                // Parse out body length
                if let data = data {
                    print("RECEIVE DATA \(data.count) BYTES")
                    let bodyLength: Int = Int(Util.uint32FromData(data[0...3]))
                    self.readBody(connection, bodyLength: bodyLength, headerLength: headerLength)
                }
            }
        }
    }
    
    // Follow the same pattern as readHeader() to read exactly the body length
    func readBody(_ connection: NWConnection, bodyLength: Int, headerLength: Int) {
        let totalLength: UInt32 = UInt32(bodyLength + headerLength)
        let mtu: UInt32 = 1000
        let recvCount = totalLength % mtu == 0 ? totalLength / mtu : ( totalLength / mtu + 1)
        let minLength = 1
        
        var mData = Data()
        
        for _ in 1...recvCount {
            connection.receive(minimumIncompleteLength: minLength, maximumLength: bodyLength, completion: { (data, context, isComplete, error) in
                if let error = error {
                    // Handle error in reading
                    print(error.localizedDescription)
                } else {
                    // Parse out body length
                    if let data = data {
                        mData.append(data)
                        print("RECEIVE DATA \(data.count) BYTES")
                        if mData.count == bodyLength {
                            DispatchQueue.main.async {
                                self.onReceiveData?(mData)
                            }
                        }
                    }
                    
                }
            })
        }
        
    }
}
