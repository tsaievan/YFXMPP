//
//  YFXMPPManager+Roster.h
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "YFXMPPManager.h"
 /* 添加花名册框架 */
#import "XMPPRoster.h"
 /* 添加花名册存储器 */
#import "XMPPRosterCoreDataStorage.h"
 /* 添加用户存储对象 */
#import "XMPPUserCoreDataStorageObject.h"

@interface YFXMPPManager ()<XMPPRosterDelegate>

/* 花名册属性 */
@property (nonatomic,strong) XMPPRoster *xmppRoster;

@property (nonatomic,copy) void(^rosterReceiveBlock)(XMPPPresence *presence);

@property (nonatomic,copy) void(^rosterChangeBlock)(XMPPIQ *iq);

@end

@interface YFXMPPManager (Roster)

- (void)addRosterModule;

@end
