//
//  RosterGroupChatVC.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/17.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "RosterGroupChatVC.h"
#import "YFXMPPManager+MessageArchive.h"
#import "YFXMPPGroupChatManager.h"
#import "YFXMPPManager+AvatarCard.h"

@interface RosterGroupChatVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;

/* 查询结果控制器 */
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation RosterGroupChatVC



#pragma mark *** 视图生命周期 ***
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 为控制器navigationBar 设置标题 */
    self.title = self.jidStr;
    /* scrollView自动调整布局关闭 */
    self.automaticallyAdjustsScrollViewInsets = NO;
    /* 设置文本输入的代理 */
    self.sendMessageTextField.delegate = self;
    __weak typeof(self)weakSelf = self;
    kYFXMPPManager.messageReceiveBlock = ^(XMPPMessage *message){
        [weakSelf updateData];
    };
    
    kYFXMPPManager.messageSendBlock = ^(XMPPMessage *message){
        [weakSelf updateData];
    };
    
    kYFXMPPManager.changeAvatarPhoto = ^{
        [weakSelf updateData];
    };
    
    self.tableView.estimatedRowHeight = 70;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark *** 事件处理 ***

- (void)updateData
{
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.fetchedResultsController performFetch:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
        if (weakSelf.fetchedResultsController.fetchedObjects.count > 1) {
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.fetchedResultsController.fetchedObjects.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    });
    
}

/****************** -------- 根据用户房间jid查询用户真实jid -------- ******************/
- (XMPPJID *)fetchRealOccupantJidWithRoomJid:(XMPPJID *)roomJid {
    /* 创建查询请求 */
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPRoomOccupantCoreDataStorageObject"];
    /* 设置排序器 */
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"realJIDStr" ascending:YES]];
    /* 设置谓词 */
    request.predicate = [NSPredicate predicateWithFormat:@"jidStr == %@",roomJid.full];
    /* 执行查询 */
    NSArray *resultArray = [[XMPPRoomCoreDataStorage sharedInstance].mainThreadManagedObjectContext executeFetchRequest:request error:nil];
    
    if (resultArray.count > 0) {
        XMPPRoomOccupantCoreDataStorageObject *objc = resultArray[0];
        return objc.realJID;
    }else {
        return nil;
    }
}


#pragma mark *** tableView 数据源方法 ***
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = nil;
    XMPPRoomMessageCoreDataStorageObject *objc = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if (objc.isFromMe) {
        identifier = @"RosterChatVCSendCell";
    }else
        {
        identifier = @"RosterChatVCRecieveCell";
        }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    /* 设置头像 */
    UIImageView *iconImageView = (UIImageView *)[cell.contentView viewWithTag:100];
    
    XMPPJID *personalJid = [self fetchRealOccupantJidWithRoomJid:objc.jid];
    
    NSData *imageData = [kYFXMPPManager.xmppvCardAvatarModule photoDataForJID:personalJid];
    //头像非空判断
    if (imageData) {
        
        //判断消息是否自己发的 自己发的jid通过xmppstream流去获取
        if (objc.isFromMe) {
            iconImageView.image = [UIImage imageWithData:[kYFXMPPManager.xmppvCardAvatarModule photoDataForJID:kYFXMPPManager.xmppStream.myJID]];
        }
        else {
            iconImageView.image = [UIImage imageWithData:imageData];
        }
    }
    else{
        iconImageView.image = [UIImage imageNamed:@"DefaultHead"];
    }
    
    
    /* 设置聊天内容 */
    UILabel *bodyLabel = (UILabel *)[cell.contentView viewWithTag:101];
    bodyLabel.text = objc.body;
    return cell;
}


/* 自适应行高 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}



#pragma mark *** textField代理 API ***

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /* 初始化一个聊天模型 */
    
    /**
     * 第一个参数: 聊天类型,"chat"表示单聊
     * 第二个参数: 聊天对象, 即聊天消息发送给谁
     */
    XMPPMessage *message = [[XMPPMessage alloc]initWithType:@"groupchat" to:self.jid];
    
    /* 添加聊天内容 */
    [message addBody:textField.text];
    
    /* 发送消息 */
    
    [kYFXMPPManager.xmppStream sendElement:message];
    
    /* 发送完毕之后清空文本 */
    textField.text = nil;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark *** Getter & Setter ***

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        /* 初始化查询请求 */
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomMessageCoreDataStorageObject"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localTimestamp" ascending:YES]];
        
        /* 设置谓词,只显示当前聊天者的聊天记录 */
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"roomJIDStr == %@",self.jid.bare];
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:[XMPPRoomCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        /* 执行查询 */
        [_fetchedResultsController performFetch:nil];
        
        /* 刷新 tableView */
        [self.tableView reloadData];
    }
    return _fetchedResultsController;
}

- (IBAction)test:(id)sender {
    XMPPMessage *message = [[XMPPMessage alloc]initWithType:@"groupchat" to:self.jid];
    
    /* 添加聊天内容 */
    [message addBody:@"test"];
    
    /* 发送消息 */
    
    [kYFXMPPManager.xmppStream sendElement:message];
    
}

@end

