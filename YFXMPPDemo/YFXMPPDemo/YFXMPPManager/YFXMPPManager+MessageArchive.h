//
//  YFXMPPManager+MessageArchive.h
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "YFXMPPManager.h"
/* 导入XMPP信息的框架 */
#import "XMPPMessage.h"

/* 导入信息归档 */
#import "XMPPMessageArchiving.h"
/* 导入信息归档存储器 */
#import "XMPPMessageArchivingCoreDataStorage.h"
/* 导入存储对象 */
#import "XMPPMessageArchiving_Message_CoreDataObject.h"


@interface YFXMPPManager ()

/* 存储信息的属性 */
@property (nonatomic,strong) XMPPMessageArchiving *xmppmessageArchiving;

/* 接收消息 block */
@property (nonatomic,copy) void(^messageReceiveBlock)(XMPPMessage *message);


/* 发送消息 block */
@property (nonatomic,copy) void(^messageSendBlock)(XMPPMessage *message);



@end

@interface YFXMPPManager (MessageArchive)

/* 添加信息存档模块 */
- (void)addMessageArchivingModule;

@end
