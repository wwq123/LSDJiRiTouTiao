//
//  LSDTuiJianVC.m
//  网易新闻(搭建界面)
//
//  Created by SelenaWong on 16/12/16.
//  Copyright © 2016年 SelenaWong. All rights reserved.
//

#import "LSDTuiJianVC.h"

@interface LSDTuiJianVC ()

@end

@implementation LSDTuiJianVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"点击了%@",NSStringFromClass([self class]));
}

@end
