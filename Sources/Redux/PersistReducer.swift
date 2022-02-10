//
//  File.swift
//  
//
//  Created by zhoupeng on 2021/12/4.
//

import Foundation

// 需要缓存的State需要实现这个协议，其中PersistedState是存储的state，它需要遵循Codable类型
// persist方法是用来存储PersistedState，init(persistedState:)是根据存储的state来恢复数据的
public protocol Persistent {
    associatedtype PersistedState: Codable, Equatable
    func persist() -> PersistedState
    init(persistedState: PersistedState)
}

// 在reducer的基础上提供持久化服务，State需要遵循Persistent协议
public func persistReducer<State: Persistent, Action>(reducer: @escaping (State?, Action) -> State) -> (State?, Action) -> State{
    // 如果state为nil，代表这是在初始化state，这个时候要从userDefaults里面取出对应的state来初始化
    // 每次有新的action过来，都需要存储最新的state
    { state, action in
        // 以state的结构体名称为key进行存储
        let key = "redux-" + String(describing: State.self)
        // 传给reducer的初始值
        var inputState: State? = nil
        if state == nil {
            // 持久化的state的类型
            let PersistedState = State.PersistedState.self
            // 先到Userdefaults.redux里找key对应的值
            if let json = UserDefaults.standard.object(forKey: key) as? Data {
                if let persistedState = try? JSONDecoder().decode(PersistedState.self, from: json) {
                    // 如果找到，将它恢复成原本的state结构，用来传入reducer作为初始值
                    inputState = State.self.init(persistedState: persistedState)
                } else {
                    print("\(key) json decode fail, this reason because you changed the persisted structure." +
                          "Don't worry, just lost the data persist before.")
                }
            } else {
                print("Don't find \(key) from UserDefaults.redux, if this is the first time open the app, it's common.")
            }
        }
        // 如果state为空，那就通过已存储的数据来恢复，如果state不为空，还是传递原来的state
        let outputState = reducer(inputState ?? state, action)
        // 将新的state的值需要持久化的存入UserDefaults.redux
        if state != nil && state?.persist() != outputState.persist() {
            if let encoded = try? JSONEncoder().encode(outputState.persist()) {
                UserDefaults.standard.set(encoded, forKey: key)
            } else {
                print("\(key) encode fail")
            }
        }
        return outputState
    }
}

// 清除Userdefaults.redux里面所有值
public func clearPersistentState() {
    UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
        if key.prefix(6) == "redux-" {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
