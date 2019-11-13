//
//  SJIJKMediaPlaybackController.m
//  Test
//
//  Created by 畅三江 on 2018/8/12.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJIJKMediaPlaybackController.h"
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

#import "SJIJKMediaSeekToTimeHelper.h"
#import "SJIJKMediaPlayTimeHelper.h"
#import "SJIJKMediaPrepareToPlayHelper.h"
#import "SJIJKMediaBufferLoadStatusHelper.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKFFPlayerLayerPresentView: UIView
@end
@implementation SJIJKFFPlayerLayerPresentView
@end

@interface SJIJKMediaPlaybackController()
@property (nonatomic, strong, nullable) IJKFFMoviePlayerController *player;
@property (nonatomic, strong, readonly) SJIJKMediaPlayTimeHelper *refreshTimeHelper;
@property (nonatomic, strong, readonly) SJIJKMediaSeekToTimeHelper *seekToTimeHelper;
@property (nonatomic, strong, readonly) SJIJKMediaPrepareToPlayHelper *prepareToPlayHelper;
@property (nonatomic, strong, readonly) SJIJKMediaBufferLoadStatusHelper *bufferLoadStateHelper;
@end

@implementation SJIJKMediaPlaybackController
@synthesize delegate = _delegate;
@synthesize media = _media;
@synthesize mute = _mute;
@synthesize pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
@synthesize playerView = _playerView;
@synthesize rate = _rate;
@synthesize videoGravity = _videoGravity;
/// helpers
@synthesize seekToTimeHelper = _seekToTimeHelper;
@synthesize refreshTimeHelper = _refreshTimeHelper;
@synthesize prepareToPlayHelper = _prepareToPlayHelper;
@synthesize bufferLoadStateHelper = _bufferLoadStateHelper;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    _rate = 1;
    _videoGravity = AVLayerVideoGravityResizeAspect;
    return self;
}
- (UIView *)playerView {
    if ( _playerView ) return _playerView;
    return _playerView = [SJIJKFFPlayerLayerPresentView new];
}
- (CGSize)presentationSize {
    if ( !_player.isPreparedToPlay ) return CGSizeZero;
    return CGSizeMake(_player.monitor.width, _player.monitor.height);
}
- (NSTimeInterval)currentTime {
    return self.refreshTimeHelper.currentTime;
}
- (NSTimeInterval)duration {
    return self.refreshTimeHelper.duration;
}
- (NSTimeInterval)bufferLoadedTime {
    return self.refreshTimeHelper.bufferTime;
}
- (SJIJKMediaPlayTimeHelper *)refreshTimeHelper {
    if ( _refreshTimeHelper ) return _refreshTimeHelper;
    return _refreshTimeHelper = [SJIJKMediaPlayTimeHelper new];
}
- (void)setPauseWhenAppDidEnterBackground:(BOOL)pauseWhenAppDidEnterBackground {
    _pauseWhenAppDidEnterBackground = pauseWhenAppDidEnterBackground;
    [_player setPauseInBackground:pauseWhenAppDidEnterBackground];
}
- (void)setMedia:(nullable id<SJMediaModelProtocol>)media {
    [self.prepareToPlayHelper clean];
    [self.refreshTimeHelper clean];
    [self.seekToTimeHelper clean];
    [self.bufferLoadStateHelper clean];
    [self stop];
    _media = media;
}
- (void)setMute:(BOOL)mute {
    _mute = mute;
    _player.playbackVolume = _mute?0:1;
}
- (void)setRate:(float)rate {
    _rate = rate;
    _player.playbackRate = rate;
}
- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    _videoGravity = videoGravity;
    [self _updateScalingMode];
}
- (void)_updateScalingMode {
    if ( _videoGravity == AVLayerVideoGravityResizeAspect ) _player.scalingMode = IJKMPMovieScalingModeAspectFit;
    else if ( _videoGravity == AVLayerVideoGravityResizeAspectFill ) _player.scalingMode = IJKMPMovieScalingModeAspectFill;
    else _player.scalingMode = IJKMPMovieScalingModeFill;
}
- (SJPlayerBufferStatus)bufferStatus {
    return self.bufferLoadStateHelper.bufferLoadStatus;
}
- (SJIJKMediaBufferLoadStatusHelper *)bufferLoadStateHelper {
    if ( _bufferLoadStateHelper ) return _bufferLoadStateHelper;
    return _bufferLoadStateHelper = [SJIJKMediaBufferLoadStatusHelper new];
}
- (SJMediaPlaybackPrepareStatus)prepareStatus {
    return self.prepareToPlayHelper.prepareStatus;
}
- (nullable NSError *)error {
    return self.prepareToPlayHelper.error;
}
- (void)prepareToPlay {
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [_player.view removeFromSuperview];
    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.media.mediaURL?:self.media.otherMedia.mediaURL withOptions:options];
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _player.view.frame = self.playerView.bounds;
    _player.shouldAutoplay = NO;
    [_player setPauseInBackground:_pauseWhenAppDidEnterBackground];
    _player.playbackVolume = _mute?0:1;
    [self _updateScalingMode];
    [self.playerView addSubview:_player.view];
    
    __weak typeof(self) _self = self;
    /// prepare status
    [self.prepareToPlayHelper observe:_player prepareToPlayStatusDidChangeExeBlock:^(SJIJKMediaPrepareToPlayHelper * _Nonnull helper) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        void(^inner_block)(void) = ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( helper.prepareStatus == SJMediaPlaybackPrepareStatusReadyToPlay ) {
                if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
                     [self.delegate playbackController:self presentationSizeDidChange:self.presentationSize];
                }
            }
            
            if ( [self.delegate respondsToSelector:@selector(playbackController:prepareToPlayStatusDidChange:)] ) {
                 [self.delegate playbackController:self prepareToPlayStatusDidChange:helper.prepareStatus];
            }
        };
        
        /// seek to specified time
        if ( helper.prepareStatus == SJVideoPlayerPlayStatusReadyToPlay && 0 != self.media.specifyStartTime ) {
            [self seekToTime:self.media.specifyStartTime completionHandler:^(BOOL finished) {
                inner_block();
            }];
            
            return;
        }
        
        inner_block();
    }];
    
    /// refresh time
    [self.refreshTimeHelper observe:_player currentTimeDidChangeExeBlock:^(SJIJKMediaPlayTimeHelper * _Nonnull helper) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:currentTimeDidChange:)] ) {
             [self.delegate playbackController:self currentTimeDidChange:helper.currentTime];
        }
    } bufferTimeDidChangeExeBlock:^(SJIJKMediaPlayTimeHelper * _Nonnull helper) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:bufferLoadedTimeDidChange:)] ) {
             [self.delegate playbackController:self bufferLoadedTimeDidChange:helper.bufferTime];
        }
    } durationDidChangeExeBlock:^(SJIJKMediaPlayTimeHelper * _Nonnull helper) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:durationDidChange:)] ) {
             [self.delegate playbackController:self durationDidChange:helper.duration];
        }
    }];
    
    /// buffer load status
    [self.bufferLoadStateHelper observe:_player bufferLoadStatusDidChangeExeBlock:^(SJIJKMediaBufferLoadStatusHelper * _Nonnull helper) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:bufferLoadedTimeDidChange:)] ) {
             [self.delegate playbackController:self bufferStatusDidChange:helper.bufferLoadStatus];
        }
    }];
    
    [_player prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerPlaybackDidFinishNotify:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
}

