//
//  SJIJKMediaSeekToTimeHelper.m
//  Test
//
//  Created by BlueDancer on 2018/8/13.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJIJKMediaSeekToTimeHelper.h"
#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)
#import <IJKMediaFramework/IJKMediaFramework.h>
#else
#import "IJKMediaFramework.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@implementation SJIJKMediaSeekToTimeHelper {
    void(^_completionHandler)(BOOL);
    BOOL _isSeeking;
}
- (void)    player:(__weak IJKFFMoviePlayerController *)player
        seekToTime:(NSTimeInterval)secs
 completionHandler:(nullable void(^)(BOOL finished))completionHandler {
    [self clean];
    [self _observePlayerNotifies:player];
    if ( isnan(secs) ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( !player ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( secs > player.duration || secs < 0 ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( floor(player.currentPlaybackTime) == floor(secs) ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( !player.isPreparedToPlay ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    player.currentPlaybackTime = secs;
    _completionHandler = completionHandler;
    _isSeeking = YES;
}
- (void)_observePlayerNotifies:(IJKFFMoviePlayerController *)player {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidSeekCompleteNotify:)
                                                 name:IJKMPMoviePlayerDidSeekCompleteNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLoadStateDidChangeNotify:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateDidChangeNotify:)
                                                 name:IJKMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
}
- (void)_removeNotifies { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)playerDidSeekCompleteNotify:(NSNotification *)notify {
    BOOL error = [notify.userInfo[IJKMPMoviePlayerDidSeekCompleteErrorKey] integerValue];
    if ( error ) {
        if ( _completionHandler ) _completionHandler(error);
        [self clean];
        return;
    }
    
    IJKFFMoviePlayerController *player = notify.object;
    if ( player.loadState == (IJKMPMovieLoadStatePlayable | IJKMPMovieLoadStatePlaythroughOK) ) {
        if ( _completionHandler ) _completionHandler(YES);
        [self clean];
    }
}
- (void)playerLoadStateDidChangeNotify:(NSNotification *)notify {
    if ( _isSeeking ) {
        IJKFFMoviePlayerController *player = notify.object;
        if ( player.loadState == (IJKMPMovieLoadStatePlayable | IJKMPMovieLoadStatePlaythroughOK) ) {
            if ( self->_completionHandler ) self->_completionHandler(YES);
            [self clean];
        }
    }
}
- (void)playbackStateDidChangeNotify:(NSNotification *)notify {
    IJKFFMoviePlayerController *player = notify.object;
    switch ( player.playbackState ) {
        case IJKMPMoviePlaybackStateStopped:
        case IJKMPMoviePlaybackStatePlaying:
        case IJKMPMoviePlaybackStatePaused:
        case IJKMPMoviePlaybackStateInterrupted: {
            [self clean];
        }
            break;
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: break;
    }
    if ( player.playbackState ==  IJKMPMoviePlaybackStatePlaying ) [self clean];
}
- (void)clean {
    _isSeeking = NO;
    [self _removeNotifies];
    _completionHandler = nil;
}
@end
NS_ASSUME_NONNULL_END
