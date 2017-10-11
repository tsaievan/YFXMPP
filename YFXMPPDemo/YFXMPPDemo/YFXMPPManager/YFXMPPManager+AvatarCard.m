//
//  YFXMPPManager+AvatarCard.m
//  YFXMPPDemo
//
//  Created by tsaievan on 17/2/6.
//  Copyright © 2017年 tsaievan. All rights reserved.
//

#import "YFXMPPManager+AvatarCard.h"

@implementation YFXMPPManager (AvatarCard)

- (void)addVCardAvatarModule {
     /* 创建个人资料模块 */
    self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
    
     /* 创建个人头像模块 */
    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule dispatchQueue:dispatch_get_main_queue()];
     /* 添加代理 */
    [self.xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppvCardTempModule activate:self.xmppStream];
    [self.xmppvCardAvatarModule activate:self.xmppStream];
}

#pragma mark - 代理方法回调

    /****************** -------- 接收到头像更改 -------- ******************/

- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid {
    if (self.changeAvatarPhoto) {
        self.changeAvatarPhoto();
    }
}

    /****************** -------- 上传头像成功 -------- ******************/
- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule {
    if (self.changeAvatarPhoto) {
        self.changeAvatarPhoto();
    }
}

@end
