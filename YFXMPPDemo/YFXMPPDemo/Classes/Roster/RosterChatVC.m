//
//  RosterChatVC.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "RosterChatVC.h"

#import "YFXMPPManager+MessageArchive.h"

#import "YFXMPPManager+AvatarCard.h"



@interface RosterChatVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;

/* 查询结果控制器 */
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation RosterChatVC



#pragma mark *** 视图生命周期 ***
- (void)viewDidLoad {
    [super viewDidLoad];
    
     /* 为控制器navigationBar 设置标题 */
    self.title = self.jidStr;
     /* scrollView自动调整布局关闭 */
    self.automaticallyAdjustsScrollViewInsets = NO;
     /* 设置文本输入的代理 */
    self.sendMessageTextField.delegate = self;
    WEAK_SELF
    kYFXMPPManager.messageSendBlock = ^(XMPPMessage *message){
        [weakSelf updateData];
    };
    
    kYFXMPPManager.messageReceiveBlock = ^(XMPPMessage *message){
        [weakSelf updateData];
    };

    self.tableView.estimatedRowHeight = 70;
    
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    WEAK_SELF
    
    kYFXMPPManager.changeAvatarPhoto = ^{
        [weakSelf updateData];
    };
    
    [self updateData];
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
        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.fetchedResultsController.fetchedObjects.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
}


#pragma mark *** tableView 数据源方法 ***
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = nil;
    XMPPMessageArchiving_Message_CoreDataObject *objc = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if (objc.isOutgoing) {
        identifier = @"RosterChatVCSendCell";
    }else 
    {
        identifier = @"RosterChatVCRecieveCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
     /* 设置头像 */
    UIImageView *iconImageView = (UIImageView *)[cell.contentView viewWithTag:100];
    
    NSData *imageData = [kYFXMPPManager.xmppvCardAvatarModule photoDataForJID:objc.bareJid];
     /* 头像非空判断 */
    if (imageData) {
         /* 判断消息是否是自己发的,自己发的jid通过xmppstream流去获取 */
        if (objc.isOutgoing) {
            iconImageView.image = [UIImage imageWithData:[kYFXMPPManager.xmppvCardAvatarModule photoDataForJID:kYFXMPPManager.xmppStream.myJID]];
        }else {
            iconImageView.image = [UIImage imageWithData:imageData];
        }
    }else {
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
    XMPPMessage *message = [[XMPPMessage alloc]initWithType:@"chat" to:self.jid];
    
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
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
        
        /* 设置谓词,只显示当前聊天者的聊天记录 */
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@",self.jid.bare];
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        /* 执行查询 */
        [_fetchedResultsController performFetch:nil];
        
        /* 刷新 tableView */
        [self.tableView reloadData];
    }
    return _fetchedResultsController;
}


@end
