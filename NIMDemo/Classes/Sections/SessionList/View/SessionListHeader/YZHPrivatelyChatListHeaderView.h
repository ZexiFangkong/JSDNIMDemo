//
//  YZHPrivatelyChatListHeaderView.h
//  NIM
//
//  Created by Jersey on 2018/10/17.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    YZHListHeaderStatusTypeDefault = 0,
    YZHListHeaderStatusTypeShow = 1,
    YZHListHeaderStatusTypeClose = 2,
} YZHListHeaderStatusType;

@interface YZHPrivatelyChatListHeaderView : UIView

@property (nonatomic, strong) UIImageView* guideImageView;
@property (nonatomic, strong) UILabel* tagNameLabel;
@property (nonatomic, strong) UILabel* unReadCountLabel;
@property (nonatomic, strong) UIButton* groupButton;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, copy) void(^callBlock)(NSInteger currentSection);
@property (nonatomic, assign) YZHListHeaderStatusType currentStatusType;

- (void)refreshStatus;
- (void)refresh:(NIMRecentSession*)recent;

@end

NS_ASSUME_NONNULL_END
