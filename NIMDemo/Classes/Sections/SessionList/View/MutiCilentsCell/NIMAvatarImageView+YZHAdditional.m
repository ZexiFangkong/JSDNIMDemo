//
//  NIMAvatarImageView+YZHAdditional.m
//  NIM
//
//  Created by Jersey on 2018/10/16.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "NIMAvatarImageView+YZHAdditional.h"

#import <NIMKitInfoFetchOption.h>
#import "UIView+NIM.h"

@implementation NIMAvatarImageView (YZHAdditional)
/*

- (void)setAvatarBySession:(NIMSession *)session
{
    NIMKitInfo *info = nil;
    if (session.sessionType == NIMSessionTypeTeam)
    {
        info = [[NIMKit sharedKit] infoByTeam:session.sessionId option:nil];
    }
    else
    {
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = session;
        info = [[NIMKit sharedKit] infoByUser:session.sessionId option:option];
    }
    NSURL *url = info.avatarUrlString ? [NSURL URLWithString:info.avatarUrlString] : nil;
    [self nim_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"addBook_cover_cell_photo_default"]];
    NSLog(@"实现了分类的");
}

- (void)setupRadius
{
    switch ([NIMKit sharedKit].config.avatarType)
    {
        case NIMKitAvatarTypeNone:
            self.cornerRadius = 0;
            break;
        case NIMKitAvatarTypeRounded:
            self.cornerRadius = self.nim_width *.5f;
            break;
        case NIMKitAvatarTypeRadiusCorner:
            self.cornerRadius = 6.f;
            break;
        default:
            break;
    }
}
*/
- (void)setupRadius
{
    switch ([NIMKit sharedKit].config.avatarType)
    {
        case NIMKitAvatarTypeNone:
            self.cornerRadius = 0;
            break;
        case NIMKitAvatarTypeRounded:
            self.cornerRadius = self.nim_width *.5f;
            break;
        case NIMKitAvatarTypeRadiusCorner:
            self.cornerRadius = 3.f;
            break;
        default:
            break;
    }
}

@end
