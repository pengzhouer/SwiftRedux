//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/11/25.
//

import Foundation

// 一个app只应有一个Store
@available(iOS 13.0, *)
public final class Store<State, Action>: ObservableObject {
    // _state是这个app的所有状态，所有状态只能通过dispatch action来更改，所以这里设置为private(set)
    @Published private(set) var _state: State
    // 因为_state不是public，为了在别的project中能够访问state，所以对外暴露了一个计算属性state
    public var state: State { _state }
    // reducer用于处理dipatch的action，这是一个纯方法
    private let reducer: Reducer<State, Action>
    // initialState是state的初始值，在外部建议通过直接调用reducer(action:)来初始化，enhancer为dispatch中间件，后续可以加入compose函数，组合多个中间件
    public init(initialState: State, reducer: @escaping Reducer<State, Action>, enhancer: Enhancer<State, Action>? = nil) {
        self._state = initialState
        self.reducer = reducer
        // 这个方法是用于中间件传递给别的地方便是的“加入了中间件的dispatch”，它不应该在enhancer函数声明周期内调用
        // 例如saga中的put便是在saga中间件中将此方法赋值给put
        self._dispatch = { (_ action: Action) -> Void in
            print("Dispatching while constructing your middleware is not allowed.")
        }
        // 这个方法实现了最原始的dispatch功能
        func dispatch(_ action: Action) {
            _state = reducer(_state, action)
        }
        if let enhancer = enhancer {
            // 要传给enhancer两个dispatch，一个是未加强的(dispatch)，一个是已加强的(self.dispatch)
            self._dispatch = enhancer(getState, self._dispatch)(dispatch)
        } else {
            self._dispatch = dispatch
        }
    }
    // 用于传给enhancer的，例如saga中的select便是调用了这个方法
    func getState() -> State {
        self._state
    }
    // dispatch用来发起一个action，_dispatch与_state同理
    private(set) var _dispatch: (Action) -> Void
    public var dispatch: (Action) -> Void { _dispatch }
}
