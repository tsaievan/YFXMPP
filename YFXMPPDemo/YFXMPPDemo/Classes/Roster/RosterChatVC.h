//
//  RosterChatVC.h
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"

@interface RosterChatVC : UIViewController
/* 聊天者 JID */
@property (nonatomic,strong)XMPPJID *jid;

 /* 聊天者账号字符串 */
@property (nonatomic,copy)NSString *jidStr;

@end
