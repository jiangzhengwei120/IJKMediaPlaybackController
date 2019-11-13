//
//  SJIJKMediaPlayTimeHelper.h
//  Test
//
//  Created by BlueDancer on 2018/8/13.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IJKFFMoviePlayerController;

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKMediaPlayTimeHelper : NSObject
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval bufferTime;

- (void)             observe:(__weak IJKFFMoviePlayerController *)player
currentTimeDidChangeExeBlock:(void(^)(SJIJKMediaPlayTimeHelper *helper))currentTimeDidChangeExeBlock
 bufferTimeDidChangeExeBlock:(void(^)(SJIJKMediaPlayTimeHelper *helper))bufferTimeDidChangeExeBlock
   durationDidChangeExeBlock:(void(^)(SJIJKMediaPlayTimeHelper *helper))durationDidChangeExeBlock;

- (void)clean;
@end
NS_ASSUME_NONNULL_END
