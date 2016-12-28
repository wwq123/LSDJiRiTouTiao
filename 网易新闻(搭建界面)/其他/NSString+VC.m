//
//  NSString+VC.m
//  网易新闻(搭建界面)
//
//  Created by SelenaWong on 16/12/21.
//  Copyright © 2016年 SelenaWong. All rights reserved.
//

#import "NSString+VC.h"
#import "LSDTopLineVC.h"
#import "LSDHotVC.h"
#import "LSDYuLeVC.h"
#import "LSDMingXingVC.h"
#import "LSDMovieVC.h"
#import "LSDTiYuVC.h"
#import "LSDDuanZiVC.h"
#import "LSDTuiJianVC.h"
#import "LSDJunShiVC.h"

@implementation NSString (VC)
+ (UIViewController *)vcWithTitle:(NSString *)title{
    UIViewController *vc;
    if ([title isEqualToString:@"推荐"]) {
        vc = [[LSDTuiJianVC alloc] init];
    }else if ([title isEqualToString:@"头条"]){
        vc = [[LSDTopLineVC alloc] init];
    }else if ([title isEqualToString:@"热点"]){
        vc = [[LSDHotVC alloc] init];
    }else if ([title isEqualToString:@"军事"]){
        vc = [[LSDJunShiVC alloc] init];
    }else if ([title isEqualToString:@"娱乐"]){
        vc = [[LSDYuLeVC alloc] init];
    }else if ([title isEqualToString:@"明星"]){
        vc = [[LSDMingXingVC alloc] init];
    }else if ([title isEqualToString:@"电影"]){
        vc = [[LSDMovieVC alloc] init];
    }else if ([title isEqualToString:@"体育"]){
        vc = [[LSDTiYuVC alloc] init];
    }else if ([title isEqualToString:@"段子"]){
        vc = [[LSDDuanZiVC alloc] init];
    }else{
        vc = [[UIViewController alloc] init];
    }
    return vc;
}
@end
