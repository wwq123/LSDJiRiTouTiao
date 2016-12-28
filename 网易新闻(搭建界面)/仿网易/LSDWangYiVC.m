//
//  LSDWangYiVC.m
//  网易新闻(搭建界面)
//
//  Created by SelenaWong on 16/12/16.
//  Copyright © 2016年 SelenaWong. All rights reserved.
//

#import "LSDWangYiVC.h"
#import "Marco.h"
#import "LSDListView.h"
#import "ChannelUnitModel.h"
#import "NSString+VC.h"


@interface LSDWangYiVC () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *topTitleScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
/**标题数组*/
@property (nonatomic, strong) NSMutableArray <NSString *>*titles;
/**子控制器数组*/
@property (nonatomic, strong) NSMutableArray <UIViewController *>*vcs;
/**标题按钮数组*/
@property (nonatomic, strong) NSMutableArray <UIButton *>*titleBtns;
/**当前点击的标题按钮*/
@property (nonatomic, strong) UIButton *currentSelectedTitleBtn;
/**记录contentScrollView当前滚动距离对应的角标*/
@property (nonatomic, assign) NSUInteger currentIndex;
/**遮罩*/
@property (nonatomic, strong) UIView *coverView;
/**当前选中的角标*/
@property (nonatomic, assign) NSUInteger chooseIndex;
/**设置标题按钮*/
@property (nonatomic, strong) UIButton *arrowBtn;
@property (nonatomic, strong) LSDListView *listView;
@property (nonatomic, strong) NSMutableArray<ChannelUnitModel *> *bottomChannelArr;
@property (nonatomic, strong) NSMutableArray<ChannelUnitModel *> *topChannelArr;
@end

@implementation LSDWangYiVC
- (void)viewDidLoad{
    [super viewDidLoad];
    //添加顶部标题ScrollView和内容ScrollView
    self.chooseIndex = 0;
    [self setUI];
}

- (void)setUI{
    UIScrollView *topTitleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,SelfViewWidth, TopTitleScrollViewHeight)];
    topTitleScrollView.showsVerticalScrollIndicator = NO;
    topTitleScrollView.showsHorizontalScrollIndicator = NO;
    topTitleScrollView.bounces = NO;
    [self.view addSubview:topTitleScrollView];
    self.topTitleScrollView = topTitleScrollView;
    
    UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, TopTitleScrollViewHeight,SelfViewWidth,SelfViewHeight - TopTitleScrollViewHeight)];
    contentScrollView.backgroundColor = [UIColor clearColor];
    contentScrollView.showsVerticalScrollIndicator = NO;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.bounces = NO;
    contentScrollView.pagingEnabled  = YES;
    contentScrollView.delegate = self;
    [self.view addSubview:contentScrollView];
    self.contentScrollView = contentScrollView;
    
    [self.view insertSubview:self.arrowBtn aboveSubview:self.topTitleScrollView];
}

- (void)setChildVCs:(NSArray<ChannelUnitModel *> *)childVCs{
    _childVCs = childVCs;
    for (int i=0; i<childVCs.count; i++) {
        ChannelUnitModel *model = childVCs[i];
        UIViewController *vc = model.vc;
        [self.vcs addObject:vc];
        [self.titles addObject:model.name];
    }
    //添加标题
    [self addTitles:self.titles];
    //添加标题对应的子控制器
    [self addChildVC:self.vcs];
}

- (void)addChildVC:(NSArray *)childVCArray{
    NSInteger count = childVCArray.count;
    for (int i=0; i<count; i++) {
        UIViewController *childVC = childVCArray[i];
        //只有添加了这句，才能实现添加的view的逻辑
        [self addChildViewController:childVC];
    }
    NSLog(@"childVCCount:%ld",self.childViewControllers.count);
    [self.contentScrollView setContentSize:CGSizeMake(SelfViewWidth *count, 0)];
}

- (void)addTitles:(NSArray *)titles{    
    NSInteger count = titles.count;
    [self.topTitleScrollView setContentSize:CGSizeMake(TitleBtnWidth *count, 0)];
    for (int i=0; i<count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100+i;
        btn.frame = CGRectMake(TitleBtnWidth *i, 0, TitleBtnWidth, TopTitleScrollViewHeight);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(titleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.topTitleScrollView addSubview:btn];
        [self.titleBtns addObject:btn];
        if (i == self.chooseIndex) {
            [self titleBtnAction:btn];
            [self addCover:btn];
        }
    }
    NSLog(@"titleScrollViewContentSize:%f",self.topTitleScrollView.contentSize.width);
}

