//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/11/25.
//

import Foundation

@available(iOS 13.0, *)
public final class Store<State, Action>: ObservableObject {
    @Published private(set) var _state: State
    public var state: State { _state }
    
    private let reducer: Reducer<State, Action>
    
    public init(initialState: State, reducer: @escaping Reducer<State, Action>, enhancer: Enhancer<State, Action>? = nil) {
        self._state = initialState
        self.reducer = reducer
        self._dispatch = { (_ action: Action) -> Void in
            print("Dispatching while constructing your middleware is not allowed.")
        }
        
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
    
    func getState() -> State {
        self._state
    }
    private(set) var _dispatch: (Action) -> Void
    public var dispatch: (Action) -> Void { _dispatch }
}
