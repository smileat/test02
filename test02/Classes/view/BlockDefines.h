//
//  BlockDefines.h
//  XTrip
//
//  Created by loufq on 16/3/28.
//  Copyright © 2016年 xiafeitu. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^NormalBlockObj)(id obj);

typedef void(^CompleteBlockStr)(NSString * _Nullable str);

typedef void(^CompleteBlockTwoStr)(NSString *first,NSString *second);

typedef void(^funcBlockBlock)(NSInteger btnTag,NSInteger btnRow);

typedef void(^intClickBlock)(NSInteger index);
