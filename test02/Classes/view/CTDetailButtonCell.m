//
//  CTDetailButtonCell.m
//  AppBasic
//
//  Created by zsh on 2020/4/10.
//  Copyright © 2020 rain. All rights reserved.
//

#import "CTDetailButtonCell.h"
#import "Masonry.h"
@implementation CTDetailButtonCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.detailBtn addTarget:self action:@selector(detailBtnClick) forControlEvents:UIControlEventTouchUpInside];
//        self.detailBtn.backgroundColor = [UIColor redColor];
        [self.detailBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.detailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.contentView addSubview:self.detailBtn];
        
        [self.detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.left.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}
-(void)setCellDataSysScreen:(NSString *)dataName indexPath:(NSIndexPath *)indexPath{
    [self.detailBtn setTitle:dataName forState:UIControlStateNormal];
    if (indexPath.section == 1){
        self.textLabel.text = @"系统选择";
    }else if (indexPath.section == 2){
        self.textLabel.text = @"大屏选择";
    }else{
        self.textLabel.text = @"";
    }
}

-(void)detailBtnClick{
    if (self.cellBtnBlock != nil) {
        self.cellBtnBlock(@"1");
    }
}

@end
