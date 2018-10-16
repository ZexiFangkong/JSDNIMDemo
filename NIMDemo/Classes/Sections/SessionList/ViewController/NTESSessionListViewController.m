//
//  NTESSessionListViewController.m
//  NIMDemo
//
//  Created by chris on 15/2/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionListViewController.h"
#import "NTESSessionViewController.h"
#import "NTESSessionPeekViewController.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "NTESListHeader.h"
#import "NTESClientsTableViewController.h"
#import "NTESSnapchatAttachment.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESChartletAttachment.h"
#import "NTESWhiteboardAttachment.h"
#import "NTESSessionUtil.h"
#import "NTESPersonalCardViewController.h"
#import "NTESRobotCardViewController.h"
#import "NTESRedPacketAttachment.h"
#import "NTESRedPacketTipAttachment.h"
#define SessionListTitle @"云信 Demo"
#import "NIMSessionListCell.h"
#import <SVProgressHUD.h>
//#import "NIMSessionListCell+YZHSessionListCell.h"
#import "YZHPrivatelyChatListHeaderView.h"
#import "YZHRecentSessionExtManage.h"

typedef enum : NSUInteger {
    YZHTableViewShowTypeDefault = 0,
    YZHTableViewShowTypeTags,
} YZHTableViewShowType;

static YZHTableViewShowType currentShowType = YZHTableViewShowTypeDefault;
@interface NTESSessionListViewController ()<NIMLoginManagerDelegate,NTESListHeaderDelegate,NIMEventSubscribeManagerDelegate,UIViewControllerPreviewingDelegate,NIMUserManagerDelegate,NIMConversationManagerDelegate>

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) NTESListHeader *header;

@property (nonatomic,assign) BOOL supportsForceTouch;

@property (nonatomic,strong) NSMutableDictionary *previews;

@property (nonatomic, strong) UIButton* leftButton;

@property (nonatomic, strong) UITableView* tagsTableView;

@property (nonatomic, strong) NSMutableArray<NSMutableArray<NIMRecentSession*>* >* tagsArray;

@property (nonatomic, strong) YZHRecentSessionExtManage* recentSessionExtManage;

@property (nonatomic, strong) NSMutableDictionary* headerViewDictionary;

@end

@implementation NTESSessionListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _previews = [[NSMutableDictionary alloc] init];
        self.autoRemoveRemoteSession = [[NTESBundleSetting sharedConfig] autoRemoveRemoteSession];
    }
    return self;
}

