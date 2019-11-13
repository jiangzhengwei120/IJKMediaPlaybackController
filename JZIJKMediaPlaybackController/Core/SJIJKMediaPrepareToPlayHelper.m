//
//  SJIJKMediaPrepareToPlayHelper.m
//  Test
//
//  Created by BlueDancer on 2018/8/13.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJIJKMediaPrepareToPlayHelper.h"
#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)
#import <IJKMediaFramework/IJKMediaFramework.h>
#else
#import "IJKMediaFramework.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@implementation SJIJKMediaPrepareToPlayHelper {
    void(^_prepareToPlayStatusDidChangeExeBlock)(SJIJKMediaPrepareToPlayHelper *helper);
}
- (void)                     observe:(IJKFFMoviePlayerController *)player
prepareToPlayStatusDidChangeExeBlock:(void(^)(SJIJKMediaPrepareToPlayHelper *helper))prepareToPlayStatusDidChangeExeBlock {
    [self clean];
    _prepareToPlayStatusDidChangeExeBlock = prepareToPlayStatusDidChangeExeBlock;
    [self _observePlayerNotifies:player];
}
- (void)_observePlayerNotifies:(IJKFFMoviePlayerController *)player {
    if ( !player ) return;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerPlaybackDidFinishNotify:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackIsPreparedToPlayDidChangeNotify:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];
}
- (void)_removeNotifies { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)playerPlaybackDidFinishNotify:(NSNotification *)notify {
    IJKMPMovieFinishReason reason = [notify.userInfo[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    switch ( reason ) {
        case IJKMPMovieFinishReasonPlaybackError: {
            _error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"msg":@"IJKMPMovieFinishReasonPlaybackError"}];
            _prepareStatus = SJMediaPlaybackPrepareStatusFailed;
            if ( _prepareToPlayStatusDidChangeExeBlock ) _prepareToPlayStatusDidChangeExeBlock(self);
        }
            break;
        case IJKMPMovieFinishReasonPlaybackEnded:
        case IJKMPMovieFinishReasonUserExited: { /* nothing */ } break;
    }
}
- (void)playbackIsPreparedToPlayDidChangeNotify:(NSNotification *)notify {
    IJKFFMoviePlayerController *player = notify.object;
    _prepareStatus = player.isPreparedToPlay?SJMediaPlaybackPrepareStatusReadyToPlay:SJMediaPlaybackPrepareStatusUnknown;
    if ( _prepareToPlayStatusDidChangeExeBlock ) _prepareToPlayStatusDidChangeExeBlock(self);
}
- (void)clean {
    _error = nil;
    _prepareToPlayStatusDidChangeExeBlock = nil;
    _prepareStatus = SJMediaPlaybackPrepareStatusUnknown;
    [self _removeNotifies];
}
@end
NS_ASSUME_NONNULL_END
