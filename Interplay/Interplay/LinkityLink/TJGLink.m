//
//  TJGLink.m
//  Interplay
//
//  Created by Zoreslav Khimich on 3/16/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

#import "TJGLink.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import "ABLLink.h"
#import "ABLLinkSettingsViewController.h"
#pragma clang diagnostic pop

#pragma mark - Constants

NSString *const TJGLinkTempoDidChangeNotification = @"TJGLinkTempoDidChangeNotification";
NSString *const TJGLinkConnectionDidChangeNotification = @"TJGLinkConnectionDidChangeNotification";
NSString *const TJGTempoUserInfoKey = @"tempo";
NSString *const TJGIsConnectedUserInfoKey = @"isConnected";

const double TJGDefaultTempo = 120.;

#pragma mark - Private parts

@interface TJGLink ()

@property (readonly, assign, nonatomic) ABLLinkRef linkRef;

- (void)onTempoChange:(double)tempo;
- (void)onIsConnected:(BOOL)isConnected;

@end

#pragma mark - C callbacks

static void sessionTempoCallback(double tempo, void *context) {
    TJGLink *link = (__bridge TJGLink *)(context);
    [link onTempoChange:tempo];
}

static void isConnectedCallback(bool isConnected, void *context) {
    TJGLink *link = (__bridge TJGLink *)(context);
    [link onIsConnected:isConnected];
}

#pragma mark -

@implementation TJGLink {
    UIViewController *_settings;
}

@synthesize linkRef = _linkRef;

- (instancetype)init {
    if (self = [super init]) {
        _linkRef = ABLLinkNew(TJGDefaultTempo);
        [self setupCallbacks];
    }
    return self;
}

- (void)dealloc {
    ABLLinkDelete(self.linkRef);
}

#pragma mark - Public

- (void)activate {
    ABLLinkSetActive(self.linkRef, true);
}

- (void)deactivate {
    ABLLinkSetActive(self.linkRef, false);
}

- (BOOL)isEnabled {
    return ABLLinkIsEnabled(self.linkRef);
}

- (void)captureTimelineFromThread:(TGJLinkTimelineCaptureThread)thread completion:(void (^)(TGJLinkTimeline *))handler {
    ABLLinkSessionStateRef stateRef;
    switch (thread) {
        case TGJLinkTimelineCaptureThreadAudio:
            stateRef = ABLLinkCaptureAudioSessionState(self.linkRef);
            break;
            
        case TGJLinkTimelineCaptureThreadMain:
            stateRef = ABLLinkCaptureAppSessionState(self.linkRef);
    }
    handler([[TGJLinkTimeline alloc] initWithLinkSessionState:stateRef]);
}

- (UIViewController *)settings {
    if (!_settings) {
        ABLLinkSettingsViewController *linkSettingsController =  [ABLLinkSettingsViewController instance:self.linkRef];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:linkSettingsController];
        
        UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings:)];
        navigationController.topViewController.navigationItem.rightBarButtonItem = dismissButton;
        
        _settings = navigationController;
    }
    return _settings;
}

#pragma mark - Actions

- (void)dismissSettings:(id)sender {
    [self.settings dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Callbacks

- (void)setupCallbacks {
    ABLLinkSetSessionTempoCallback(self.linkRef, &sessionTempoCallback, (__bridge void *)(self));
    ABLLinkSetIsConnectedCallback(self.linkRef, &isConnectedCallback, (__bridge void *)(self));
}

- (void)onTempoChange:(double)tempo {
    [[NSNotificationCenter defaultCenter] postNotificationName:TJGLinkTempoDidChangeNotification object:self userInfo:@{ TJGTempoUserInfoKey: @(tempo), }];
}

- (void)onIsConnected:(BOOL)isConnected {
    [[NSNotificationCenter defaultCenter] postNotificationName:TJGLinkConnectionDidChangeNotification object:self userInfo:@{  TJGIsConnectedUserInfoKey: @(isConnected), }];
}

@end
