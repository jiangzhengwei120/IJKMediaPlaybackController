//
//  SJIJKMediaPlayTimeHelper.m
//  Test
//
//  Created by BlueDancer on 2018/8/13.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJIJKMediaPlayTimeHelper.h"
#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)
#import <IJKMediaFramework/IJKMediaFramework.h>
#else
#import "IJKMediaFramework.h"
#endif

#if __has_include(<SJBaseVideoPlayer/NSTimer+SJAssetAdd.h>)
#import <SJBaseVideoPlayer/NSTimer+SJAssetAdd.h>
#else
#import "NSTimer+SJAssetAdd.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKMediaPlayTimeHelper()
@property (nonatomic, strong, nullable) NSTimer *refreshCurrentTimeTimer;
@property (nonatomic, weak, nullable) IJKFFMoviePlayerController *player;
@end
@implementation SJIJKMediaPlayTimeHelper {
    void(^_currentTimeDidChangeExeBlock)(SJIJKMediaPlayTimeHelper *helper);
    void(^_bufferTimeDidChangeExeBlock)(SJIJKMediaPlayTimeHelper *helper);
    void(^_durationDidChangeExeBlock)(SJIJKMediaPlayTimeHelper *helper);
}
- (void)dealloc { [self _inactivateTimer]; }
- (void)             observe:(__weak IJKFFMoviePlayerController *)player
currentTimeDidChangeExeBlock:(void(^)(SJIJKMediaPlayTimeHelper *helper))currentTimeDidChangeExeBlock
 bufferTimeDidChangeExeBlock:(void(^)(SJIJKMediaPlayTimeHelper *helper))bufferTimeDidChangeExeBlock
   durationDidChangeExeBlock:(void(^)(SJIJKMediaPlayTimeHelper *helper))durationDidChangeExeBlock {
    [self clean];
    _currentTimeDidChangeExeBlock = currentTimeDidChangeExeBlock;
    _durationDidChangeExeBlock = durationDidChangeExeBlock;
    _bufferTimeDidChangeExeBlock = bufferTimeDidChangeExeBlock;
    self.player = player;
    if ( !player ) return;
    [self _observePlayerNotifies:player];
    [self _updateTimes];
}
- (void)_observePlayerNotifies:(IJKFFMoviePlayerController *)player {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackIsPreparedToPlayDidChangeNotify:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateDidChangeNotify:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidFinishNotify:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
}
- (void)_removeNotifies {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)playbackStateDidChangeNotify:(NSNotification *)notify {
    switch ( _player.playbackState ) {
        case IJKMPMoviePlaybackStatePlaying: {
            [self _activateTimer];
        }
            break;
        case IJKMPMoviePlaybackStateStopped:
        case IJKMPMoviePlaybackStatePaused:
        case IJKMPMoviePlaybackStateInterrupted:
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            [self _inactivateTimer];
        }
            break;
    }
}
- (void)playbackDidFinishNotify:(NSNotification *)notify {
    [self _inactivateTimer];
    IJKMPMovieFinishReason reason = [notify.userInfo[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    switch ( reason ) {
        case IJKMPMovieFinishReasonPlaybackEnded: {
            _currentTime = _duration;
            if ( _currentTimeDidChangeExeBlock ) _currentTimeDidChangeExeBlock(self);
        }
            break;
        case IJKMPMovieFinishReasonPlaybackError:
        case IJKMPMovieFinishReasonUserExited: { /* nothing */ }
            break;
    }
}
- (void)playbackIsPreparedToPlayDidChangeNotify:(NSNotification *)notify {
    [self _updateTimes];
}
- (void)_activateTimer {
    if ( _refreshCurrentTimeTimer ) return;
    __weak typeof(self) _self = self;
    _refreshCurrentTimeTimer = [NSTimer assetAdd_timerWithTimeInterval:0.5 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) {
            [timer invalidate];
            return ;
        }
        
        if ( !self.player ) {
            [self _inactivateTimer];
            return;
        }
        
        [self _updateTimes];
    } repeats:YES];
    
    [_refreshCurrentTimeTimer fire];
    [[NSRunLoop mainRunLoop] addTimer:_refreshCurrentTimeTimer forMode:NSRunLoopCommonModes];
}
- (void)_inactivateTimer {
    if ( !_refreshCurrentTimeTimer ) return;
    [_refreshCurrentTimeTimer invalidate];
    _refreshCurrentTimeTimer = nil;
}
- (void)_updateTimes {
    if ( !_player.isPreparedToPlay ) return;
    
    if ( _player.duration != _duration ) {
        _duration = _player.duration;
        if ( _durationDidChangeExeBlock ) _durationDidChangeExeBlock(self);
    }
    
    _currentTime = _player.currentPlaybackTime;
    if ( _currentTimeDidChangeExeBlock ) _currentTimeDidChangeExeBlock(self);
    
    if ( _bufferTime != _player.playableDuration ) {
        _bufferTime = _player.playableDuration;
        if ( _bufferTimeDidChangeExeBlock ) _bufferTimeDidChangeExeBlock(self);
    }
}
- (void)clean {
    [self _removeNotifies];
    [self _inactivateTimer];
    _player = nil;
    _currentTimeDidChangeExeBlock = nil;
    _durationDidChangeExeBlock = nil;
    _bufferTimeDidChangeExeBlock = nil;
}
@end
NS_ASSUME_NONNULL_END
