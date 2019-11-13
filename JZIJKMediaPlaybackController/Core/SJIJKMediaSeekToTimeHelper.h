//
//  SJIJKMediaSeekToTimeHelper.h
//  Test
//
//  Created by BlueDancer on 2018/8/13.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IJKFFMoviePlayerController;

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKMediaSeekToTimeHelper : NSObject
- (void)    player:(__weak IJKFFMoviePlayerController *)player
        seekToTime:(NSTimeInterval)secs
 completionHandler:(nullable void(^)(BOOL finished))completionHandler;

- (void)clean;
@end
NS_ASSUME_NONNULL_END
