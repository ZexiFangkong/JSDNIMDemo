//
//  YZHRecentSessionExtManage.m
//  NIM
//
//  Created by Jersey on 2018/10/18.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YZHRecentSessionExtManage.h"
#import "NTESSessionUtil.h"

@implementation YZHRecentSeesionExtModel

@end

@implementation YZHRecentSessionExtManage

#pragma mark -- Sort

- (void)screeningTagSessionAllRecentSession:(NSMutableArray<NIMRecentSession *> *)allRecentSession {
    _tagsRecentSession = [self defaultTagsRecentSession];
    _currentSessionTags = [self defaultCurrentSessionTags];
    NSString *markTypeTopkey = [NTESSessionUtil keyForMarkType:NTESRecentSessionMarkTypeTop];
        //检查本地扩展字段,
    for (NSInteger i = 0; i < allRecentSession.count; i++) {
        NIMRecentSession* recentSession = allRecentSession[i];
        //不比较未分类,直接存到到最后
        NSInteger tagCount = self.tagsRecentSession.count;
        // BUG
        for (NSInteger y = 0; y < tagCount; y++) {
            //先检查是否包含置顶,如果包含则不需要考虑标签,之前假如到第一组
            if ([[recentSession.localExt objectForKey:markTypeTopkey] boolValue] == YES) {
                [self.tagsRecentSession.firstObject addObject:recentSession];
                break;
            } else {
                [self.tagsRecentSession.firstObject removeObject:recentSession];
            }
            NSString* tagName = self.defaultTags[y];
            NSString* sessionTagName = [self getSessionExtTagNameWithRecentSession:recentSession];
            BOOL isSessionTypeP2P = recentSession.session.sessionType == NIMSessionTypeP2P;
            // 查找到之后终止循环,防止重复添加。
            if ([tagName isEqualToString:sessionTagName] && isSessionTypeP2P) {
                
                [self.tagsRecentSession[y] addObject:recentSession];
                break;
            } else if(sessionTagName.length == 0 && isSessionTypeP2P) {
                [self.tagsRecentSession.lastObject addObject:recentSession];
                break;
            }
        }
    }
    // 去掉不包含回话的空标签数组.
    for (NSInteger i = 0; i < self.tagsRecentSession.count; ) {
        if (self.tagsRecentSession[i].count == 0) {
            [self.tagsRecentSession removeObjectAtIndex:i];
        } else {
            i++;
        }
    }
}

- (void)sortTagRecentSession {
    
    NSMutableArray* recentSessionArray;
    for (NSInteger i = 0; i < self.tagsRecentSession.count; i++) {
        //将每个标签包含的会话取出进行排序.
        recentSessionArray = self.tagsRecentSession[i];
        [recentSessionArray sortUsingComparator:^NSComparisonResult(NIMRecentSession *obj1, NIMRecentSession *obj2) {
            //每个标签内只比较最后一条消息时间
            if (obj1.lastMessage.timestamp > obj2.lastMessage.timestamp) {
                
                return NSOrderedAscending;
            } else if (obj1.lastMessage.timestamp < obj2.lastMessage.timestamp) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
    };
}

#pragma mark -- updateRecentSession

- (void)checkSessionUserTagWithRecentSession:(NIMRecentSession* )recentSession {
    if (recentSession.session.sessionType == NIMSessionTypeP2P) {
        NIMUser* user = [[NIMSDK sharedSDK].userManager userInfo:recentSession.session.sessionId];
        NSString* userExt = user.ext;
        NSData* jsonData = [userExt dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        if (dic[@"tagName"]) {
            NSDictionary* locExt = @{
                                     @"tagName":dic[@"tagName"]
                                     };
            [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:locExt recentSession:recentSession];
        }
    }
    
}

#pragma SET & GET

- (NSMutableArray<NSMutableArray<NIMRecentSession *> *> *)defaultTagsRecentSession {
    
    _tagsRecentSession = [[NSMutableArray alloc] initWithCapacity:self.defaultTags.count];
    for (NSInteger i = 0; i < self.defaultTags.count; i++) {
        NSMutableArray<NIMRecentSession* >*  recentSessionArray = [[NSMutableArray alloc] init];
        [_tagsRecentSession addObject:recentSessionArray];
    }
    return _tagsRecentSession;
    // 昨天的话主要在做分类标签扩展这块, 找了下云信的技术对接, 讨论了下相关接口的问题和方案可行性相关问题. 目前写了一半了 今天早上继续完善下. 在做私聊模块。
}

- (NSMutableArray<NSDictionary *> *)defaultCurrentSessionTags {
    
    _currentSessionTags = [[NSMutableArray alloc] initWithCapacity:self.defaultTags.count];
    for (NSInteger i = 0; i < self.defaultTags.count; i++) {
        NSDictionary * dic = [NSDictionary dictionary];
        [_currentSessionTags addObject:dic];
    }
    return _currentSessionTags;
}

- (NSArray<NIMUser *> *)myFriends {
    
    if (!_myFriends) {
        _myFriends = [[NIMSDK sharedSDK].userManager myFriends];
    }
    return _myFriends;
}

//- (NSMutableArray *)currentTags {
//
//    if (!_currentTags) {
////        _currentTags = [[NSMutableArray alloc] initWithArray:self.defaultTags];
////        [_currentTags addObject:];
//    }
//    return _currentTags;
//}

- (NSArray *)defaultTags {
    
    if (!_defaultTags) {
        _defaultTags = [[NSMutableArray alloc] initWithObjects:@"置顶",@"☆标好友", @"家人", @"朋友",@"无标签好友", nil];
    }
    return _defaultTags;
}

- (NSString* )getSessionExtTagNameWithRecentSession:(NIMRecentSession* )recentSession {
    // 优化
    YZHRecentSeesionExtModel* extModel = [[YZHRecentSeesionExtModel alloc] init];
    extModel.tagName = recentSession.localExt[@"tagName"];
    
    return extModel.tagName;
}

@end
