import Foundation

class TestDiplayLinkWrapper : SentryDisplayLinkWrapper {
    
    private var target: AnyObject!
    private var selector : Selector!
    
    override func link(withTarget target: Any, selector sel: Selector) {
        self.target = target as AnyObject
        self.selector = sel;
    }
    
    func call() {
        _ = target.perform(selector)
    }
    
    var internalTimestamp = 0.0
    
    override var timestamp: CFTimeInterval {
        return internalTimestamp
    }
    
    override func invalidate() {
        
    }
}
