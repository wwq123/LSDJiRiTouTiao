//
//  ChannelUnitModel.h
//  V1_Circle
//
//  Created by 刘瑞龙 on 15/11/10.
//  Copyright © 2015年 com.Dmeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChannelUnitModel : NSObject

@property (nonatomic, copy) NSString *cid;
/**标题*/
@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) BOOL isTop;
/**对应的控制器*/
@property (nonatomic, strong) UIViewController *vc;

@end
