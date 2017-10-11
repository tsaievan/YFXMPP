//
//  YFXMPPGroupChatManager.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/17.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "YFXMPPGroupChatManager.h"
#import "YFXMPPManager.h"

@implementation YFXMPPGroupChatManager

+ (instancetype)sharedManager
{
    static id instanceType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceType = [[YFXMPPGroupChatManager alloc]init];
    });
    return instanceType;
    
    
}

/**
 *  @param jid      房间的 Jid
 *  @param nickname  房间的昵称
 */
- (void)joinRoomWithJid:(XMPPJID *)jid andNickname:(NSString *)nickname
{
    /* 初始化房间 */
    self.xmppRoom = [[XMPPRoom alloc]initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:jid dispatchQueue:dispatch_get_main_queue()];
    
    /* 配置,无需配置 */
    /* 只需要添加一个代理 */
    [self.xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    /* 激活 */
    [self.xmppRoom activate:kYFXMPPManager.xmppStream];
    
    /**
     * @参数1:nickname
     * @参数2:历史记录,填写 nil, 表示不获取历史记录
     */
    
    /* 如果加入的房间在服务器中不存在,则创建,如果存在,就直接加入 */
    [self.xmppRoom joinRoomUsingNickname:nickname history:nil];
}

#pragma mark *** Getter & Setter ***

// -------- 创建房间成功之后一定要做两件事情,否则房间无法使用 --------
/**
 *  1. 配置房间
 *  2. 邀请人到房间
 */
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    /* 配置房间 */
    [sender configureRoomUsingOptions:nil];
    /* 查询房间配置 */
    [sender fetchConfigurationForm];
    /* 邀请人到房间 */
    
    /**
     *  参数1: 邀请对象的 jid
     *  参数2: 邀请信息
     */
    [sender inviteUser:[XMPPJID jidWithUser:@"tsaievan" domain:@"tsaievan.com" resource:nil] withMessage:@"今天晚上放学别走"];
    
    [sender inviteUser:[XMPPJID jidWithUser:@"caiyifan" domain:@"tsaievan.com" resource:nil] withMessage:@"今晚放学别走"];
    
    [sender inviteUser:[XMPPJID jidWithUser:@"mary" domain:@"tsaievan.com" resource:nil] withMessage:@"今天晚上放学请你喝红牛"];
}

// -------- 房间加入成功 --------
- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    /* 配置房间 */
    [sender configureRoomUsingOptions:nil];
    /* 查询房间配置 */
    [sender fetchConfigurationForm];
    /* 邀请人到房间 */
    
    /**
     *  参数1: 邀请对象的 jid
     *  参数2: 邀请信息
     */
    [sender inviteUser:[XMPPJID jidWithUser:@"tsaievan" domain:@"tsaievan.com" resource:nil] withMessage:@"今天晚上放学别走"];
    
    [sender inviteUser:[XMPPJID jidWithUser:@"caiyifan" domain:@"tsaievan.com" resource:nil] withMessage:@"今晚放学别走"];
    
    [sender inviteUser:[XMPPJID jidWithUser:@"mary" domain:@"tsaievan.com" resource:nil] withMessage:@"今天晚上放学请你喝红牛"];
}

// -------- 房间解散成功 --------
- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{

}


@end
