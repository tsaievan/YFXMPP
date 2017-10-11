//
//  YFXMPPManager+AutoPing.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "YFXMPPManager+AutoPing.h"



@implementation YFXMPPManager (AutoPing)

#pragma mark *** 添加心跳检测模块 ***

- (void)addAutoPingModule
{
     /* 心跳包检测初始化 */
    self.xmppAutoPing = [[XMPPAutoPing alloc]initWithDispatchQueue:dispatch_get_main_queue()];
     /* 属性配置 */
    
     /* 每隔多少秒 ping 一次 */
    self.xmppAutoPing.pingInterval = 500;
    
     /* 在这个时间范围内如果 ,还没有收到 ping 之后的回复,则触发代理 */
    self.xmppAutoPing.pingTimeout = 1000;
     /* 添加代理 */
    [self.xmppAutoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
     /* 激活 */
    [self.xmppAutoPing activate:self.xmppStream];
}

#pragma mark *** XMPPAutoPingDelegate 代理 API 回调 ***
- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
{
    NSLog(@"发送心跳包成功");
}

- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
{
    NSLog(@"接收到心跳包成功");
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{
    NSLog(@"请求超时");
}
@end
