//
//  LSDListView.h
//  网易新闻(搭建界面)
//
//  Created by SelenaWong on 16/12/19.
//  Copyright © 2016年 SelenaWong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChannelUnitModel;

typedef void(^ArrowBlock)();

@interface LSDListView : UIView
-(instancetype)initWithFrame:(CGRect)frame topDataSource:(NSArray<ChannelUnitModel *> *)topDataArr andBottomDataSource:(NSArray<ChannelUnitModel *> *)bottomDataSource andInitialIndex:(NSInteger)initialIndex;

/**
 * @b 编辑后, 删除初始选中项排序的回调
 */
@property (nonatomic, copy) void(^removeInitialIndexBlock)(NSMutableArray<ChannelUnitModel *> *topArr, NSMutableArray<ChannelUnitModel *> *bottomArr);

/**
 * @b 选中某一个频道回调
 */
@property (nonatomic, copy) void(^chooseIndexBlock)(NSInteger index, NSMutableArray<ChannelUnitModel *> *topArr, NSMutableArray<ChannelUnitModel *> *bottomArr);
@property (nonatomic, copy) ArrowBlock arrowBlock;
@end
