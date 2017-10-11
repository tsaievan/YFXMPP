//
//  YFXMPPManager.m
//  YFXMPPDemo
//
//  Created by tsaievan on 17/2/6.
//  Copyright © 2017年 tsaievan. All rights reserved.
//

#import "YFXMPPManager.h"
/* 添加心跳包模块分类 */
#import "YFXMPPManager+AutoPing.h"
/* 添加自动重连模块分类 */
#import "YFXMPPManager+Reconnect.h"
/* 添加花名册模块分类 */
#import "YFXMPPManager+Roster.h"
/* 添加发送,接收消息模块 */
#import "YFXMPPManager+MessageArchive.h"

/* 添加个人资料模块 */
#import "YFXMPPManager+AvatarCard.h"

@implementation YFXMPPManager  {
    NSString *_accountName;
    NSString *_password;
    YFLoginSuccessHandler _successHandler;
    YFLoginFailueHandler _failueHandler;
}

+ (instancetype)sharedManager {
    static YFXMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YFXMPPManager alloc] init];
    });
    return manager;
}

- (void)loginWithAccountName:(NSString *)accountName password:(NSString *)password successHandler:(YFLoginSuccessHandler)successHandler failueHandler:(YFLoginFailueHandler)failueHandler {
    _accountName = accountName;
    _password = password;
    _successHandler = successHandler;
    _failueHandler = failueHandler;
    
    /* 创建 XMPPJID */
    XMPPJID *jid = [XMPPJID jidWithUser:accountName domain:@"tsaievan.com" resource:@"iPhone 8S 土豪金"];
    self.xmppStream.myJID = jid;
    
    /* 流连接服务器 */
    NSError *error = nil;
    if (![self.xmppStream isConnected]) {
        /* -1 表示一直连接 */
        [self.xmppStream connectWithTimeout:-2 error:&error];
    }
    if (error) {
        NSLog(@"流连接失败,%@",error.localizedDescription);
    }else {
        NSLog(@"流连接成功");
        [self.xmppStream authenticateWithPassword:_password error:nil];
    }
    
}

- (XMPPStream *)xmppStream {
    if (!_xmppStream) {
        /* 初始化 */
        _xmppStream = [[XMPPStream alloc] init];
        /* 主机名 */
        _xmppStream.hostName = @"127.0.0.1";
        /* 主机端口 */
        _xmppStream.hostPort = 5222;
        /* 设置代理 */
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        /* 添加心跳包模块 */
        [self addAutoPingModule];
        
        /* 添加自动重连模块 */
        [self addReconnectModule];
        
        /* 添加花名册模块 */
        [self addRosterModule];
        
        /* 添加发消息模块 */
        [self addMessageArchivingModule];
        
        /* 添加个人资料模块 */
        [self addVCardAvatarModule];
    }
    return _xmppStream;
}

#pragma mark - XMPPStreamDelegate 代理API回调

/****************** -------- 流连接成功后调用此API -------- ******************/
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    [_xmppStream authenticateWithPassword:_password error:nil];
}

/****************** -------- 向服务器验证账号失败 -------- ******************/
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"想服务器验证账号失败:%@",error);
    NSError *xmppError = [NSError errorWithDomain:@"YFXMPPManager" code:101 userInfo:@{ NSLocalizedDescriptionKey : error }];
    /* 错误处理回调 */
    _failueHandler(xmppError);
}

/****************** -------- 向服务器验证账号成功 -------- ******************/
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    /* 设置出席节点 */
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[DDXMLElement elementWithName:@"show" stringValue:@"away"]];
    [presence addChild:[DDXMLElement elementWithName:@"status" stringValue:@"今晚深大北门"]];
    [_xmppStream sendElement:presence];
    NSLog(@"认证成功");
    /* 认证成功的回调 */
    _successHandler();
}

// -------- 流发送消息成功 --------
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"消息发送成功");
    !self.messageSendBlock ? :self.messageSendBlock(message);
}


// -------- 流接收消息成功 --------
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"消息接收成功");
    !self.messageReceiveBlock ? :self.messageReceiveBlock(message);
}









































@end
