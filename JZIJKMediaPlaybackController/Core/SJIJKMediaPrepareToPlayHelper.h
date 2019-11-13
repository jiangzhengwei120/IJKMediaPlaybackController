//
//  SJIJKMediaPrepareToPlayHelper.h
//  Test
//
//  Created by BlueDancer on 2018/8/13.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<SJBaseVideoPlayer/SJMediaPlaybackProtocol.h>)
#import <SJBaseVideoPlayer/SJMediaPlaybackProtocol.h>
#else
#import "SJMediaPlaybackProtocol.h"
#endif

@class IJKFFMoviePlayerController;

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKMediaPrepareToPlayHelper : NSObject
@property (nonatomic, readonly) SJMediaPlaybackPrepareStatus prepareStatus;
@property (nonatomic, strong, readonly, nullable) NSError *error;

- (void)                     observe:(IJKFFMoviePlayerController *)player
prepareToPlayStatusDidChangeExeBlock:(void(^)(SJIJKMediaPrepareToPlayHelper *helper))prepareToPlayStatusDidChangeExeBlock;

- (void)clean;
@end
NS_ASSUME_NONNULL_END
