//
//  Regimen.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 12/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

var global: Int?

typealias BooleanTest = () -> Bool?
typealias BooleanTestHandler = (Bool?) -> Void
typealias BooleanErrorHandlerHandler = (@escaping BooleanErrorHandler) -> Void

enum TestStatus {
    case none
    case working
    case skipped
    case failure
    case success
}

class RoasterTest : NSObject, NSCopying {
    static var sequence: [RoasterTest] = [
        RoasterTest.init(name: "Generic Reset", stimulate: {handler in

            Roaster.shared.shutdown()
            handler(true, nil)

            
        }, detect: {handler in
            RoasterTest.wait(handler) {
                return Roaster.shared.state == .ready
            }
        })
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        , RoasterTest.init(name: "Ready -> Preheat", stimulate: {handler in
            if Roaster.shared.state == .ready {
                Roaster.shared.preheat(){error in
                    //too late; we have already returned
                }
                handler(true, nil)
            } else {
                handler(false, NSError.init())
            }
            
        }, detect: {handler in
            RoasterTest.wait(handler) {
                //capture the state
                let result = Roaster.shared.state == .preheat
                
                print("state ================================ \(Roaster.shared.state.stringValue)")
                
                //return machine to steady state
                Roaster.shared.shutdown()
                
                //return the result
                return result
            }
        })
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////

        , RoasterTest.init(name: "Bean Load (only if hopper inserted)", stimulate: {handler in
            if Roaster.shared.hopperInserted {

                handler(true, nil)
            } else {
                handler(false, NSError.init())
            }
            
        }, detect: {handler in
            RoasterTest.wait(handler) {
                //capture the state
                let result = Roaster.shared.state == .preheat
                
                print("state ================================ \(Roaster.shared.state.stringValue)")
                
                //return machine to steady state
                Roaster.shared.shutdown()
                
                //return the result
                return result
            }
        })
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        ,RoasterTest.init(name: "Bean Exit", stimulate: {handler in
            RoasterCommander.shared.setBeanExit(state: .open){_ in
            }
            
            handler(true, nil)
        }, detect: {handler in
            RoasterTest.wait(handler) {
                RoasterCommander.shared.beanExitState(completion: {bxs in
                    //we chave to return, so cannot detect at this point!
                })
                //execute your test and return a boolean
                return true
            }
        })

    ]
    
    //the working copy of the  sequence
    static var working = [RoasterTest]()
    
    
    var index: Int?
    var name: String
    var stimulate: (BooleanErrorHandler) -> Void
    var detect: (@escaping BooleanErrorHandler) -> Void
    var status: TestStatus = .none {
        didSet {RoasterTest.delegate?.statusDidChange(index: self.index, status: self.status)}
    }
    static var delegate: TestDelegate?
    
    func stimulate(completion: (BooleanErrorHandler) -> Void){}
    func detect(completion: (BooleanErrorHandler) -> Void){}
    
    init(name: String, stimulate: @escaping (BooleanErrorHandler) -> Void, detect: @escaping BooleanErrorHandlerHandler){
        self.name = name
        self.stimulate = stimulate
        self.detect = detect
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return RoasterTest.init(name: self.name, stimulate: self.stimulate, detect: self.detect)
    }
    
    static private func delayed(test: BooleanTest, handler: @escaping BooleanErrorHandler){
        print(#function)
        guard let success = test() else {
            return handler(false, NSError.init(domain: "Unknown", code: 0, userInfo: nil))
        }
        if success {
            handler(true, nil)
        } else {
            handler(false, NSError.init(domain: "Error", code: 0, userInfo: nil))
        }
    }
    
    
    static private func wait(duration: Int = 4, _ handler: @escaping BooleanErrorHandler, test: @escaping BooleanTest){
        print(#function)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration)) {
            RoasterTest.delayed(test: test, handler: handler)
        }
    }
    
    private func execute(index: Int, completion: @escaping IntErrorHandler){
        print(#function)
        self.index = index
        self.status = .working
        self.stimulate {success, error in
            
            //flag failure if there has been an error
            if let _ = error {self.status = .failure}
            
            //we should go ahead and detect now.
            self.detect {success, error in
                
                //flag success if we have not flagged it above and now new error ocurred
                if self.status == .working {self.status = error == nil ? .success : .failure}

                //we succeeded, so we tell the test runner that we are done
                RoasterTest.next(index: index, completion: completion)
            }
        }
    }
    
    static func run(completion: @escaping IntErrorHandler){
        //make a working copy of the test seque3nce
        working = sequence.map{$0.copy() as! RoasterTest}
        
        //kick off the testing
        self.next {tests, error in
            completion(tests, error)
        }
    }
    
    static func next(index: Int = -1, completion: @escaping IntErrorHandler){
        
        //the next in the working set
        let next = index + 1
        
        //if we reached the end, we are done, and we report the total number of executed tests
        guard next < working.count else {return completion(next, nil)}
        
        //execute the test
        working[next].execute(index: next, completion: completion)
    }
}

protocol TestDelegate {
    func statusDidChange(index: Int?, status: TestStatus)
}