- (void)titleBtnAction:(UIButton *)sender{
    if (sender == self.currentSelectedTitleBtn) {
        return;
    }
    NSLog(@"点击了%@",sender.currentTitle);
    //设置被点击标题的变化
    [self selectedBtn:sender];
    //切换标题对应的子控制器的view
    [self addChildVCViewWithIndex:sender.tag-100];
}
//设置标题按钮选中状态
- (void)selectedBtn:(UIButton *)sender{
    [self.currentSelectedTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self setTitleBtnMediate:sender];
    [self setBtnTitleScale:sender];
    [self addCover:sender];
    self.currentSelectedTitleBtn = sender;
    self.chooseIndex = sender.tag - 100;
    
}
//设置标题按钮点击居中
- (void)setTitleBtnMediate:(UIButton *)sender{
    CGFloat offset = sender.center.x - SelfViewWidth*0.5;
    if (offset <0) {
        offset = 0.f;
    }
    CGFloat maxOffset = self.topTitleScrollView.contentSize.width - SelfViewWidth;
    if (offset >=maxOffset) {
        offset = maxOffset;
    }
    [self.topTitleScrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

//按钮字体缩放
- (void)setBtnTitleScale:(UIButton *)sender{
    self.currentSelectedTitleBtn.transform = CGAffineTransformIdentity;
    sender.transform = CGAffineTransformMakeScale(MaxTitleScale, MaxTitleScale);
}

- (void)addCover:(UIButton *)sender{
   [UIView animateWithDuration:0.3f animations:^{
       self.coverView.center = sender.center;
       self.coverView.bounds = CGRectMake(0, 0, sender.frame.size.width/2.f, 30);
   } completion:^(BOOL finished) {
       if (self.coverView.superview) {
           return;
       }
       [self.topTitleScrollView insertSubview:self.coverView atIndex:0];
   }];
}

//添加对应子控制器的View
- (void)addChildVCViewWithIndex:(NSUInteger)index{
    UIViewController *childVC = self.vcs[index];
    CGFloat viewX = SelfViewWidth*index;
    if (childVC.view.superview) {//如果对应的子控件的View添加过了，就不需要再次添加了
        [self.contentScrollView setContentOffset:CGPointMake(viewX, 0)];
        return;
    }
    childVC.view.frame = CGRectMake(viewX, 0, SelfViewWidth, self.contentScrollView.bounds.size.height);
    [self.contentScrollView addSubview:childVC.view];
    [self.contentScrollView setContentOffset:CGPointMake(viewX, 0)];
}

#pragma mark - 点击设置标题按钮
- (void)arrowAction:(UIButton *)sender{
    LSDListView *listView = [[LSDListView alloc] initWithFrame:CGRectMake(0, 0, SelfViewWidth,UI_ScreenHeight) topDataSource:self.topChannelArr andBottomDataSource:self.bottomChannelArr andInitialIndex:self.chooseIndex];
    
    //编辑后的回调
    __weak LSDWangYiVC *weakSelf = self;
    listView.removeInitialIndexBlock = ^(NSMutableArray<ChannelUnitModel *> *topArr, NSMutableArray<ChannelUnitModel *> *bottomArr){
        weakSelf.topChannelArr = topArr;
        weakSelf.bottomChannelArr = bottomArr;
        NSLog(@"删除了初始选中项的回调:\n保留的频道有: %@", topArr);
        BOOL isDelEqual = [weakSelf.childVCs isEqual:topArr];
        if (!isDelEqual) {
            [weakSelf dataSourceIsChange:topArr];
        }
    };
    
    listView.chooseIndexBlock = ^(NSInteger index, NSMutableArray<ChannelUnitModel *> *topArr, NSMutableArray<ChannelUnitModel *> *bottomArr){
        NSLog(@"选中了某一项的回调:\n保留的频道有: %lu, 选中第%ld个频道", (unsigned long)topArr.count, index);

        weakSelf.topChannelArr = topArr;
        weakSelf.bottomChannelArr = bottomArr;
        //比较self.childVCs和topArr两个数组是否相等
        BOOL isEqual = [weakSelf.childVCs isEqualToArray:topArr];
        if (isEqual) {//相等，不做其他处理，只需要切换当前listView显示的对应的标题和view
            NSLog(@"相等");
            weakSelf.chooseIndex = index;
            UIButton *selectBtn = weakSelf.titleBtns[index];
            [weakSelf titleBtnAction:selectBtn];
        }else{
            NSLog(@"不相等");
            [weakSelf dataSourceIsChange:topArr];
            }
    };
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:listView];
    self.listView = listView;
}

//数据源发生变化需要做的事情
- (void)dataSourceIsChange:(NSMutableArray *)newDataSource{
    if (self.topTitleScrollView.subviews.count >0) {
        [self.topTitleScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if (self.contentScrollView.subviews.count >0) {
        [self.contentScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if (self.vcs.count >0) {
        [self.vcs removeAllObjects];
    }
    
    if (self.titles.count >0) {
        [self.titles removeAllObjects];
    }
    [self.titleBtns removeAllObjects];
    self.chooseIndex = newDataSource.count - 1;
    self.childVCs = newDataSource;

}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //滚动过程中标题字体放大,颜色渐变
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger leftIndex = offset/SelfViewWidth;
    NSInteger rightIndex = leftIndex + 1;
    UIButton *leftBtn = self.titleBtns[leftIndex];
    UIButton *rightBtn = nil;
    if (rightIndex <self.titleBtns.count) {
        rightBtn = self.titleBtns[rightIndex];
    }
    
    CGFloat scaleR = offset/SelfViewWidth - leftIndex;
    CGFloat scaleL = 1- scaleR;
    CGFloat transfrom = MaxTitleScale - 1;
    leftBtn.transform = CGAffineTransformMakeScale(scaleL*transfrom +1, scaleL*transfrom+1);
    rightBtn.transform = CGAffineTransformMakeScale(scaleR*transfrom+1, scaleR*transfrom+1);
    UIColor *rightColor = [UIColor colorWithRed:scaleR green:0 blue:0 alpha:1];
    UIColor *leftColor = [UIColor colorWithRed:scaleL green:0 blue:0 alpha:1];
    
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
    [rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSUInteger index = scrollView.contentOffset.x/SelfViewWidth + 0.5;
    if (index == self.currentIndex) {
        return;
    }
    UIButton *btn = self.titleBtns[index];
    [self selectedBtn:btn];
    [self addChildVCViewWithIndex:index];
    self.currentIndex = index;
}


#pragma mark - 懒加载
-(NSMutableArray<ChannelUnitModel *> *)bottomChannelArr{
    if (!_bottomChannelArr) {
        _bottomChannelArr = [NSMutableArray array];
        for (int i = 30; i < 50; ++i) {
            ChannelUnitModel *channelModel = [[ChannelUnitModel alloc] init];
            channelModel.name = [NSString stringWithFormat:@"标题%d", i];
            channelModel.cid = [NSString stringWithFormat:@"%d", i];
            channelModel.isTop = NO;
            channelModel.vc = [NSString vcWithTitle:channelModel.name];
            [_bottomChannelArr addObject:channelModel];
        }
        
    }
    return _bottomChannelArr;
}

- (NSMutableArray <ChannelUnitModel *> *)topChannelArr{
    if (_topChannelArr == nil) {
        _topChannelArr = [NSMutableArray arrayWithArray:self.childVCs];
    }
    return _topChannelArr;
}

- (NSMutableArray <NSString *>*)titles{
    if (_titles == nil) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

- (NSMutableArray <UIViewController *>*)vcs{
    if (_vcs == nil) {
        _vcs = [NSMutableArray array];
    }
    return _vcs;
}

- (NSMutableArray <UIButton *>*)titleBtns{
    if (_titleBtns == nil) {
        _titleBtns = [NSMutableArray array];
    }
    return _titleBtns;
}

- (UIView *)coverView{
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor lightGrayColor];
        _coverView.layer.cornerRadius = 15.f;
        _coverView.layer.masksToBounds = YES;
    }
    return _coverView;
}

- (UIButton *)arrowBtn{
    if (_arrowBtn == nil) {
        _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_arrowBtn setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        _arrowBtn.frame = CGRectMake(SelfViewWidth-TopTitleScrollViewHeight, 0, TopTitleScrollViewHeight, TopTitleScrollViewHeight);
        _arrowBtn.layer.shadowColor = [UIColor whiteColor].CGColor;
        _arrowBtn.layer.shadowRadius = 5.f;
        _arrowBtn.layer.shadowOpacity = 1;
        _arrowBtn.layer.shadowOffset = CGSizeMake(-10, 0);
        [_arrowBtn addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrowBtn;
}
@end
