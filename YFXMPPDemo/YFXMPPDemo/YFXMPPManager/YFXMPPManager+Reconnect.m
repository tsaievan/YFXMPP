//
//  YFXMPPManager+Reconnect.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

    
#import "YFXMPPManager+Reconnect.h"

@implementation YFXMPPManager (Reconnect)

#pragma mark *** 添加自动重连模块 ***
- (void)addReconnectModule
{
     /* 1. 初始化 */
    self.xmppReconnect = [[XMPPReconnect alloc]initWithDispatchQueue:dispatch_get_main_queue()];
    
     /* 2. 配置属性 */
     /* 开启自动重连 */
    self.xmppReconnect.autoReconnect = YES;
      /* 设置自动重连延时,表示掉线后,过这么长时间再次请求连接 */
    self.xmppReconnect.reconnectDelay = 5;
    
     /* 3. 激活 */
    [self.xmppReconnect activate:self.xmppStream];
}
@end
