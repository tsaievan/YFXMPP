//
//  RosterVC.m
//  YFWeChat
//
//  Created by tsaievan on 16/10/6.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "RosterVC.h"

#import "RosterChatVC.h"

#import "YFXMPPManager+Roster.h"

#import "YFXMPPManager+AvatarCard.h"

@interface RosterVC ()

/* 查询结果控制器 */
@property (nonatomic,strong) NSFetchedResultsController *fetchResultsController;

@end

@implementation RosterVC


#pragma mark *** 视图的生命周期 ***

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self)weakSelf = self;
    kYFXMPPManager.rosterReceiveBlock = ^(XMPPPresence *presence){
        [kYFXMPPManager.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
        [weakSelf updateData];
    };
    
    kYFXMPPManager.rosterChangeBlock = ^(XMPPIQ *iq){
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

// -------- 点击添加好友按钮触发的事件 --------
- (IBAction)addNewFriendBarButtonItemClickAction:(UIBarButtonItem *)sender {
    XMPPJID *jidOne = [XMPPJID jidWithUser:@"tsaievan" domain:@"tsaievan.com" resource:nil];
    /* 添加好友,参数是好友的 jid ,nickname:昵称 */
    
    XMPPJID *jidTwo = [XMPPJID jidWithUser:@"mary" domain:@"tsaievan.com" resource:nil];
    /* 添加好友,参数是好友的 jid ,nickname:昵称 */
    
    XMPPJID *jidThree = [XMPPJID jidWithUser:@"caiyifan" domain:@"tsaievan.com" resource:nil];
    /* 添加好友,参数是好友的 jid ,nickname:昵称 */
    [kYFXMPPManager.xmppRoster addUser:jidOne withNickname:nil];
    [kYFXMPPManager.xmppRoster addUser:jidTwo withNickname:nil];
    [kYFXMPPManager.xmppRoster addUser:jidThree withNickname:nil];
}

// -------- 更新数据 --------
- (void)updateData
{
    /* 养成良好的习惯, 在 block 之前将 self 转化成 weakSelf, 避免循环引用 */
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.fetchResultsController performFetch:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
}


#pragma mark *** Table view data source 数据源方法 ***

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    /* 获取组的数量 */
    return self.fetchResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    /* 获取对应的组的数据集合 */
    id <NSFetchedResultsSectionInfo> fetchedResultsSectionInfo = self.fetchResultsController.sections[section];
    /* 获取 info 的元素数量 */
    return [fetchedResultsSectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RosterVCCell"];
    /* 获取 indexPath 对应的模型 */
    XMPPUserCoreDataStorageObject *objc = [self.fetchResultsController objectAtIndexPath:indexPath];
    /* 获取头像信息 */
    UIImageView *iconImageView = (UIImageView *)[cell.contentView viewWithTag:100];
    /* 获取名字 label */
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    /* 获取账号 label */
    UILabel *accountLabel = (UILabel *)[cell.contentView viewWithTag:102];
    
    NSData *imageData = [kYFXMPPManager.xmppvCardAvatarModule photoDataForJID:objc.jid];
    if (imageData) {
        iconImageView.image = [UIImage imageWithData:imageData];
    }else {
        iconImageView.image = [UIImage imageNamed:@"DefaultHead"];
    }
    
    nameLabel.text = objc.nickname;
    accountLabel.text = objc.jidStr;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.fetchResultsController.sectionIndexTitles[section];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    /* 获取对应 indexPath 的对象 */
    XMPPUserCoreDataStorageObject *objc = [self.fetchResultsController objectAtIndexPath:indexPath];
    
    /* 删除好友 */
    [kYFXMPPManager.xmppRoster removeUser:objc.jid];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.fetchResultsController.sectionIndexTitles;
}

/* tell table which section corresponds to section title/index (e.g. "B",1)) */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return 0;
}

#pragma mark *** Table view delegate 代理方法 ***
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}



#pragma mark *** Getter & Setter ***
- (NSFetchedResultsController *)fetchResultsController
{
    if (!_fetchResultsController) {
        
        /* 1. 创建查询请求 */
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
        /* 2. 设置查询请求的属性 */
        /* note: 设置排序器,否则程序会崩溃 */
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES]];
        
        /* 设置好友关系为 both */
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"subscription == 'both'"];
        /**
         * 第一个参数:查询请求
         * 第二个参数:管理对象上下文
         * 第三个参数:分组依据
         * 第四个参数:缓存名字
         */
        _fetchResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest: fetchRequest managedObjectContext:[XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:@"sectionName" cacheName:nil];
        /* 3. 执行查询 */
        [_fetchResultsController performFetch:nil];
        
        //        /* 4. 控制台输出查询结果 */
        //        for (XMPPUserCoreDataStorageObject *objc in self.fetchResultsController.fetchedObjects) {
        //            NSLog(@"%@",objc);
        //        }
        /* 5. 刷新 tableView */
        [self.tableView reloadData];
    }
    return _fetchResultsController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RosterChatVC"]) {
        RosterChatVC *chatVC = (RosterChatVC *)[segue destinationViewController];
        
        /* 获取选中行的 indexPath */
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        /* 获取点击对象的模型 */
        XMPPUserCoreDataStorageObject *objc = [self.fetchResultsController objectAtIndexPath:indexPath];
        /* 将模型对象的属性的值赋给跳转控制器的属性,让把值传给跳转的控制器 */
        chatVC.jid = objc.jid;
        chatVC.jidStr = objc.jidStr;
    }
}

@end
