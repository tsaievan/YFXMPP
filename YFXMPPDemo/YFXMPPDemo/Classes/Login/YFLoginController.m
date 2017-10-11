//
//  YFLoginController.m
//  YFXMPPDemo
//
//  Created by tsaievan on 17/2/6.
//  Copyright © 2017年 tsaievan. All rights reserved.
//

#import "YFLoginController.h"
#import "YFXMPPManager.h"

@interface YFLoginController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation YFLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


    /****************** -------- 点击登录按钮触发的事件 -------- ******************/
- (IBAction)loginButtonDidClickAction:(UIButton *)sender {
    [kYFXMPPManager loginWithAccountName:self.accountTextField.text password:self.passwordTextField.text successHandler:^{
        NSLog(@"登录成功");
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyBoard instantiateViewControllerWithIdentifier:@"tabBarController"];
        [UIApplication sharedApplication].keyWindow.rootViewController = tabBarController;
    } failueHandler:^(NSError *error) {
        NSLog(@"登录失败%@",error);
    }];
}

@end
