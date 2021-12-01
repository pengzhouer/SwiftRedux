import XCTest
@testable import Redux

struct InitialAction: Action {
}

final class ReduxTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(Redux().text, "Hello, World!")
    }
    
    func stateEqual(_ lhs: AppState, _ rhs: AppState) -> Bool {
        return lhs.history.fetching == rhs.history.fetching && lhs.history.fetchingMore == rhs.history.fetchingMore &&
        lhs.history.data == rhs.history.data && lhs.history.error == rhs.history.error
    }
    
    @available(iOS 13.0, *)
    func testRedux() {
        let store = Store(initialState: rootReducer(action: InitialAction()), reducer: rootReducer)
        var appState = AppState(
            history: HistoryState()
        )
        XCTAssert(stateEqual(store.state, appState))
        
        store.dispatch(HistoryAction.Request())
        appState.history.fetching = true
        XCTAssert(stateEqual(store.state, appState))
        
        store.dispatch(HistoryAction.RequestFailure(error: "TEST ERROR"))
        appState.history.fetching = false
        appState.history.error = "TEST ERROR"
        XCTAssert(stateEqual(store.state, appState))
        
        store.dispatch(HistoryAction.Reset())
        appState = AppState(
            history: HistoryState()
        )
        XCTAssert(stateEqual(store.state, appState))
    }
}