- (void)dealloc{
    
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    
    // 设置UI配置器
    NIMKitConfig* config = [[NIMKitConfig alloc] init];
    config.avatarType = NIMKitAvatarTypeRadiusCorner;
    [NIMKit sharedKit].config = config;
    
    // 新增扩展表
    [self.view addSubview:self.tagsTableView];
    [self.view layoutIfNeeded];
    //
    if (self.recentSessions.count) {
        [self.recentSessionExtManage screeningTagSessionAllRecentSession:self.recentSessions];
        [self.recentSessionExtManage sortTagRecentSession];
        if (self.recentSessionExtManage.tagsRecentSession.firstObject.count) {
            [self.tagsTableView reloadData];
        }
    }
    
    self.supportsForceTouch = [self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    [[NIMSDK sharedSDK].subscribeManager addDelegate:self];
    [[NIMSDK sharedSDK].userManager addDelegate:self];
    
    self.header = [[NTESListHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.delegate = self;
    [self.view addSubview:self.header];

    self.emptyTipLabel = [[UILabel alloc] init];
    self.emptyTipLabel.text = @"还没有会话，在通讯录中找个人聊聊吧";
    [self.emptyTipLabel sizeToFit];
    self.emptyTipLabel.hidden = self.recentSessions.count;
    [self.view addSubview:self.emptyTipLabel];
    
    NSString *userID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    self.navigationItem.titleView  = [self titleView:userID];
    [self setUpNavItem];
}

#pragma mark - NIMUserManagerDelegate

- (void)onFriendChanged:(NIMUser *)user
{
    [self notifyUser:user];
    [self refresh];
}

- (void)onUserInfoChanged:(NIMUser *)user
{
    [self notifyUser:user];
}

- (void)notifyUser:(NIMUser *)user
{
    if (!user)
    {
        NSLog(@"warning: notify user failed because user is empty");
    }
    else
    {
        [[NIMKit sharedKit] notfiyUserInfoChanged:@[user.userId]];
    }
}


- (void)setUpNavItem{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setImage:[UIImage imageNamed:@"icon_sessionlist_more_normal"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"icon_sessionlist_more_pressed"] forState:UIControlStateHighlighted];
    [moreBtn sizeToFit];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItem = moreItem;
    
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(funcation:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:@"AppIcon"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"icon_chatroom_pressed"] forState:UIControlStateHighlighted];
    [leftButton sizeToFit];
    UIBarButtonItem *exetension = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.leftButton = leftButton;
    self.navigationItem.leftBarButtonItem = exetension;
}

- (void)funcation:(UIButton *)sender {
    
    self.leftButton.selected = !self.leftButton.isSelected;
    currentShowType = !currentShowType;
    self.recentSessions = [self customSortRecents:self.recentSessions];
    //显示扩展功能.
    if (self.leftButton.isSelected) {
        self.tableView.hidden = YES;
        self.tagsTableView.hidden = NO;
        [self.tagsTableView reloadData];
    } else {
        self.tableView.hidden = NO;
        self.tagsTableView.hidden = YES;
    }
}

- (void)refresh{
    [super refresh];
    if (self.recentSessionExtManage.tagsRecentSession.firstObject.count) {
        [self.tagsTableView reloadData];
    }
    self.emptyTipLabel.hidden = self.recentSessions.count;
}

- (void)more:(id)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *markAllMessagesReadAction = [UIAlertAction actionWithTitle:@"标记所有消息为已读"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [[NIMSDK sharedSDK].conversationManager markAllMessagesRead];
                                                        }];
    [vc addAction:markAllMessagesReadAction];
    
    
    UIAlertAction *cleanAllMessagesAction = [UIAlertAction actionWithTitle:@"清理所有消息"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                                         BOOL removeRecentSessions = [NTESBundleSetting sharedConfig].removeSessionWhenDeleteMessages;
                                                                         BOOL removeTables = [NTESBundleSetting sharedConfig].dropTableWhenDeleteMessages;

                                                                         NIMDeleteMessagesOption *option = [[NIMDeleteMessagesOption alloc] init];
                                                                         option.removeSession = removeRecentSessions;
                                                                         option.removeTable = removeTables;

                                                                         [[NIMSDK sharedSDK].conversationManager deleteAllMessages:option];
                                                                     }];
    [vc addAction:cleanAllMessagesAction];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                                     style:UIAlertActionStyleCancel
                                                                   handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)onSelectedRecent:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath{
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onSelectedAvatar:(NIMRecentSession *)recent
             atIndexPath:(NSIndexPath *)indexPath{
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        UIViewController *vc;
        if ([[NIMSDK sharedSDK].robotManager isValidRobot:recent.session.sessionId])
        {
            vc = [[NTESRobotCardViewController alloc] initWithUserId:recent.session.sessionId];
        }
        else
        {
            vc = [[NTESPersonalCardViewController alloc] initWithUserId:recent.session.sessionId];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)onDeleteRecentAtIndexPath:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath
{
    id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
    [manager deleteRecentSession:recent];
}
// 置顶
- (void)onTopRecentAtIndexPath:(NIMRecentSession *)recent
                   atIndexPath:(NSIndexPath *)indexPath
                         isTop:(BOOL)isTop
{
    if (isTop)
    {
        [NTESSessionUtil removeRecentSessionMark:recent.session type:NTESRecentSessionMarkTypeTop];
    }
    else
    {
        [NTESSessionUtil addRecentSessionMark:recent.session type:NTESRecentSessionMarkTypeTop];
    }
    self.recentSessions = [self customSortRecents:self.recentSessions];
    [self.recentSessionExtManage screeningTagSessionAllRecentSession:self.recentSessions];
    [self.recentSessionExtManage sortTagRecentSession];
    [self.tableView reloadData];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self refreshSubview];
}


- (NSString *)nameForRecentSession:(NIMRecentSession *)recent{
    if ([recent.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        return @"我的电脑";
    }
    return [super nameForRecentSession:recent];
}

- (NSMutableArray *)customSortRecents:(NSMutableArray *)recentSessions
{
    for (NSInteger i = 0 ; i < recentSessions.count; i++) {
        NIMRecentSession* recentSession = recentSessions[i];
        BOOL isSessionP2PType;
        if (recentSession.session.sessionType == NIMSessionTypeP2P) {
            isSessionP2PType = YES;
        } else {
            isSessionP2PType = NO;
        }
        if (isSessionP2PType) {
            
        } else {
            [recentSessions removeObjectAtIndex:i];
        }
        
    }
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[recentSessions copy]];
    [array sortUsingComparator:^NSComparisonResult(NIMRecentSession *obj1, NIMRecentSession *obj2) {
        NSInteger score1 = [NTESSessionUtil recentSessionIsMark:obj1 type:NTESRecentSessionMarkTypeTop]? 10 : 0;
        NSInteger score2 = [NTESSessionUtil recentSessionIsMark:obj2 type:NTESRecentSessionMarkTypeTop]? 10 : 0;
        if (obj1.lastMessage.timestamp > obj2.lastMessage.timestamp)
        {
            score1 += 1;
        }
        else if (obj1.lastMessage.timestamp < obj2.lastMessage.timestamp)
        {
            score2 += 1;
        }
        if (score1 == score2)
        {
            return NSOrderedSame;
        }
        return score1 > score2? NSOrderedAscending : NSOrderedDescending;
    }];
    return array;
}

#pragma mark - SessionListHeaderDelegate

- (void)didSelectRowType:(NTESListHeaderType)type{
    //多人登录
    switch (type) {
        case ListHeaderTypeLoginClients:{
            NTESClientsTableViewController *vc = [[NTESClientsTableViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}


#pragma mark - NIMLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step{
    [super onLogin:step];
    switch (step) {
        case NIMLoginStepLinkFailed:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(未连接)"];
            break;
        case NIMLoginStepLinking:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(连接中)"];
            break;
        case NIMLoginStepLinkOK:
        case NIMLoginStepSyncOK:
            self.titleLabel.text = SessionListTitle;
            break;
        case NIMLoginStepSyncing:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(同步数据)"];
            break;
        default:
            break;
    }
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    [self.header refreshWithType:ListHeaderTypeNetStauts value:@(step)];
    [self refreshSubview];
}

- (void)onMultiLoginClientsChanged
{
    [self.header refreshWithType:ListHeaderTypeLoginClients value:[NIMSDK sharedSDK].loginManager.currentLoginClients];
    [self refreshSubview];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([tableView isEqual:self.tableView]) {
        NIMSessionListCell* cell = (NIMSessionListCell* )[super tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell;
    } else {
       static NSString * cellId = @"TagCell";
       NIMSessionListCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[NIMSessionListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//            [cell.avatarImageView addTarget:self action:@selector(onTouchAvatar:) forControlEvents:UIControlEventTouchUpInside];
        }
            NIMRecentSession *recent = [self.recentSessionExtManage.tagsRecentSession[indexPath.section] objectAtIndex:indexPath.row];
            cell.nameLabel.text = [self nameForRecentSession:recent];
            [cell.avatarImageView setAvatarBySession:recent.session];
            [cell.nameLabel sizeToFit];
            cell.messageLabel.attributedText  = [self contentForRecentSession:recent];
            [cell.messageLabel sizeToFit];
            cell.timeLabel.text = [self timestampDescriptionForRecentSession:recent];
            [cell.timeLabel sizeToFit];

            [cell refresh:recent];

        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if ([tableView isEqual:self.tagsTableView]) {
        if ([self.recentSessionExtManage.tagsRecentSession count]) {
            return self.recentSessionExtManage.tagsRecentSession.count;
        } else {
            return 0;
        }
    } else {
        return 1;
    }
}

- (UIView* )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (![tableView isEqual:self.tableView]) {
        YZHPrivatelyChatListHeaderView* headerView = [self.headerViewDictionary objectForKey:@(section)];
        if (!headerView)
        {
            NIMRecentSession* session = [self.self.recentSessionExtManage.tagsRecentSession[section] firstObject];
            headerView = [[YZHPrivatelyChatListHeaderView alloc] init];
            if (section == 0)
            {
                NSString *markTypeTopkey = [NTESSessionUtil keyForMarkType:NTESRecentSessionMarkTypeTop];
                BOOL isMarkTop = session.localExt[markTypeTopkey];
                if (isMarkTop) {
                    headerView.tagNameLabel.text = @"置顶";
                }
            } else {
                headerView.tagNameLabel.text = session.localExt[@"tagName"] ? session.localExt[@"tagName"] : @"无好友标签";
            }
            [headerView.tagNameLabel sizeToFit];
            headerView.unReadCountLabel.text = @"9";
            [headerView.unReadCountLabel sizeToFit];
            headerView.guideImageView.image = [UIImage imageNamed:@"chatroom_role_manager"];
            [headerView.guideImageView sizeToFit];
            headerView.section = section;
            headerView.currentStatusType = YZHTableViewShowTypeDefault;
            __weak typeof(self) weakSelf = self;
            headerView.callBlock = ^(NSInteger currentSection) {
                [weakSelf selectedTableViewForHeaderInSection:currentSection];
            };
            // 缓存
            [self.headerViewDictionary setObject:headerView forKey:@(section)];
            return headerView;
        } else {
            return headerView;
        }
    } else {
        return nil;
    }
    
}

- (void)selectedTableViewForHeaderInSection:(NSInteger)section {
    
    YZHPrivatelyChatListHeaderView* headerView = [self.headerViewDictionary objectForKey:@(section)];
    
    NSInteger integer = headerView.currentStatusType;
    integer = ((++integer) > 2 ? 0 : integer);
    headerView.currentStatusType = integer;
    [headerView refreshStatus];
    
    switch (headerView.currentStatusType) {
        case YZHListHeaderStatusTypeDefault:
            headerView.guideImageView.image = [UIImage imageNamed:@"chatroom_role_manager"];
            break;
        case YZHListHeaderStatusTypeShow:
            headerView.guideImageView.image = [UIImage imageNamed:@"chatroom_announce"];
            break;
        case YZHListHeaderStatusTypeClose:
            headerView.guideImageView.image = [UIImage imageNamed:@"chatroom_role_master"];
            break;
        default:
            break;
    }
    NSIndexSet *indexSet= [[NSIndexSet alloc] initWithIndex: section];
    [self.tagsTableView reloadSections:indexSet withRowAnimation: UITableViewRowAnimationNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.tagsTableView] && self.recentSessionExtManage.tagsRecentSession.count) {
        YZHPrivatelyChatListHeaderView* headerView = [self.headerViewDictionary objectForKey:@(section)];
        if (headerView) {
            if (headerView.currentStatusType == YZHListHeaderStatusTypeDefault) {
                NSInteger row = [self.recentSessionExtManage.tagsRecentSession[section] count] < 3 ? [self.recentSessionExtManage.tagsRecentSession[section] count] : 3;
                return row;
            } else if (headerView.currentStatusType == YZHListHeaderStatusTypeShow) {
                return [self.recentSessionExtManage.tagsRecentSession[section] count];
            } else {
                return 0;
            }
        }
        return [self.recentSessionExtManage.tagsRecentSession[section] count];
    } else {
        return self.recentSessions.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (![tableView isEqual:self.tableView]) {
        return 40;
    } else {
        return 0;
    }
    
}

// 添加分段尾,为了隐藏每个Section最后一个 Cell 分割线
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (![tableView isEqual:self.recentSessionExtManage.tagsRecentSession]) {
        return 10;
    } else {
        return 0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NIMRecentSession *recentSession;
    if ([tableView isEqual:self.tableView]) {
        recentSession = self.recentSessions[indexPath.row];
    } else {
        recentSession = self.recentSessionExtManage.tagsRecentSession[indexPath.section][indexPath.row];
    }
    [self onSelectedRecent:recentSession atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.supportsForceTouch) {
        id<UIViewControllerPreviewing> preview = [self registerForPreviewingWithDelegate:self sourceView:cell];
        [self.previews setObject:preview forKey:@(indexPath.row)];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.supportsForceTouch) {
        id<UIViewControllerPreviewing> preview = [self.previews objectForKey:@(indexPath.row)];
        [self unregisterForPreviewingWithContext:preview];
        [self.previews removeObjectForKey:@(indexPath.row)];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)context viewControllerForLocation:(CGPoint)point {
    UITableViewCell *touchCell = (UITableViewCell *)context.sourceView;
    if ([touchCell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:touchCell];
        NIMRecentSession *recent = self.recentSessions[indexPath.row];
        NTESSessionPeekNavigationViewController *nav = [NTESSessionPeekNavigationViewController instance:recent.session];
        return nav;
    }
    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    UITableViewCell *touchCell = (UITableViewCell *)previewingContext.sourceView;
    if ([touchCell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:touchCell];
        NIMRecentSession *recent = self.recentSessions[indexPath.row];
        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
        [self.navigationController showViewController:vc sender:nil];
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if ([tableView isEqual:weakSelf.tableView]) {
            NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
            [weakSelf onDeleteRecentAtIndexPath:recentSession atIndexPath:indexPath];
        } else {
            NIMRecentSession *recentSession = weakSelf.recentSessionExtManage.tagsRecentSession[indexPath.section][indexPath.row
                                                                                             ];
            [weakSelf onDeleteRecentAtIndexPath:recentSession atIndexPath:indexPath];
        }
        [tableView setEditing:NO animated:YES];
    }];
    
    NIMRecentSession *recentSession;
    if ([tableView isEqual:self.tableView]) {
        recentSession = weakSelf.recentSessions[indexPath.row];
    } else {
        recentSession = weakSelf.recentSessionExtManage.tagsRecentSession[indexPath.section][indexPath.row];
    }
    BOOL isTop = [NTESSessionUtil recentSessionIsMark:recentSession type:NTESRecentSessionMarkTypeTop];
    UITableViewRowAction *top = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:isTop?@"取消置顶":@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf onTopRecentAtIndexPath:recentSession atIndexPath:indexPath isTop:isTop];
        [tableView setEditing:NO animated:YES];
    }];
    
    return @[delete,top];
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // All tasks are handled by blocks defined in editActionsForRowAtIndexPath, however iOS8 requires this method to enable editing
}


#pragma mark - NIMEventSubscribeManagerDelegate

- (void)onRecvSubscribeEvents:(NSArray *)events
{
    NSMutableSet *ids = [[NSMutableSet alloc] init];
    for (NIMSubscribeEvent *event in events) {
        [ids addObject:event.from];
    }

    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        NIMRecentSession *recent = self.recentSessions[indexPath.row];
        if (recent.session.sessionType == NIMSessionTypeP2P) {
            NSString *from = recent.session.sessionId;
            if ([ids containsObject:from]) {
                [indexPaths addObject:indexPath];
            }
        }
    }

    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)findInsertPlace:(NIMRecentSession *)recentSession{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.recentSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NIMRecentSession *item = obj;
        if (item.lastMessage.timestamp <= recentSession.lastMessage.timestamp) {
            *stop = YES;
            find  = YES;
            matchIdx = idx;
        }
    }];
    if (find) {
        return matchIdx;
    }else{
        return self.recentSessions.count;
    }
}

