//
//  CTDetailSwitchCell.h
//  AppBasic
//
//  Created by zsh on 2020/4/10.
//  Copyright © 2020 rain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlockDefines.h"
NS_ASSUME_NONNULL_BEGIN

@interface CTDetailSwitchCell : UITableViewCell
@property (nonatomic,strong) UISwitch *detailSwitch;
@property (nonatomic,copy) NormalBlockObj cellSwitchBlock;
-(void)setCellDataScreenSwitch:(NSString *)controlStr;
@end

NS_ASSUME_NONNULL_END
