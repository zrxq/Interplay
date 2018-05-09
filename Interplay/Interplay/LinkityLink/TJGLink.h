//
//  TJGLink.h
//  Interplay
//
//  Created by Zoreslav Khimich on 3/16/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

@import Foundation;

#import "TGJLinkTimeline.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TGJLinkTimelineCaptureThread) {
    TGJLinkTimelineCaptureThreadMain,
    TGJLinkTimelineCaptureThreadAudio,
};

extern NSString *const TJGLinkTempoDidChangeNotification;
extern NSString *const TJGLinkConnectionDidChangeNotification;

extern NSString *const TJGTempoUserInfoKey;
extern NSString *const TJGIsConnectedUserInfoKey;

extern const double TJGDefaultTempo;

@class UIViewController;

NS_SWIFT_NAME(Link)
@interface TJGLink : NSObject

- (void)activate;
- (void)deactivate;

- (void)captureTimelineFromThread:(TGJLinkTimelineCaptureThread)thread completion:(void (^)(TGJLinkTimeline *))handler;

@property (readonly) BOOL isEnabled;
@property (readonly) UIViewController *settings;

@end

NS_ASSUME_NONNULL_END
