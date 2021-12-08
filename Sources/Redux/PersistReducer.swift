//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/12/4.
//

import Foundation

public protocol Persistent {
    associatedtype PersistState: Codable
    func persist() -> PersistState
    init(_: PersistState?)
}

extension UserDefaults {
    static let redux = UserDefaults.init(suiteName: "ReduxPersist")
}

public func persistReducer<State: Persistent, Action>(reducer: @escaping (State?, Action) -> State) -> (State?, Action) -> State{
    // 如果state为nil，代表这是在初始化state，这个时候要从userDefaults里面取出对应的state来初始化
    // 每次有新的action过来，都需要存储最新的state
    { state, action in
        let key = String(describing: State.self)
        var inputState: State? = nil
        if state == nil {
            let PersistState = type(of: State.self.init(nil).persist())
            if let json = UserDefaults.redux?.object(forKey: key) as? Data {
                if let persistState = try? JSONDecoder().decode(PersistState.self, from: json) {
                    inputState = State.self.init(persistState)
                } else {
                    print("\(key) json decode fail")
                }
            } else {
                print("Don't find \(key) from UserDefaults.redux, if this is the first time open the app, it's common.")
            }
        }
        
        let outputState = reducer(inputState ?? state, action)
        
        if let encoded = try? JSONEncoder().encode(outputState.persist()) {
            UserDefaults.redux?.set(encoded, forKey: key)
        } else {
            print("\(key) encode fail")
        }
        return outputState
    }
}

public func clearPersistentState() {
    if let reduxDB = UserDefaults.redux {
        reduxDB.dictionaryRepresentation().keys.forEach { key in
            reduxDB.removeObject(forKey: key)
        }
    }
}
