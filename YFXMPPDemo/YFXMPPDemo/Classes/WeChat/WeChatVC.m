//
//  WeChatVC.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/17.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "WeChatVC.h"
#import "YFXMPPManager+MessageArchive.h"
#import "RosterGroupChatVC.h"
#import "RosterChatVC.h"
#import "YFXMPPGroupChatManager.h"
#import "YFXMPPManager+AvatarCard.h"


@interface WeChatVC ()

/* FetchedResultsController */
@property (nonatomic,strong)NSFetchedResultsController *fetchedResultsController;


@end

@implementation WeChatVC


#pragma mark *** 视图生命周期 ***

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WEAK_SELF
    kYFXMPPManager.messageSendBlock = ^(XMPPMessage *message){
        [weakSelf updateData];
    };
    
    kYFXMPPManager.messageReceiveBlock = ^(XMPPMessage *message){
        [weakSelf updateData];
    };
    

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    WEAK_SELF
    kYFXMPPManager.changeAvatarPhoto = ^{
        [weakSelf updateData];
    };
    [self updateData];
}

#pragma mark *** 事件处理 ***
// -------- 更新数据 --------

- (void)updateData
{
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.fetchedResultsController performFetch:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
}


// -------- 点击群聊按钮触发的事件 --------
- (IBAction)inviteToJoinTheGroupChatAction:(UIBarButtonItem *)sender {
    
    /* 创建房间的 jid, user: 房间名, domain:房间服务器 + 域名 */
    
    XMPPJID *roomJid = [XMPPJID jidWithUser:@"ios5qi" domain:@"shenzhen.tsaievan.com" resource:@"laosiji"];
    [kYFXMPPGroupChatManager joinRoomWithJid:roomJid andNickname:@"laosiji"];
}

// -------- 跳转控制器时触发的事件 --------

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* 将点击的聊天账号传给聊天界面控制器 */
    if ([segue.identifier isEqualToString:@"RosterChatVCSegue"]) {
        
        RosterChatVC *chatVC = (RosterChatVC *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        /* 获取点击的模型对象 */
        XMPPMessageArchiving_Contact_CoreDataObject *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
         /* 赋值 */
        chatVC.jid = contact.bareJid;
        chatVC.jidStr = contact.bareJidStr;
        
    }
    
    if ([segue.identifier isEqualToString:@"RosterGroupChatVCSegue"]) {
        
        RosterGroupChatVC *groupChatVC = (RosterGroupChatVC *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        /* 获取点击的模型对象 */
        XMPPMessageArchiving_Contact_CoreDataObject *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        /* 赋值 */
        groupChatVC.jid = contact.bareJid;
        groupChatVC.jidStr = contact.bareJidStr;
    }
}

#pragma mark *** Table view 数据源 ***

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.fetchedResultsController.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    /* 获取对应的组的数据集合 */
    id <NSFetchedResultsSectionInfo> info = self.fetchedResultsController.sections[section];
    /* 获取 info 的元素数量 */
    
    return [info numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeChatVCCell" forIndexPath:indexPath];
    
    /* 获取 indexPath 对应的模型 */
    XMPPMessageArchiving_Contact_CoreDataObject *objc = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    /* 获取头像 imageView */
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    /* 获取名字 label */
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    /* 获取最近消息 Label */
    UILabel *messageLabel = (UILabel *)[cell.contentView viewWithTag:102];
    /* 获取消息事件 Label */
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:103];
    
    NSData *imageData = [kYFXMPPManager.xmppvCardAvatarModule photoDataForJID:objc.bareJid];
    if (imageData) {
        imageView.image = [UIImage imageWithData:imageData];
    }else {
        imageView.image = [UIImage imageNamed:@"DefaultHead"];
    }
    
    nameLabel.text = objc.bareJidStr;
    messageLabel.text = objc.mostRecentMessageBody;
    
    /* 将 NSDate 转成字符串 */
    /* 1. 初始化格式 */
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    /* 2. 设置时间格式属性 */
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    /* 3. 转化成字符串 */
    timeLabel.text = [dateFormatter stringFromDate:objc.mostRecentMessageTimestamp];
    
    return cell;
}

#pragma mark *** tableViewDelegate代理 API  ***

// -------- 这两个方法是让 cell 可以侧滑删除 --------

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// -------- 侧滑后显示的内容 --------

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

// -------- 点击删除后触发的事件 --------

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* 获取对应 indexPath 的对象 */
    XMPPMessageArchiving_Contact_CoreDataObject *objc = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    /* 删除对象 */
    [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext deleteObject:objc];
    
    /* 保存到数据库 */
    [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext save:nil];
    
    /* 更新数据 */
    [self updateData];
    
}

// -------- 点击 cell 触发的跳转事件 --------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.fetchedResultsController.fetchedObjects[indexPath.row];
    
    /* 表明是群聊 */
    if (![contact.bareJidStr containsString:@"@tsaievan.com"]) {
        
        [self performSegueWithIdentifier:@"RosterGroupChatVCSegue" sender:self];
        
    } else  /* 表明是单聊 */
        
    {
        [self performSegueWithIdentifier:@"RosterChatVCSegue" sender:self];
    }
}


// -------- 返回索引栏数组 --------

- (NSArray <NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sectionIndexTitles;
}

// -------- 点击索引后自动滚动到对应位置 --------

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return 0;
}
#pragma mark *** Getter & Setter ***

-(NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
        /* 初始化查询请求 */
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
        
        /* 设置排序器,否则程序会崩溃,根据接收消息的时间排序 */
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO]];
        
        /**  初始化查询结果控制器
         * 参数1 : 查询请求
         * 参数2 : 管理对象上下文
         * 参数3 : 分组依据
         * 参数4 : 缓存名字
         */
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        /* 执行查询 */
        [_fetchedResultsController performFetch:nil];
        
        /* 如何区分消息是群消息还是单聊消息 */
        for (XMPPMessageArchiving_Contact_CoreDataObject *objc in self.fetchedResultsController.fetchedObjects) {
            if (![objc.bareJidStr containsString:@"@tsaievan.com"]) {
                /* 则表示是群消息 */
                [kYFXMPPGroupChatManager joinRoomWithJid:objc.bareJid andNickname:@"laosiji"];
            }
        }
        [self.tableView reloadData];
    }
    
    return _fetchedResultsController;
}

@end
