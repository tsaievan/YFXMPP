//
//  YFXMPPManager+AvatarCard.h
//  YFXMPPDemo
//
//  Created by tsaievan on 17/2/6.
//  Copyright © 2017年 tsaievan. All rights reserved.
//

#import "YFXMPPManager.h"

//个人资料
//个人头像
#import "XMPPvCardAvatarModule.h"
//个人资料
#import "XMPPvCardTempModule.h"

#import "XMPPvCardCoreDataStorage.h"

#import "XMPPvCardAvatarCoreDataStorageObject.h"

#import "XMPPvCardTemp.h"

typedef  void(^YFChangeAvatarPhotoBlock)();

@interface YFXMPPManager ()
/**
 个人头像模块
 */
@property (nonatomic,strong)XMPPvCardAvatarModule *xmppvCardAvatarModule;


/**
 个人资料模块
 */
@property (nonatomic,strong)XMPPvCardTempModule *xmppvCardTempModule;

@property (nonatomic,copy)YFChangeAvatarPhotoBlock changeAvatarPhoto;

@end

@interface YFXMPPManager (AvatarCard)<XMPPvCardAvatarDelegate,XMPPvCardTempModuleDelegate>

- (void)addVCardAvatarModule;

@end
