//
//  YFXMPPManager+AutoPing.h
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "YFXMPPManager.h"
/* 加入心跳检测模块 */
#import <XMPPFramework/XMPPAutoPing.h>

@interface YFXMPPManager ()<XMPPAutoPingDelegate>
/* 将心跳检测模块作为 YFXMPPManager 的属性 */
@property (nonatomic,strong)XMPPAutoPing *xmppAutoPing;

@end

@interface YFXMPPManager (AutoPing)
/* 添加心模块的方法 */
- (void)addAutoPingModule;

@end
