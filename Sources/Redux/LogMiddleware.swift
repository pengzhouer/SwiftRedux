//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/11/30.
//

import Foundation

// 对外提供的传入参数类型Log
public typealias Log = (String, Any?) -> Void

public func createLogMiddleware<State, Action>(_ log: @escaping Log) -> Enhancer<State, Action> {
    func middleware(_ getState: @escaping GetState<State>, _ dispatch: @escaping Dispatch<Action>) -> (@escaping Dispatch<Action>) -> Dispatch<Action> {
        // 修改完的dispatch这里面用不到
        return { originalDispatch in
            return { action in
                // 每次外部dispatch一个action，便打印前后的状态和action类型，便于调试
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
