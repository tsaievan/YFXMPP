//
//  YFXMPPManager.h
//  YFXMPPDemo
//
//  Created by tsaievan on 17/2/6.
//  Copyright © 2017年 tsaievan. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 添加XMPPFramework 框架
 */
#import <XMPPFramework/XMPPFramework.h>

#define kYFXMPPManager [YFXMPPManager sharedManager]

typedef void(^YFLoginSuccessHandler)();
typedef void(^YFLoginFailueHandler)(NSError *error);


@interface YFXMPPManager : NSObject <XMPPStreamDelegate>

/**
 XMPPStream
 */
@property (nonatomic,strong)XMPPStream *xmppStream;

+ (instancetype)sharedManager;

- (void)loginWithAccountName:(NSString *)accountName password:(NSString *)password successHandler:(YFLoginSuccessHandler)successHandler failueHandler:(YFLoginFailueHandler)failueHandler;

@end
