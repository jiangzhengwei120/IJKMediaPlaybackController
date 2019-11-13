//
//  SJIJKMediaPlaybackController.h
//  Test
//
//  Created by 畅三江 on 2018/8/12.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<SJBaseVideoPlayer/SJMediaPlaybackProtocol.h>)
#import <SJBaseVideoPlayer/SJMediaPlaybackProtocol.h>
#else
#import "SJMediaPlaybackProtocol.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKMediaPlaybackController : NSObject<SJMediaPlaybackController>

@end
NS_ASSUME_NONNULL_END
