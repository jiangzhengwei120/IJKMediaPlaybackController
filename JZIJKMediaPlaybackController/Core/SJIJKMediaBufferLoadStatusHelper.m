//
//  SJIJKMediaBufferLoadStatusHelper.m
//  Test
//
//  Created by BlueDancer on 2018/8/13.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJIJKMediaBufferLoadStatusHelper.h"
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
@interface SJIJKMediaBufferLoadStatusHelper()
@property (nonatomic, strong, nullable) NSTimer *refreshBufferLoadStatusTimer;
@property (nonatomic, weak, nullable) IJKFFMoviePlayerController *player;
@end

@implementation SJIJKMediaBufferLoadStatusHelper {
    void(^_bufferLoadStatusDidChangeExeBlock)(SJIJKMediaBufferLoadStatusHelper *helper);
}

- (void)                  observe:(IJKFFMoviePlayerController *)player
bufferLoadStatusDidChangeExeBlock:(void(^)(SJIJKMediaBufferLoadStatusHelper *helper))bufferLoadStatusDidChangeExeBlock {
    [self clean];
    _player = player;
    _bufferLoadStatusDidChangeExeBlock = bufferLoadStatusDidChangeExeBlock;
    [self _observePlayerNotifies:player];
}
- (void)_observePlayerNotifies:(IJKFFMoviePlayerController *)player {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLoadStateDidChangeNotify:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
}
- (void)_removeNotifies { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)playerLoadStateDidChangeNotify:(NSNotification *)notify {
    IJKFFMoviePlayerController *player = notify.object;
    if ( player.loadState & IJKMPMovieLoadStateStalled ) {
        [self _activateTimer];
    }
}
- (void)_activateTimer {
    if ( _refreshBufferLoadStatusTimer ) return;
    __weak typeof(self) _self = self;
    _refreshBufferLoadStatusTimer = [NSTimer assetAdd_timerWithTimeInterval:.5 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) {
            [timer invalidate];
            return ;
        }
        
        if ( !self.player ) {
            [self _inactivateTimer];
            return;
        }
        
        [self _considerUpdateBufferLoadStatus];
    } repeats:YES];
    
    [_refreshBufferLoadStatusTimer fire];
    [[NSRunLoop mainRunLoop] addTimer:_refreshBufferLoadStatusTimer forMode:NSRunLoopCommonModes];
}
- (void)_inactivateTimer {
    [_refreshBufferLoadStatusTimer invalidate];
    _refreshBufferLoadStatusTimer = nil;
}
- (void)_considerUpdateBufferLoadStatus {
    IJKMPMovieLoadState ok = IJKMPMovieLoadStatePlayable | IJKMPMovieLoadStatePlaythroughOK;
    IJKMPMovieLoadState no = IJKMPMovieLoadStateStalled;
    
    SJPlayerBufferStatus status = SJPlayerBufferStatusUnknown;
    if ( _player.loadState == ok ) {
        status = SJPlayerBufferStatusFull;
        [self _inactivateTimer];
    }
    else if ( _player.loadState == no ) {
        status = SJPlayerBufferStatusEmpty;
    }
    
    if ( status != _bufferLoadStatus ) {
        _bufferLoadStatus = status;
        if ( _bufferLoadStatusDidChangeExeBlock ) _bufferLoadStatusDidChangeExeBlock(self);
    }
}
- (void)clean {
    _player = nil;
    _bufferLoadStatusDidChangeExeBlock = nil;
    _bufferLoadStatus = SJPlayerBufferStatusUnknown;
    [self _inactivateTimer];
    [self _removeNotifies];
}
@end
NS_ASSUME_NONNULL_END
