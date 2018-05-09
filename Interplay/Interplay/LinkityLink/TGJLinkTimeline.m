//
//  TGJLinkTimeline.m
//  Interplay
//
//  Created by Zoreslav Khimich on 5/9/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

#import "TGJLinkTimeline.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import "ABLLink.h"
#import "ABLLinkSettingsViewController.h"
#pragma clang diagnostic pop

@interface TGJLinkTimeline ()

@property (readonly, assign) ABLLinkSessionStateRef sessionState;

@end

@implementation TGJLinkTimeline

- (instancetype)initWithLinkSessionState:(ABLLinkSessionStateRef)sessionState {
    if (self = [super init]) {
        _sessionState = sessionState;
    }
    return self;
}

- (uint64_t)hostTimeAtBeat:(double)beatTime quantum:(double)quantum {
    return ABLLinkTimeAtBeat(self.sessionState, beatTime, quantum);
}


@end