#pragma mark - NIMConversationManagerDelegate

- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    [self.recentSessionExtManage checkSessionUserTagWithRecentSession:recentSession];
    [self.recentSessions addObject:recentSession];
    self.recentSessions = [self customSortRecents:self.recentSessions];
    //TODO: 有空了在单独封装一个新增,接口.
    [self.recentSessionExtManage screeningTagSessionAllRecentSession:self.recentSessions];
    [self refresh];
    
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    
    for (NIMRecentSession *recent in self.recentSessions)
    {
        if ([recentSession.session.sessionId isEqualToString:recent.session.sessionId])
        {
            [self.recentSessions removeObject:recent];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:recentSession];
    [self.recentSessions insertObject:recentSession atIndex:insert];
    self.recentSessions = [self customSortRecents:self.recentSessions];
    [self.recentSessionExtManage screeningTagSessionAllRecentSession:self.recentSessions];
    [self refresh];
}

- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    //清理本地数据
    NSInteger index = [self.recentSessions indexOfObject:recentSession];
    [self.recentSessions removeObjectAtIndex:index];

    //如果删除本地会话后就不允许漫游当前会话，则需要进行一次删除服务器会话的操作
    if (self.autoRemoveRemoteSession)
    {
        [[NIMSDK sharedSDK].conversationManager deleteRemoteSessions:@[recentSession.session]
                                                          completion:nil];
    }
    self.recentSessions = [self customSortRecents:self.recentSessions];
    [self.recentSessionExtManage screeningTagSessionAllRecentSession:self.recentSessions];
    [self refresh];
}

