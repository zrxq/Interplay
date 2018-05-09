//
//  TGJLinkTimeline.h
//  Interplay
//
//  Created by Zoreslav Khimich on 5/9/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

#import <Foundation/Foundation.h>

struct ABLLinkSessionState;

NS_ASSUME_NONNULL_BEGIN

@interface TGJLinkTimeline : NSObject

- (instancetype)initWithLinkSessionState:(struct ABLLinkSessionState *)sessionState;

- (uint64_t)hostTimeAtBeat:(double)beatTime quantum:(double)quantum;

@end

NS_ASSUME_NONNULL_END
