//
//  YFXMPPManager+Roster.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "YFXMPPManager+Roster.h"

@implementation YFXMPPManager (Roster)

#pragma mark *** 添加花名册模块 ***
- (void)addRosterModule
{
     /* 1. 初始化 */
    self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
    
     /* 2. 配置属性 */
     /* 自动接收别人添加好友的请求 */
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
     /* 当 xmpp 流断开时,自动清除花名册资源 */
    self.xmppRoster.autoClearAllUsersAndResources = YES;
    
     /* 自动查询花名册 */
    self.xmppRoster.autoFetchRoster = YES;
    
     /* 3. 设置代理 */
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
     /* 4. 激活 */
    
    [self.xmppRoster activate:self.xmppStream];
    
     /* 5. 手动获取花名册列表 */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.xmppRoster fetchRoster];
    });
}

#pragma mark *** XMPPRosterDelegate 代理 API 回调 ***
 /* 开始获取花名册 */
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version
{
    
}

 /* 结束获取花名册 */
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    
}

 /* 接收到好友请求 */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    if (self.rosterReceiveBlock) {
        self.rosterReceiveBlock(presence);
    }
}

 /* 获取到每一个花名册好友 */
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item
{
    
}

 /* 好友关系变更 */
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq
{
    if (self.rosterChangeBlock) {
        self.rosterChangeBlock(iq);
    }
}

@end
