//
//  LSDWangYiVC.h
//  网易新闻(搭建界面)
//
//  Created by SelenaWong on 16/12/16.
//  Copyright © 2016年 SelenaWong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChannelUnitModel;
@interface LSDWangYiVC : UIViewController
/*需添加的子控制器数组*/
@property (nonatomic, strong) NSArray <ChannelUnitModel *>*childVCs;
@end
