//
//  YFXMPPManager+MessageArchive.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "YFXMPPManager+MessageArchive.h"

@implementation YFXMPPManager (MessageArchive)

- (void)addMessageArchivingModule
{
     /* 初始化 */
    self.xmppmessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:[XMPPMessageArchivingCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
     /* 无需配置 */
    
     /* 激活 */
    [self.xmppmessageArchiving activate:self.xmppStream];
    
}

@end
