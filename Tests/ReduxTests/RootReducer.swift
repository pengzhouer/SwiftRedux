//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/11/27.
//

import Foundation
import Redux

func rootReducer(state: AppState? = nil, action: Action) -> AppState {
    return AppState(
        history: historyReducer(state?.history, action)
    )
}
