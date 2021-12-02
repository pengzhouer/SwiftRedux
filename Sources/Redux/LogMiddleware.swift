//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/11/30.
//

import Foundation

public typealias Log = (String, Any?) -> Void

public func createLogMiddleware<State, Action>(_ log: @escaping Log) -> Enhancer<State, Action> {
    func middleware(_ getState: @escaping GetState<State>, _ dispatch: @escaping Dispatch<Action>) -> (@escaping Dispatch<Action>) -> Dispatch<Action> {
        return { originalDispatch in
            return { action in
                log("------------------------------------------------------", nil)
                log("prevState", getState())
                log("action", type(of: action as Any))
                originalDispatch(action)
                log("afterState", getState())
                log("------------------------------------------------------", nil)
            }
        }
    }
    return middleware
}
