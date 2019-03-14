//
//  TJGLink.h
//  Interplay
//
//  Created by Zoreslav Khimich on 3/16/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

@import Foundation;

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

+ (instancetype)shared;

- (void)activate;
- (void)deactivate;

- (double)beatAtHostTime:(uint64_t)hostTimeAtOutput quantum:(double)quantum;

@property (readonly) BOOL isEnabled;
@property (readonly) UIViewController *settings;

@end

NS_ASSUME_NONNULL_END
