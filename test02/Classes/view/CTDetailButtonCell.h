//
//  CTDetailButtonCell.h
//  AppBasic
//
//  Created by zsh on 2020/4/10.
//  Copyright © 2020 rain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlockDefines.h"
NS_ASSUME_NONNULL_BEGIN

@interface CTDetailButtonCell : UITableViewCell
@property (nonatomic,strong) UIButton *detailBtn;
@property (nonatomic,copy) CompleteBlockStr cellBtnBlock;
-(void)setCellDataSysScreen:(NSString *)dataName indexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
