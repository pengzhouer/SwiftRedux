//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/11/27.
//

import Foundation
import Redux

struct HistoryState {
    var fetching: Bool = false
    var data: [String]? = nil
    var error: String? = nil
    var fetchingMore: Bool = false
}

struct HistoryAction {
    struct Request: Action {
        
    }
    struct RequestSuccess: Action {
        let data: [String]
    }
    struct RequestFailure: Action {
        let error: String
    }
    struct Reset: Action {
        
    }
}

func historyReducer(_ state: HistoryState?, _ action: Action) -> HistoryState {
    let state = state ?? HistoryState()
    if let action = action as? HistoryAction.Request {
        return historyRequest(state: state, action: action)
    }
    if let action = action as? HistoryAction.RequestSuccess {
        return historyRequestSuccess(state: state, action: action)
    }
    if let action = action as? HistoryAction.RequestFailure {
        return historyRequestFailure(state: state, action: action)
    }
    if let action = action as? HistoryAction.Reset {
        return historyReset(state: state, action: action)
    }
    return state
}

func historyRequest(state: HistoryState, action: HistoryAction.Request) -> HistoryState {
    var state = state
    state.fetching = true
    state.error = nil
    return state
}

func historyRequestSuccess(state: HistoryState, action: HistoryAction.RequestSuccess) -> HistoryState {
    var state = state
    state.fetching = false
    state.data = action.data
    return state
}

func historyRequestFailure(state: HistoryState, action: HistoryAction.RequestFailure) -> HistoryState {
    var state = state
    state.fetching = false
    state.error = action.error
    return state
}

func historyReset(state: HistoryState, action: HistoryAction.Reset) -> HistoryState {
    return HistoryState()
}
