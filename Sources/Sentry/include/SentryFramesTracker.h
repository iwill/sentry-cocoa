#import "SentryDefines.h"

@class SentryOptions, SentryDisplayLinkWrapper;

NS_ASSUME_NONNULL_BEGIN

@interface SentryFramesTracker : NSObject
SENTRY_NO_INIT

- (instancetype)initWithOptions:(SentryOptions *)options displayLinkWrapper:(SentryDisplayLinkWrapper *)displayLinkWrapper;

-(NSInteger)slowFrames:(NSDate *) startTimestamp end:(NSDate *)endTimestamp;

-(NSInteger)frozenFrames:(NSDate *) startTimestamp end:(NSDate *)endTimestamp;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
