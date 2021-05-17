#import <Foundation/Foundation.h>
#import "SentryFramesTrackingIntegration.h"
#import "SentryFramesTracker.h"
#import "SentryDisplayLinkWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface
SentryFramesTrackingIntegration ()

@property (nonatomic, strong) SentryFramesTracker *tracker;

@end

@implementation SentryFramesTrackingIntegration

- (void)installWithOptions:(SentryOptions *)options
{
    self.tracker = [[SentryFramesTracker alloc] initWithOptions:options displayLinkWrapper:[[SentryDisplayLinkWrapper alloc] init]];
    [self.tracker start];
}

- (void)uninstall
{
    [self stop];
}

- (void)stop
{
    if (nil != self.tracker) {
        [self.tracker stop];
    }
}

@end

NS_ASSUME_NONNULL_END
