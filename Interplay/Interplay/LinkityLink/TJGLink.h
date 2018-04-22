//
//  TJGLink.h
//  Interplay
//
//  Created by Zoreslav Khimich on 3/16/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

@import Foundation;

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

@property (readonly) BOOL isEnabled;
@property (readonly) UIViewController *settings;

@end
