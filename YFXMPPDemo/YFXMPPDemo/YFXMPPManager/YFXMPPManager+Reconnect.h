//
//  YFXMPPManager+Reconnect.h
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//
// -------- 添加重连模块 --------
#import "YFXMPPManager.h"
#import "XMPPReconnect.h"

@interface YFXMPPManager ()

/* 重连属性 */
@property (nonatomic,strong) XMPPReconnect *xmppReconnect;

@end

@interface YFXMPPManager (Reconnect)

 /* 添加自动重连模块的方法 */

- (void)addReconnectModule;

@end
