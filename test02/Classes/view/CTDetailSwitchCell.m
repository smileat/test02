//
//  CTDetailSwitchCell.m
//  AppBasic
//
//  Created by zsh on 2020/4/10.
//  Copyright © 2020 rain. All rights reserved.
//

#import "CTDetailSwitchCell.h"
#import "Masonry.h"
@implementation CTDetailSwitchCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.detailSwitch = [[UISwitch alloc] init];
        [self.detailSwitch addTarget:self action:@selector(detailSwitchClick) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.detailSwitch];
        [self.detailSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}
-(void)setCellDataScreenSwitch:(NSString *)controlStr{
    self.textLabel.text = @"连接状态";
    if ([controlStr isEqualToString:@"0"]) {
        self.detailSwitch.on = NO;
    }
    else{
        self.detailSwitch.on = YES;
    }
}
-(void)detailSwitchClick{
    if (self.cellSwitchBlock != nil) {
        self.cellSwitchBlock(self.detailSwitch);
    }
}

@end
