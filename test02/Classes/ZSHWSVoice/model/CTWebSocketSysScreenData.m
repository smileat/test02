//
//  CTWebSocketSysScreenData.m
//  AppBasic
//
//  Created by zsh on 2020/4/8.
//  Copyright © 2020 rain. All rights reserved.
//

#import "CTWebSocketSysScreenData.h"

@implementation CTWebSocketSysScreenData
+(NSDictionary *)mj_objectClassInArray{
    return @{@"clientInfoList" : @"CTWebSocketClientData"};
}
@end

@implementation CTWebSocketClientData

@end

@implementation CTWebSocketDeviceClientStatusData
+(NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"idField":@"id"};
}
@end
