//
//  ViewController.m
//  网易新闻(搭建界面)
//
//  Created by SelenaWong on 16/12/16.
//  Copyright © 2016年 SelenaWong. All rights reserved.
//

#import "ViewController.h"
#import "LSDWangYiVC.h"
#import "LSDTuiJianVC.h"
#import "LSDTopLineVC.h"
#import "LSDHotVC.h"
#import "LSDJunShiVC.h"
#import "LSDYuLeVC.h"
#import "LSDMingXingVC.h"
#import "LSDMovieVC.h"
#import "LSDTiYuVC.h"
#import "LSDDuanZiVC.h"
#import "LSDConst.h"
#import "ChannelUnitModel.h"
#import "NSString+VC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"网易新闻";
    LSDWangYiVC *wyVC = [[LSDWangYiVC alloc] init];
    wyVC.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    NSArray *titles = @[@"推荐",@"头条",@"热点",@"军事",@"娱乐",@"明星",@"电影",@"体育",@"段子"];
    wyVC.childVCs = [[self channelsWithTitles:titles] copy];
    [self.view addSubview:wyVC.view];
    [self addChildViewController:wyVC];
}

- (NSMutableArray *)channelsWithTitles:(NSArray <NSString *> *)titles{
    NSMutableArray *channels = [NSMutableArray array];
    for (int i=0;i<titles.count;i++) {
        NSString *title = titles[i];
        ChannelUnitModel *model = [[ChannelUnitModel alloc] init];
        model.name = title;
        model.cid = [NSString stringWithFormat:@"%d",i];
        model.vc = [NSString vcWithTitle:title];
        model.isTop = YES;
        [channels addObject:model];
    }
    return channels;
}


@end