- (SJIJKMediaPrepareToPlayHelper *)prepareToPlayHelper {
    if ( _prepareToPlayHelper ) return _prepareToPlayHelper;
    return _prepareToPlayHelper = [SJIJKMediaPrepareToPlayHelper new];
}
- (void)playerPlaybackDidFinishNotify:(NSNotification *)notify {
    IJKMPMovieFinishReason reason = [notify.userInfo[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    switch ( reason ) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            if ( [self.delegate respondsToSelector:@selector(mediaDidPlayToEndForPlaybackController:)] ) {
                 [self.delegate mediaDidPlayToEndForPlaybackController:self];
            }
            break;
        case IJKMPMovieFinishReasonPlaybackError:
        case IJKMPMovieFinishReasonUserExited: { /* nothing */ } break;
    }
}

- (void)play {
    if ( !_player.isPreparedToPlay ) return;
    [_player play];
    _player.playbackRate = _rate;
#ifdef DEBUG
    printf("\n");
    printf("SJIJKMediaPlaybackController<%p>.rate == %lf\n", self, self.rate);
    printf("SJIJKMediaPlaybackController<%p>.mute == %s\n",  self, self.mute?"YES":"NO");
#endif
}
- (void)pause {
    [_player pause];
}
- (void)stop {
    [_player.view removeFromSuperview];
    [_player stop];
    _player = nil;
}
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    [self.seekToTimeHelper player:self.player seekToTime:secs completionHandler:completionHandler];
}
- (SJIJKMediaSeekToTimeHelper *)seekToTimeHelper {
    if ( _seekToTimeHelper ) return _seekToTimeHelper;
    return _seekToTimeHelper = [SJIJKMediaSeekToTimeHelper new];
}

- (nullable UIImage *)screenshot {
    if ( !_player.isPreparedToPlay ) return nil;
    return [_player thumbnailImageAtCurrentTime];
}

- (void)cancelPendingSeeks { /* nothing */ }
@end
NS_ASSUME_NONNULL_END
