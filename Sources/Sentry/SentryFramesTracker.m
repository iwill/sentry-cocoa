#import "SentryFramesTracker.h"
#import "SentryOptions.h"
#import "SentryLog.h"
#import "SentryDisplayLinkWrapper.h"

#if SENTRY_HAS_UIKIT
#    import <UIKit/UIKit.h>
#endif

static CFTimeInterval const SentryFrozenFrameThreshold = 0.7;

@interface SentryFramesTracker()

@property (nonatomic, strong, readonly) SentryOptions *options;
@property (nonatomic, assign, readonly) CFTimeInterval slowFrameThreshold;
@property (nonatomic, strong, readonly) SentryDisplayLinkWrapper *displayLinkWrapper;

@end

static const int slowFramesSize = 60;
static const int frozenFramesSize = 10;


@implementation SentryFramesTracker {
    int slowFrameIndex;
    CFAbsoluteTime slowFrames[slowFramesSize];
    
    int frozenFrameIndex;
    CFAbsoluteTime frozenFrames[frozenFramesSize];
}

- (instancetype)initWithOptions:(SentryOptions *)options displayLinkWrapper:(SentryDisplayLinkWrapper *)displayLinkWrapper {
    if (self = [super init]) {
        _options = options;
        _displayLinkWrapper = displayLinkWrapper;
        // Most frames take just a few microseconds longer than the optimal caculated duration.
        // Therefore we substract one, because otherwise almost all frames would be slow.
        _slowFrameThreshold = 1 / ((double)[UIScreen.mainScreen maximumFramesPerSecond] - 1);
        
        slowFrameIndex = 0;
        frozenFrameIndex = 0;
    }
    return self;
}

-(void)start {
    [_displayLinkWrapper linkWithTarget:self selector:@selector(displayLinkCallback)];
}

- (void)displayLinkCallback {
    static CFTimeInterval previousFrameTimestamp = -1;
    CFTimeInterval lastFrameTimestamp = self.displayLinkWrapper.timestamp;
    CFTimeInterval frameDuration = lastFrameTimestamp - previousFrameTimestamp;
    
    if (frameDuration > self.slowFrameThreshold && frameDuration < SentryFrozenFrameThreshold) {
           [SentryLog logWithMessage:[NSString stringWithFormat:@"FPS: %f SlowFrame: %f", lastFrameTimestamp, frameDuration] andLevel:kSentryLevelDebug];
        
        slowFrames[slowFrameIndex] = lastFrameTimestamp;
        slowFrameIndex = (slowFrameIndex + 1) % slowFramesSize;
    }
    
    if (frameDuration > SentryFrozenFrameThreshold) {
           [SentryLog logWithMessage:[NSString stringWithFormat:@"FPS: %f FozenFrame: %f", lastFrameTimestamp, frameDuration] andLevel:kSentryLevelDebug];
        
        frozenFrames[frozenFrameIndex] = lastFrameTimestamp;
        frozenFrameIndex += (frozenFrameIndex + 1) % frozenFramesSize;
    }
    
    previousFrameTimestamp = lastFrameTimestamp;
}

-(void)stop {
    [self.displayLinkWrapper invalidate];
}

-(NSInteger)slowFrames:(NSDate *) startTimestamp end:(NSDate *)endTimestamp {
    NSInteger slowFramesCount = 0;
    for (int i = 0; i < slowFramesSize; i ++) {
        CFAbsoluteTime time = slowFrames[i];
        if( time >= startTimestamp.timeIntervalSince1970 && time <= endTimestamp.timeIntervalSince1970) {
            slowFramesCount++;
        }
    }
    
    return slowFramesCount;
}

-(NSInteger)frozenFrames:(NSDate *) startTimestamp end:(NSDate *)endTimestamp {
    return 0;
}

@end
