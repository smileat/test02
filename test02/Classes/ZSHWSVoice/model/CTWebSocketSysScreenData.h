//
//  CTWebSocketSysScreenData.h
//  AppBasic
//
//  Created by zsh on 2020/4/8.
//  Copyright © 2020 rain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CTWebSocketClientData,CTWebSocketDeviceClientStatusData;
@interface CTWebSocketSysScreenData : NSObject
@property (nonatomic, strong) NSString * sysId;
@property (nonatomic, strong) NSString * sysName;

@property (nonatomic, strong) NSString * creator;
@property (nonatomic, assign) long       createDate;
@property (nonatomic, strong) NSString * updater;
@property (nonatomic, assign) long       updateDate;

@property (nonatomic, strong) NSArray<CTWebSocketClientData *> *clientInfoList;
@end

@interface CTWebSocketClientData : NSObject
@property (nonatomic, strong) NSString * clientId;
@property (nonatomic, strong) NSString * clientName;
@property (nonatomic, strong) NSString * sysId;
@property (nonatomic, strong) NSString * sysName;
@property (nonatomic, strong) NSString * area;

@property (nonatomic, strong) NSString * creator;
@property (nonatomic, assign) long       createDate;
@property (nonatomic, strong) NSString * updater;
@property (nonatomic, assign) long       updateDate;

@property (nonatomic, strong) CTWebSocketDeviceClientStatusData * deviceClientStatus;
@end

@interface CTWebSocketDeviceClientStatusData : NSObject
@property (nonatomic, strong) NSString * idField;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * deviceId;
@property (nonatomic, strong) NSString * deviceName;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger status;//0离线，1在线
@property (nonatomic, strong) NSString * devCltIp;
@property (nonatomic, strong) NSString * serverIp;
@property (nonatomic, assign) long connTime;

@property (nonatomic, strong) NSString * creator;
@property (nonatomic, assign) long       createDate;
@property (nonatomic, strong) NSString * updater;
@property (nonatomic, assign) long       updateDate;
@end
NS_ASSUME_NONNULL_END
