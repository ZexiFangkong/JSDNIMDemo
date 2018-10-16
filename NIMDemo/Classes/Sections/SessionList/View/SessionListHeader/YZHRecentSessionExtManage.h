//
//  YZHRecentSessionExtManage.h
//  NIM
//
//  Created by Jersey on 2018/10/18.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZHRecentSeesionExtModel : NSObject

@property (nonatomic, copy) NSString* tagName;

@end

@interface YZHRecentSessionExtManage : NSObject

@property (nonatomic, strong) NSMutableArray<NSMutableArray<NIMRecentSession*>* >* tagsRecentSession;
@property (nonatomic, strong) NSArray<NIMUser* >* myFriends;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> * currentSessionTags;
@property (nonatomic, strong) NSArray* defaultTags;

// 对最近回话进行标签分类
- (void)screeningTagSessionAllRecentSession:(NSMutableArray<NIMRecentSession* > *)allRecentSession;
- (void)sortTagRecentSession;
// 当回话发送变动时,会最近回话进行新增与删除

// 置顶.

//检查当前回话的目标用户是否包含扩展标签,包含则更新到回话本地扩展。
- (void)checkSessionUserTagWithRecentSession:(NIMRecentSession* )recentSession;

@end

NS_ASSUME_NONNULL_END