- (void)messagesDeletedInSession:(NIMSession *)session{
    self.recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    self.recentSessions = [self customSortRecents:self.recentSessions];
    [self.recentSessionExtManage screeningTagSessionAllRecentSession:self.recentSessions];
    [self refresh];
}

- (void)allMessagesDeleted{
    self.recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    self.recentSessions = [self customSortRecents:self.recentSessions];
    [self.recentSessionExtManage screeningTagSessionAllRecentSession:self.recentSessions];
    [self refresh];
}

- (void)allMessagesRead
{
    self.recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    self.recentSessions = [self customSortRecents:self.recentSessions];
    [self.recentSessionExtManage screeningTagSessionAllRecentSession:self.recentSessions];
    [self refresh];
}

#pragma mark - Private

- (void)refreshSubview{
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    if (@available(iOS 11.0, *))
    {
        self.header.top = self.view.safeAreaInsets.top;
        self.tableView.top = self.header.bottom;
        CGFloat offset = self.view.safeAreaInsets.bottom;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
    }
    else
    {
        self.tableView.top = self.header.height;
        self.header.bottom    = self.tableView.top + self.tableView.contentInset.top;
    }
    self.tableView.height = self.view.height - self.tableView.top;
    
    self.emptyTipLabel.centerX = self.view.width * .5f;
    self.emptyTipLabel.centerY = self.tableView.height * .5f;
}

