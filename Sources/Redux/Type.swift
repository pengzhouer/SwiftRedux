//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/11/25.
//

import Foundation

public protocol Action {
    
}

public typealias Reducer<State, Action> = (State, Action) -> State
public typealias GetState<State> = () -> State
public typealias Dispatch<Action> = (Action) -> Void
public typealias Enhancer<State, Action> = (@escaping GetState<State>, @escaping Dispatch<Action>) -> (@escaping Dispatch<Action>) -> Dispatch<Action>
