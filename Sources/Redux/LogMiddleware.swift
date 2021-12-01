//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/11/30.
//

import Foundation

public typealias Log = (String, Any) -> Void

public func createLogMiddleware<State, Action>(_ log: @escaping Log) -> Enhancer<State, Action> {
    func middleware(_ getState: @escaping GetState<State>, _ dispatch: @escaping Dispatch<Action>) -> (@escaping Dispatch<Action>) -> Dispatch<Action> {
        return { originalDispatch in
            return { action in
                log("state:", getState())
                log("action:", type(of: action))
                originalDispatch(action)
                log("state:", getState())
            }
        }
    }
    return middleware
}
