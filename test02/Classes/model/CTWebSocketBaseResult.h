//
//  CTWebSocketBaseResult.h
//  AppBasic
//
//  Created by zsh on 2020/4/8.
//  Copyright © 2020 rain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTWebSocketBaseResult : NSObject
@property (nonatomic, strong) NSString * msgId;
@property (nonatomic, assign) NSInteger  type;
@property (nonatomic, assign) NSInteger  sendRole;//0主动，1回执
@property (nonatomic, assign) NSInteger  result;//0失败，1成功
@property (nonatomic, strong) NSString * data;
@end

NS_ASSUME_NONNULL_END
