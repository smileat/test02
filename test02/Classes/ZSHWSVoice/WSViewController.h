//
//  WSViewController.h
//  IntercomDemo
//
//  Created by zsh on 2020/3/26.
//  Copyright © 2020 zsh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"
#import "SocketRocket.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "MJExtension.h"
#import "ZJPickerView.h"
//#import "BDSSpeechSynthesizer.h"
#import "YSCVoiceWaveView.h"
#import "YSCVoiceLoadingCircleView.h"
//#import <CTUser.h>
//#import <CTCommon/CTCommon.h>
/**
 *  缓存区的个数，一般3个
 */
#define kNumberAudioQueueBuffers 3
/**
 *  采样率，要转码为amr的话必须为8000
 */
#define kDefaultSampleRate 8000

#define kDefaultInputBufferSize 7360
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)
# define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
# define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height
NS_ASSUME_NONNULL_BEGIN

@interface WSViewController : UIViewController
{
    AudioQueueRef                   _inputQueue;
    AudioStreamBasicDescription     _audioFormat;
    
    AudioQueueBufferRef     _inputBuffers[kNumberAudioQueueBuffers];
}
@property (strong, nonatomic) SRWebSocket      *socket;
@property (assign, nonatomic) AudioQueueRef    inputQueue;
@end

NS_ASSUME_NONNULL_END
