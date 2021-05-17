import XCTest

@available(iOS 10.0, *)
class SentryFramesTrackerTests: XCTestCase {

 

    func testExample() {
        let displayLinkWrapper = TestDiplayLinkWrapper()
        let sut = SentryFramesTracker(options: Options(), displayLinkWrapper: displayLinkWrapper)
        
        sut.start()
        
        
        let queue = DispatchQueue(label: "SentryFramesTrackerTests", qos: .background, attributes: [.concurrent])
        let group = DispatchGroup()
        
        for _ in 0 ... 60000 {
            displayLinkWrapper.call()
            displayLinkWrapper.internalTimestamp += 0.02
        }
        
        queue.async {
            group.enter()
            for _ in 0 ... 600000 {
                displayLinkWrapper.call()
                displayLinkWrapper.internalTimestamp += 0.02
            }
            group.leave()
        }
        
        queue.async {
            group.enter()
            for _ in 0 ... 600000 {
                let actual = sut.slowFrames(Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 10000))
                
                XCTAssertEqual(60, actual)
            }
            group.leave()
        }
        
        for _ in 0 ... 600000 {
            displayLinkWrapper.call()
            displayLinkWrapper.internalTimestamp += 0.02
        }
        
        group.wait()
        
        
        let actual = sut.slowFrames(Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100000))
        
        XCTAssertEqual(60, actual)
        
    }


}
