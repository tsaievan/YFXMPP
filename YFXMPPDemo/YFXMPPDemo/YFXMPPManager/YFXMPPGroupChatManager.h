//
//  YFXMPPGroupChatManager.h
//  YFWeChat
//
//  Created by tsaievan on 16/10/17.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import <Foundation/Foundation.h>
/* 导入房间模块 */
#import <XMPPFramework/XMPPMUC.h>
/* 导入房间的存储器 */
#import <XMPPFramework/XMPPRoomCoreDataStorage.h>
/* 导入群消息模型对象 */
#import <XMPPFramework/XMPPRoomMessageCoreDataStorageObject.h>
/* 导入群人员管理模型对象 */
#import <XMPPFramework/XMPPRoomOccupantCoreDataStorageObject.h>

#define kYFXMPPGroupChatManager [YFXMPPGroupChatManager sharedManager]

@interface YFXMPPGroupChatManager : NSObject



/* 群聊房间 */
@property (nonatomic,strong)XMPPRoom *xmppRoom;



// -------- 设置一个单例 --------
+ (instancetype)sharedManager;

/**
 *  @param jid      房间的 Jid
 *  @param nickname  房间的昵称
 */
- (void)joinRoomWithJid:(XMPPJID *)jid andNickname:(NSString *)nickname;

@end
