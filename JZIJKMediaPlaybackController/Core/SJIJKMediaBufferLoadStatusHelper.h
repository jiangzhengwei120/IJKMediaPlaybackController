//
//  SJIJKMediaBufferLoadStatusHelper.h
//  Test
//
//  Created by BlueDancer on 2018/8/13.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<SJBaseVideoPlayer/SJMediaPlaybackProtocol.h>)
#import <SJBaseVideoPlayer/SJPlayerBufferStatus.h>
#else
#import "SJPlayerBufferStatus.h"
#endif
@class IJKFFMoviePlayerController;

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKMediaBufferLoadStatusHelper : NSObject
@property (nonatomic, readonly) SJPlayerBufferStatus bufferLoadStatus;

- (void)                  observe:(IJKFFMoviePlayerController *)player
bufferLoadStatusDidChangeExeBlock:(void(^)(SJIJKMediaBufferLoadStatusHelper *helper))bufferLoadStatusDidChangeExeBlock;

- (void)clean;
@end
NS_ASSUME_NONNULL_END
