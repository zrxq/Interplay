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

@interface TJGLink (Callbacks)
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
    ABLLinkRef _linkRef;
    UIViewController *_settings;
}

- (instancetype)init {
    if (self = [super init]) {
        _linkRef = ABLLinkNew(TJGDefaultTempo);
        [self setupCallbacks];
    }
    return self;
}

- (void)dealloc {
    ABLLinkDelete(_linkRef);
}

#pragma mark - Public

- (void)activate {
    ABLLinkSetActive(_linkRef, true);
}

- (void)deactivate {
    ABLLinkSetActive(_linkRef, false);
}

- (BOOL)isEnabled {
    return ABLLinkIsEnabled(_linkRef);
}

- (UIViewController *)settings {
    if (!_settings) {
        ABLLinkSettingsViewController *linkSettingsController =  [ABLLinkSettingsViewController instance:_linkRef];
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
    ABLLinkSetSessionTempoCallback(_linkRef, &sessionTempoCallback, (__bridge void *)(self));
    ABLLinkSetIsConnectedCallback(_linkRef, &isConnectedCallback, (__bridge void *)(self));
}

- (void)onTempoChange:(double)tempo {
    [[NSNotificationCenter defaultCenter] postNotificationName:TJGLinkTempoDidChangeNotification object:self userInfo:@{ TJGTempoUserInfoKey: @(tempo), }];
}

- (void)onIsConnected:(BOOL)isConnected {
    [[NSNotificationCenter defaultCenter] postNotificationName:TJGLinkConnectionDidChangeNotification object:self userInfo:@{  TJGIsConnectedUserInfoKey: @(isConnected), }];
}

@end
