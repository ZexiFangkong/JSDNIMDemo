//
//  YZHPrivatelyChatListHeaderView.m
//  NIM
//
//  Created by Jersey on 2018/10/17.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YZHPrivatelyChatListHeaderView.h"

#import "UIView+NIM.h"
@implementation YZHPrivatelyChatListHeaderView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _tagNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagNameLabel.font = [UIFont systemFontOfSize:13];
        _tagNameLabel.textColor = [UIColor colorWithRed:142/255.0 green:142/255.0 blue:142/255.0 alpha:1];
        [self addSubview:_tagNameLabel];
        
        _unReadCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _unReadCountLabel.font = [UIFont systemFontOfSize:13];
        _unReadCountLabel.textColor = [UIColor colorWithRed:142/255.0 green:142/255.0 blue:142/255.0 alpha:1];
        [self addSubview:_unReadCountLabel];
        
        _guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:_guideImageView];
        
        _groupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 40)];
        [_groupButton addTarget:self action:@selector(executeSelected:) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:_groupButton];
        
    }
    return self;
}

- (void)executeSelected:(UIButton* )sender {
    
    self.callBlock ? self.callBlock(_section) : NULL;
}

- (void)refresh:(NIMRecentSession*)recent {
    
//    self.tagNameLabel.nim_width = 30;
//    self.tagNameLabel.nim_height = 11;
//    self.unReadCountLabel.nim_width = 10;
//    self.unReadCountLabel.nim_height = 11;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    //Session List
//    NSInteger sessionListAvatarLeft             = 12;
//    NSInteger sessionListNameTop                = 15;
//    NSInteger sessionListNameLeftToAvatar       = 15;
//    NSInteger sessionListMessageLeftToAvatar    = 15;
//    NSInteger sessionListMessageBottom          = 15;
//    NSInteger sessionListTimeRight              = 15;
//    NSInteger sessionListTimeTop                = 15;
//    NSInteger sessionBadgeTimeBottom            = 15;
//    NSInteger sessionBadgeTimeRight             = 15;
    /*
    _avatarImageView.nim_left    = sessionListAvatarLeft;
    _avatarImageView.nim_centerY = self.nim_height * .5f;
    _nameLabel.nim_top           = sessionListNameTop;
    _nameLabel.nim_left          = _avatarImageView.nim_right + sessionListNameLeftToAvatar;
    _messageLabel.nim_left       = _avatarImageView.nim_right + sessionListMessageLeftToAvatar;
    _messageLabel.nim_bottom     = self.nim_height - sessionListMessageBottom;
    _timeLabel.nim_right         = self.nim_width - sessionListTimeRight;
    _timeLabel.nim_top           = sessionListTimeTop;
    _badgeView.nim_right         = self.nim_width - sessionBadgeTimeRight;
    _badgeView.nim_bottom        = self.nim_height - sessionBadgeTimeBottom;
     */
    _tagNameLabel.nim_left = 12;
    _tagNameLabel.nim_centerY = self.nim_height * .5f;
    
    _unReadCountLabel.nim_left = self.tagNameLabel.nim_right + 5;
    _unReadCountLabel.nim_centerY = self.nim_height * .5f;
    
    _guideImageView.nim_right = self.nim_width - 26;
    _guideImageView.nim_centerY = self.nim_height * .5f;
}

- (void)refreshStatus {
    
    NSLog(@"刷新了嘛");
}


@end