- (UIView*)titleView:(NSString*)userID{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text =  SessionListTitle;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [self.titleLabel sizeToFit];
    UILabel *subLabel  = [[UILabel alloc] initWithFrame:CGRectZero];
    subLabel.textColor = [UIColor grayColor];
    subLabel.font = [UIFont systemFontOfSize:12.f];
    subLabel.text = userID;
    subLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [subLabel sizeToFit];
    
    UIView *titleView = [[UIView alloc] init];
    titleView.width  = subLabel.width;
    titleView.height = self.titleLabel.height + subLabel.height;
    
    subLabel.bottom = titleView.height;
    [titleView addSubview:self.titleLabel];
    [titleView addSubview:subLabel];
    return titleView;
}
// 检测最后一条消息, 来设置 cell message 展示
- (NSAttributedString *)contentForRecentSession:(NIMRecentSession *)recent{
    NSAttributedString *content;
    if (recent.lastMessage.messageType == NIMMessageTypeCustom)
    {
        NIMCustomObject *object = recent.lastMessage.messageObject;
        NSString *text = @"";
        if ([object.attachment isKindOfClass:[NTESSnapchatAttachment class]])
        {
            text = @"[阅后即焚]";
        }
        else if ([object.attachment isKindOfClass:[NTESJanKenPonAttachment class]])
        {
            text = @"[猜拳]";
        }
        else if ([object.attachment isKindOfClass:[NTESChartletAttachment class]])
        {
            text = @"[贴图]";
        }
        else if ([object.attachment isKindOfClass:[NTESWhiteboardAttachment class]])
        {
            text = @"[白板]";
        }
        else if ([object.attachment isKindOfClass:[NTESRedPacketAttachment class]])
        {
            text = @"[红包消息]";
        }
        else if ([object.attachment isKindOfClass:[NTESRedPacketTipAttachment class]])
        {
            NTESRedPacketTipAttachment *attach = (NTESRedPacketTipAttachment *)object.attachment;
            text = attach.formatedMessage;
        }
        else
        {
            text = @"[未知消息]";
        }
        if (recent.session.sessionType != NIMSessionTypeP2P)
        {
            NSString *nickName = [NTESSessionUtil showNick:recent.lastMessage.from inSession:recent.lastMessage.session];
            text =  nickName.length ? [nickName stringByAppendingFormat:@" : %@",text] : @"";
        }
        content = [[NSAttributedString alloc] initWithString:text];
    }
    else
    {
        content = [super contentForRecentSession:recent];
    }
    NSMutableAttributedString *attContent = [[NSMutableAttributedString alloc] initWithAttributedString:content];
    [self checkNeedAtTip:recent content:attContent];
//    [self checkOnlineState:recent content:attContent];
    return attContent;
}

