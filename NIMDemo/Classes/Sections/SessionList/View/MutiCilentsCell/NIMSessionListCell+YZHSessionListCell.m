//
//  NIMSessionListCell+YZHSessionListCell.m
//  NIM
//
//  Created by Jersey on 2018/10/16.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "NIMSessionListCell+YZHSessionListCell.h"
#import "NIMAvatarImageView.h"
#import "UIView+NIM.h"
#import "NIMKitUtil.h"
#import "NIMBadgeView.h"

#import <objc/runtime.h>
@implementation NIMSessionListCell (YZHSessionListCell)

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.avatarImageView = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [self addSubview:self.avatarImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.backgroundColor = [UIColor whiteColor];
        self.nameLabel.font            = [UIFont systemFontOfSize:14.f];
        [self addSubview:self.nameLabel];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.messageLabel.backgroundColor = [UIColor whiteColor];
        self.messageLabel.font            = [UIFont systemFontOfSize:12.f];
        self.messageLabel.textColor       = [UIColor lightGrayColor];
        [self addSubview:self.messageLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.backgroundColor = [UIColor whiteColor];
        self.timeLabel.font            = [UIFont systemFontOfSize:11.f];
        self.timeLabel.textColor       = [UIColor grayColor];
        [self addSubview:self.timeLabel];
        
        self.badgeView = [NIMBadgeView viewWithBadgeTip:@"10"];
        [self addSubview:self.badgeView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //Session List
    NSInteger sessionListAvatarLeft             = 15;
    NSInteger sessionListNameTop                = 12;
    NSInteger sessionListNameLeftToAvatar       = 7;
    NSInteger sessionListMessageLeftToAvatar    = 7;
    NSInteger sessionListMessageBottom          = 12;
    NSInteger sessionListTimeRight              = 20;
    NSInteger sessionListTimeTop                = 12;
    NSInteger sessionBadgeTimeBottom            = 12;
    NSInteger sessionBadgeTimeRight             = 20;
    
    self.avatarImageView.nim_left    = sessionListAvatarLeft;
    self.avatarImageView.nim_centerY = self.nim_height * .5f;
    self.nameLabel.nim_top           = sessionListNameTop;
    self.nameLabel.nim_left          = self.avatarImageView.nim_right + sessionListNameLeftToAvatar;
    self.messageLabel.nim_left       = self.avatarImageView.nim_right + sessionListMessageLeftToAvatar;
    self.messageLabel.nim_bottom     = self.nim_height - sessionListMessageBottom;
    self.timeLabel.nim_right         = self.nim_width - sessionListTimeRight;
    self.timeLabel.nim_top           = sessionListTimeTop;
    self.badgeView.nim_right         = self.nim_width - sessionBadgeTimeRight;
    self.badgeView.nim_bottom        = self.nim_height - sessionBadgeTimeBottom;
}

@end
