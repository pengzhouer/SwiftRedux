# Swift Redux
A Predictable State Container for Swift Apps
## Installation
### Swift Package Manager
For [Swift Package Manager](https://www.swift.org/package-manager/) add the following package to your Package.swift file. Just Swift 4 & 5 are supported:
```swift
.package(url: "https://github.com/13773753970/SwiftRedux.git", .upToNextMajor(from: "1.1.0")),
```
## Usage
This package provide the basic function for swift to manage our app state. There are many tutorial teach you how to use redux in swift, however, in this page I just recommend you the method how to use redux flexibly in large project.

**Given we have a video app, we want to store videos data as well as fetching state in our app.**
### Group
Firstly, we should create a group called "Redux" in root group of our project.
The final folder sturcture will be like this:  
* Redux  
  * VideoReducer.swift (we could add any child state and reducers like this file)
  * AppState.swift
  * RootReducer.swift
  * createStore.swift
### VideoReducer
Then we create a swift file under "Redux" Group called "VideoReducer":
```swift
import Foundation
import Redux
// State
struct Video {
    var name: String
    var url: String
}
struct VideoState {
    var fetching: Bool = false // initial value
    var data: [Video] = [] // initial value
}

// Action
struct VideoRequestAction: Action {
}
struct VideoRequestSuceessAction: Action {
    let data: [Video]
}

// Reducer
func videoReducer(_ state: VideoState?, _ action: Action) -> VideoState {
    let state = state ?? VideoState()
    if let action = action as? VideoRequestAction {
        return request(state: state, action: action)
    }else if let action = action as? VideoRequestSuceessAction {
        return requestSuccess(state: state, action: action)
    }
    return state
}

fileprivate func request(state: VideoState, action: VideoRequestAction) -> VideoState {
    var state = state
    state.fetching = true
    return state
}

fileprivate func requestSuccess(state: VideoState, action: VideoRequestSuceessAction) -> VideoState {
    var state = state
    state.fetching = false
    state.data = action.data
    return state
}
```
### AppState
After that, we should declare our AppState structure:
```swift
import Foundation

struct AppState {
    var video: VideoState
    // any other child state...
}
```
### RootReducer
Now, we could combine our child reducer to construct root reducer
```swift
import Foundation
import Redux

struct InitialAction: Action {}

// rootReducer() return initial state
func rootReducer(state: AppState? = nil, action: Action = InitialAction()) -> AppState {
    return AppState(
        video: videoReducer(state?.video, action)
    )
}
```
### createStore
Finally, we could expose Store instance by func createStore:
```swift
import Foundation
import Redux

typealias AppStore = Store<AppState, Action>

func createStore() -> AppStore {
    return Store(
        initialState: rootReducer(),
        reducer: rootReducer,
        // you could add some enhancers in this place
        // We plan to add saga middleware to enhance redux.
        enhancer: createLogMiddleware({ message, obj in
            // print action, state before action, and state after action
            // you could use some packages to handle the message and state by yourself.
            print(message, obj)
        }))
}
```
### subscribe state
```swift
import SwiftUI

@main
struct ReduxExampleApp: App {
    @StateObject private var store: AppStore = createStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
```
```swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack {
            Text(store.state.video.fetching ? "Loading" : "Hello World")
                .padding()
            HStack(spacing: 20) {
                Button(action: {
                    store.dispatch(VideoRequestAction())
                }, label: {
                    Text("request")
                })
                Button(action: {
                    store.dispatch(VideoRequestSuceessAction(data: [Video(name: "abc", url: "http://www.baidu.com")]))
                }, label: {
                    Text("requestSuccess")
                })
            }
        }
    }
}
```
**If you want to add some other state, you could follow VideoReducer and add some other "ChildReducers".**

## Persist state
For example, we want to persist `store.state.video.data`. 
We should make `VideoState` follow Protocol `Persistent`, and expose persistentVideoReducer by wrapping the original reducer func:
```swift
struct Video: Codable {
    var name: String
    var url: String
}

struct VideoState: Persistent {
    var fetching: Bool = false
    var data: [Video] = []
    struct PersistedState: Codable {
        var data: [Video]
    }
    init() {}
    init(persistedState: PersistedState) {
        self.data = persistedState.data
    }
    func persist() -> PersistedState {
        PersistedState(data: self.data)
    }
}

let persistentVideoReducer = persistReducer(reducer: videoReducer)
```
Then you should replace `videoReducer` by `persistentVideoReducer` in RootReducer.swift. 
After that, we successfully persist store.state.video.data
```swift
func rootReducer(state: AppState? = nil, action: Action = InitialAction()) -> AppState {
    return AppState(
        video: persistentVideoReducer(state?.video, action)
    )
}
```
## Example
We write one example project [Game-2048](https://github.com/13773753970/Game-2048) use this package to manage app state.

## License