- (void)checkNeedAtTip:(NIMRecentSession *)recent content:(NSMutableAttributedString *)content
{
    if ([NTESSessionUtil recentSessionIsMark:recent type:NTESRecentSessionMarkTypeAt]) {
        NSAttributedString *atTip = [[NSAttributedString alloc] initWithString:@"[有人@你] " attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        [content insertAttributedString:atTip atIndex:0];
    }
}

- (void)checkOnlineState:(NIMRecentSession *)recent content:(NSMutableAttributedString *)content
{
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NSString *state  = [NTESSessionUtil onlineState:recent.session.sessionId detail:NO];
        if (state.length) {
            NSString *format = [NSString stringWithFormat:@"[%@] ",state];
            NSAttributedString *atTip = [[NSAttributedString alloc] initWithString:format attributes:nil];
            [content insertAttributedString:atTip atIndex:0];
        }
    }
    
}

#pragma mark -- SET GET

-(UITableView *)tagsTableView {
    
    if (!_tagsTableView) {
        _tagsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tagsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.height - 48);
        _tagsTableView.delegate         = self;
        _tagsTableView.dataSource       = self;
        _tagsTableView.tableFooterView  = [[UIView alloc] init];
        _tagsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tagsTableView.backgroundColor = [UIColor grayColor];
        _tagsTableView.hidden = YES;
        [_tagsTableView reloadData];
    }
    return _tagsTableView;
}

- (NSMutableArray<NSMutableArray<NIMRecentSession *> *> *)tagsArray {
    
    if (!_tagsArray) {
        _tagsArray = self.recentSessionExtManage.tagsRecentSession;
    }
    return _tagsArray;
}

- (YZHRecentSessionExtManage *)recentSessionExtManage {
    
    if (!_recentSessionExtManage) {
        _recentSessionExtManage = [[YZHRecentSessionExtManage alloc] init];
    }
    return _recentSessionExtManage;
}

- (NSMutableDictionary *)headerViewDictionary {
    
    if (!_headerViewDictionary) {
        _headerViewDictionary = [[NSMutableDictionary alloc] init];
    }
    return _headerViewDictionary;
}

@end
