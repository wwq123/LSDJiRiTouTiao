//
//  LSDListView.m
//  网易新闻(搭建界面)
//
//  Created by SelenaWong on 16/12/19.
//  Copyright © 2016年 SelenaWong. All rights reserved.
//

#import "LSDListView.h"
#import "Marco.h"
#import "ChannelUnitModel.h"
#import "TouchView.h"

#define myChannelLabW 70
#define myChannelLabH 20
#define alertLabW 80
#define alertLabH 10
#define editBtnW 50
#define editBtnH 20
//左右边距
#define EdgeX 5
#define TopEdge 15
//每行频道的个数
#define ButtonCountOneRow 4
#define ButtonHeight (ButtonWidth * 4/9)
#define LocationWidth (ScreenWidth - EdgeX * 2)
#define ButtonWidth (LocationWidth/ButtonCountOneRow)
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define TitleSize 12.0
#define EditTextSize 9.0

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LSDListView ()
{
    BOOL _isEditing;
    CGPoint _oldCenter;
    NSInteger _moveIndex;
}
/**假导航栏*/
@property (nonatomic, strong) UIView *navView;
/**关闭按钮*/
@property (nonatomic, strong) UIButton *arrowBtn;
/**编辑按钮*/
@property (nonatomic, strong) UIButton *editBtn;
/**提示label*/
@property (nonatomic, strong) UILabel *alertLab;
/**我的频道Lab*/
@property (nonatomic, strong) UILabel *myChannelLab;
/**顶部内容View,封editBtn,alertLab,myChannelLab*/
@property (nonatomic, strong) UIView *topContentView;
/**频道推荐label*/
@property (nonatomic, strong) UILabel *bottomLabel;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<ChannelUnitModel *> *topDataSource;
@property (nonatomic, strong) NSMutableArray<ChannelUnitModel *> *bottomDataSource;
@property (nonatomic, assign) NSInteger locationIndex;
@property (nonatomic, strong) NSMutableArray<TouchView *> *topViewArr;
@property (nonatomic, strong) NSMutableArray<TouchView *> *bottomViewArr;
@property (nonatomic, strong) ChannelUnitModel *initialIndexModel;
@property (nonatomic, strong) TouchView *initalTouchView;
@property (nonatomic, assign) CGFloat topHeight;
@property (nonatomic, assign) CGFloat bottomHeight;
@property (nonatomic, strong) ChannelUnitModel *touchingModel;
@property (nonatomic, strong) ChannelUnitModel *placeHolderModel;
@property (nonatomic, strong) TouchView *clearView;
@end

@implementation LSDListView

-(instancetype)initWithFrame:(CGRect)frame topDataSource:(NSArray<ChannelUnitModel *> *)topDataArr andBottomDataSource:(NSArray<ChannelUnitModel *> *)bottomDataSource andInitialIndex:(NSInteger)initialIndex{
    if (self == [super initWithFrame:frame]) {
        self.topDataSource = [NSMutableArray arrayWithArray:topDataArr];
        self.bottomDataSource = [NSMutableArray arrayWithArray:bottomDataSource];
        self.locationIndex = initialIndex;
        [self setUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.navView.frame = CGRectMake(0, 0, width, NavViewHeight);
    self.arrowBtn.frame = CGRectMake(width - ArrowBtnHeight,20 + (NavViewHeight - ArrowBtnHeight-20)/2.f, ArrowBtnHeight, ArrowBtnHeight);
    
    self.topContentView.frame = CGRectMake(0, CGRectGetMaxY(self.navView.frame), width, TopTitleScrollViewHeight);
    self.myChannelLab.frame = CGRectMake(Margin,(self.topContentView.frame.size.height - myChannelLabH)/2, myChannelLabW, myChannelLabH);
    self.alertLab.frame = CGRectMake(CGRectGetMaxX(self.myChannelLab.frame) + Margin/2, (self.topContentView.frame.size.height - alertLabH)/2, alertLabW, alertLabH);
    self.editBtn.frame = CGRectMake(width-Margin-editBtnW, (self.topContentView.frame.size.height - editBtnH)/2, editBtnW, editBtnH);
    self.editBtn.layer.cornerRadius = 10.f;
    self.editBtn.layer.masksToBounds = YES;
    
    self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.topContentView.frame), width,height-CGRectGetMaxY(self.topContentView.frame));
}

- (void)setUI{
    //添加顶部假导航栏
    [self.navView addSubview:self.arrowBtn];
    [self addSubview:self.navView];
    
    //添加顶部编辑按钮view
    [self.topContentView addSubview:self.myChannelLab];
    [self.topContentView addSubview:self.alertLab];
    [self.topContentView addSubview:self.editBtn];
    [self addSubview:self.topContentView];
   
    [self addSubview:self.scrollView];
    
    [self addChannel];
}

- (void)addChannel{
    //添加我的频道分类的所有频道
    for (int i = 0; i < self.topDataSource.count; ++i) {
        TouchView *touchView = [[TouchView alloc] initWithFrame:CGRectMake(5 + i%ButtonCountOneRow * ButtonWidth, TopEdge + i/ButtonCountOneRow * ButtonHeight, ButtonWidth, ButtonHeight)];
        touchView.userInteractionEnabled = YES;
        
        ChannelUnitModel *model = self.topDataSource[i];
        touchView.contentLabel.text = model.name;
        if (i < 1) { //位于前一个的频道不添加任何手势, 并且文字颜色为灰色
            touchView.contentLabel.textColor = [UIColor lightGrayColor];
            touchView.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(defaultTopTap:)];
            [touchView addGestureRecognizer:touchView.tap];
        }else{
            touchView.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topTapAct:)];
            [touchView addGestureRecognizer:touchView.tap];
            
            touchView.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topPanAct:)];
            touchView.pan.enabled = NO;
            [touchView addGestureRecognizer:touchView.pan];
            
            touchView.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAct:)];
            [touchView addGestureRecognizer:touchView.longPress];
        }
        
        if (self.locationIndex == i) { //蓝色 //008dff
            touchView.contentLabel.textColor = [UIColor redColor];
            self.initialIndexModel = self.topDataSource[i];
            self.initalTouchView = touchView;
        }
        
        [self.scrollView addSubview:touchView];
        [self.topViewArr addObject:touchView];
    }
    //添加频道推荐label
    [self.scrollView addSubview:self.bottomLabel];
    self.bottomLabel.frame = CGRectMake(Margin,TopEdge + 25 + self.topHeight, 150, 20);
    CGFloat startHeight = self.bottomLabel.frame.origin.y + 20 + 10;
    //添加频道推荐分类的所有频道
    for (int i = 0; i < self.bottomDataSource.count; ++i) {
        TouchView *touchView = [[TouchView alloc] initWithFrame:CGRectMake(EdgeX + i%ButtonCountOneRow * ButtonWidth, startHeight + i/ButtonCountOneRow * ButtonHeight, ButtonWidth, ButtonHeight)];
        ChannelUnitModel *model = self.bottomDataSource[i];
        touchView.contentLabel.text = model.name;
        touchView.userInteractionEnabled = YES;
        touchView.contentLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:touchView];
        [self.bottomViewArr addObject:touchView];
        
        touchView.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomTapAct:)];
        [touchView addGestureRecognizer:touchView.tap];
    }
    self.scrollView.contentSize = CGSizeMake(ScreenWidth, 85 + self.topHeight + self.bottomHeight + ButtonHeight);
}

#pragma mark - 重新布局下边
-(void)reconfigBottomView{
    CGFloat startHeight = self.bottomLabel.frame.origin.y + 20 + 10;
    for (int i = 0; i < self.bottomViewArr.count; ++i) {
        TouchView *touchView = self.bottomViewArr[i];
        touchView.frame = CGRectMake(EdgeX + i%ButtonCountOneRow * ButtonWidth, startHeight + i/ButtonCountOneRow * ButtonHeight, ButtonWidth, ButtonHeight);
    }
}
#pragma mark - 重新布局上边
-(void)reconfigTopView{
    for (int i = 0; i < self.topViewArr.count; ++i) {
        TouchView *touchView = self.topViewArr[i];
        touchView.frame = CGRectMake(EdgeX + i%ButtonCountOneRow * ButtonWidth, TopEdge + i/ButtonCountOneRow*ButtonHeight, ButtonWidth, ButtonHeight);
    }
}

#pragma mark - 从上到下
-(void)topTapAct:(UITapGestureRecognizer *)tap{
    TouchView *touchView = (TouchView *)tap.view;
    NSInteger index = [self.topViewArr indexOfObject:touchView];
    if (_isEditing) {
        [self.scrollView bringSubviewToFront:touchView];
        //获取点击view的位置
        [self.bottomViewArr insertObject:touchView atIndex:0];
        [self.topViewArr removeObject:touchView];
        //为了安全, 加判断
        if (index < self.topDataSource.count) {
            ChannelUnitModel *cModel = self.topDataSource[index];
            cModel.isTop = NO;
            [self.bottomDataSource insertObject:cModel atIndex:0];
            [self.topDataSource removeObjectAtIndex:index];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomLabel.frame = CGRectMake(Margin, TopEdge + 25 + self.topHeight, 200, 20);
            [self reconfigTopView];
            [self reconfigBottomView];
            touchView.closeImageView.hidden = YES;
        }];
        
        [touchView.pan removeTarget:self action:@selector(topPanAct:)];
        [touchView removeGestureRecognizer:touchView.pan];
        touchView.pan = nil;
        
        [touchView.longPress removeTarget:self action:@selector(longTapAct:)];
        [touchView removeGestureRecognizer:touchView.longPress];
        touchView.longPress = nil;
        
        [touchView.tap removeTarget:self action:@selector(topTapAct:)];
        [touchView.tap addTarget:self action:@selector(bottomTapAct:)];
    }else{
        [self returnToHomeWithIndex:index];
    }
}
#pragma mark - 点击上边前两个按钮
-(void)defaultTopTap:(UITapGestureRecognizer *)tap{
    if (!_isEditing) {
        TouchView *touchView = (TouchView *)tap.view;
        NSInteger index = [self.topViewArr indexOfObject:touchView];
        [self returnToHomeWithIndex:index];
    }
}
#pragma mark - 返回到home页面, 带有点击的某个index
-(void)returnToHomeWithIndex:(NSInteger)index{
    if (self.chooseIndexBlock) {
        self.chooseIndexBlock(index, self.topDataSource, self.bottomDataSource);
    }
    [UIView animateWithDuration:1.f animations:^{
        if (self.superview) {
            [self removeFromSuperview];
        }
    } completion:^(BOOL finished) {
        [self updateTOsql];
    }];

}
#pragma mark - 从下到上
-(void)bottomTapAct:(UITapGestureRecognizer *)tap{
    TouchView *touchView = (TouchView *)tap.view;
    [self.scrollView bringSubviewToFront:touchView];
    NSInteger index = [self.bottomViewArr indexOfObject:touchView];
    [self.topViewArr addObject:touchView];
    [self.bottomViewArr removeObject:touchView];
    //为了安全, 加判断
    if (index < self.bottomDataSource.count) {
        ChannelUnitModel *model = self.bottomDataSource[index];
        model.isTop = YES;
        if (model == self.initialIndexModel) {
            if (_isEditing) {
            }else{
                touchView.contentLabel.textColor = [UIColor redColor];
            }
        }
        [self.topDataSource addObject:model];
        [self.bottomDataSource removeObject:model];
    }
    
    NSInteger i = self.topViewArr.count - 1;
    [UIView animateWithDuration:0.3 animations:^{
        touchView.frame = CGRectMake(EdgeX + i%ButtonCountOneRow * ButtonWidth, TopEdge + i/ButtonCountOneRow*ButtonHeight, ButtonWidth, ButtonHeight);
        self.bottomLabel.frame = CGRectMake(Margin, TopEdge + 25 + self.topHeight, 200, 20);
        [self reconfigBottomView];
        touchView.closeImageView.hidden = !_isEditing;
    }];
    
    touchView.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topPanAct:)];
    [touchView addGestureRecognizer:touchView.pan];
    touchView.pan.enabled = _isEditing;
    
    touchView.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAct:)];
    [touchView addGestureRecognizer:touchView.longPress];
    
    [touchView.tap removeTarget:self action:@selector(bottomTapAct:)];
    [touchView.tap addTarget:self action:@selector(topTapAct:)];
}

#pragma mark - 拖拽手势
-(void)topPanAct:(UIPanGestureRecognizer *)pan{
    TouchView *touchView = (TouchView *)pan.view;
    [self.scrollView  bringSubviewToFront:touchView];
    static int staticIndex = 0;
    if (pan.state == UIGestureRecognizerStateBegan) {
        [touchView inOrOutTouching:YES];
        //记录移动的label最初的index
        _moveIndex = [self.topViewArr indexOfObject:touchView];
        if (_moveIndex < self.topDataSource.count) {
            self.touchingModel = self.topDataSource[_moveIndex];
        }
        [self.topViewArr removeObject:touchView];
        if (self.touchingModel) {
            [self.topDataSource removeObject:self.touchingModel];
            [self.topDataSource addObject:self.placeHolderModel];
        }
        _oldCenter = touchView.center;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        CGPoint movePoint = [pan translationInView:self.scrollView];
        touchView.center = CGPointMake(_oldCenter.x + movePoint.x, _oldCenter.y + movePoint.y);
        CGFloat x = touchView.center.x;
        CGFloat y = touchView.center.y;
        //没有超出范围
        if (!(x < EdgeX || x > ScreenWidth - EdgeX || y < TopEdge || y > TopEdge + self.topHeight  || (y < (TopEdge + ButtonHeight) && x < (EdgeX + 2 * ButtonWidth)))) {
            //记录移动过程中label所处的index
            int index = ((int)((y - TopEdge)/ButtonHeight)) * ButtonCountOneRow + (int)(x - EdgeX)/ButtonWidth;
            //当index发生改变时, 插入占位的label, 重新布局UI
            if (staticIndex !=index) {
                staticIndex = index;
                if (staticIndex < self.topViewArr.count && staticIndex >= 0) {
                    if ([self.topViewArr containsObject:self.clearView]) {
                        [self.topViewArr removeObject:self.clearView];
                    }
                    [self.topViewArr insertObject:self.clearView atIndex:staticIndex];
                    if (!self.clearView.superview) {
                        [self.scrollView addSubview:self.clearView];
                        [self.scrollView sendSubviewToBack:self.clearView];
                    }
                    self.clearView.frame = CGRectMake(EdgeX + staticIndex%ButtonCountOneRow * ButtonWidth, TopEdge + staticIndex/ButtonCountOneRow*ButtonHeight, ButtonWidth, ButtonHeight);
                    [UIView animateWithDuration:0.5 animations:^{
                        [self reconfigTopView];
                    }];
                }else{
                }
            }
        }
    }else if(pan.state == UIGestureRecognizerStateEnded){
        [touchView inOrOutTouching:NO];
        CGFloat x = touchView.center.x;
        CGFloat y = touchView.center.y;
        if (x < EdgeX || x > ScreenWidth - EdgeX || y < TopEdge || y > TopEdge + self.topHeight || (y < (TopEdge + ButtonHeight) && x < (EdgeX + 2 * ButtonWidth))) {
            NSLog(@"超出范围");
            [UIView animateWithDuration:0.5 animations:^{
                touchView.center = _oldCenter;
            }];
        }else{
            _moveIndex = ((int)((y - TopEdge)/ButtonHeight)) * ButtonCountOneRow + (int)(x - EdgeX)/ButtonWidth;
        }
        staticIndex = 0;
        if ([self.topViewArr containsObject:self.clearView]) {
            [self.topViewArr removeObject:self.clearView];
            if (self.clearView.superview) {
                [self.clearView removeFromSuperview];
            }
        }
        if ([self.topDataSource containsObject:self.placeHolderModel]) {
            [self.topDataSource removeObject:self.placeHolderModel];
        }
        if (_moveIndex < self.topViewArr.count && _moveIndex >= 0 ) {
            [self.topViewArr insertObject:touchView atIndex:_moveIndex];
            if (_moveIndex < self.topDataSource.count && self.touchingModel) {
                [self.topDataSource insertObject:self.touchingModel atIndex:_moveIndex];
            }
        }else{
            [self.topViewArr addObject:touchView];
            if (self.touchingModel) {
                [self.topDataSource removeObject:self.placeHolderModel];
                [self.topDataSource addObject:self.touchingModel];
            }
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self reconfigTopView];
        }];
    }else if(pan.state == UIGestureRecognizerStateCancelled){
    }else if(pan.state == UIGestureRecognizerStateFailed){
    }
}
#pragma mark - 长按手势
-(void)longTapAct:(UILongPressGestureRecognizer *)longPress{
    TouchView *touchView = (TouchView *)longPress.view;
    [self.scrollView bringSubviewToFront:touchView];
    static CGPoint touchPoint;
    static CGFloat offsetX;
    static CGFloat offsetY;
    static NSInteger staticIndex = 0;
    if (longPress.state == UIGestureRecognizerStateBegan) {
        _isEditing = YES;
        [touchView inOrOutTouching:YES];
        [self inOrOutEditWithEditing:_isEditing];
        //记录移动的label最初的index
        _moveIndex = [self.topViewArr indexOfObject:touchView];
        if (_moveIndex < self.topDataSource.count) {
            self.touchingModel = self.topDataSource[_moveIndex];
        }
        [self.topViewArr removeObject:touchView];
        if (self.touchingModel) {
            [self.topDataSource removeObject:self.touchingModel];
            [self.topDataSource addObject:self.placeHolderModel];
        }
        _oldCenter = touchView.center;
        
        //这是为了计算手指在Label上的偏移位置
        touchPoint = [longPress locationInView:touchView];
        CGPoint centerPoint = CGPointMake(ButtonWidth/2, ButtonHeight/2);
        offsetX = touchPoint.x - centerPoint.x;
        offsetY = touchPoint.y - centerPoint.y;
        
        CGPoint movePoint = [longPress locationInView:self.scrollView];
        [UIView animateWithDuration:0.1 animations:^{
            touchView.center = CGPointMake(movePoint.x - offsetX, movePoint.y - offsetY);
        }];
    }else if(longPress.state == UIGestureRecognizerStateChanged){
        CGPoint movePoint = [longPress locationInView:self.scrollView];
        touchView.center = CGPointMake(movePoint.x - offsetX, movePoint.y - offsetY);
        
        CGFloat x = touchView.center.x;
        CGFloat y = touchView.center.y;
        //没有超出范围
        if (!(x < EdgeX || x > ScreenWidth - EdgeX || y < TopEdge || y > TopEdge + self.topHeight || (y < (TopEdge + ButtonHeight) && x < (EdgeX + 2 * ButtonWidth)))) {
            //记录移动过程中label所处的index
            int index = ((int)((y - TopEdge)/ButtonHeight)) * ButtonCountOneRow + (int)(x - EdgeX)/ButtonWidth;
            
            //当index发生改变时, 插入占位的label, 重新布局UI
            if (staticIndex !=index) {
                staticIndex = index;
                if (staticIndex < self.topViewArr.count && staticIndex >= 0) {
                    if ([self.topViewArr containsObject:self.clearView]) {
                        [self.topViewArr removeObject:self.clearView];
                    }
                    [self.topViewArr insertObject:self.clearView atIndex:staticIndex];
                    if (!self.clearView.superview) {
                        [self.scrollView addSubview:self.clearView];
                        [self.scrollView sendSubviewToBack:self.clearView];
                    }
                    self.clearView.frame = CGRectMake(EdgeX + staticIndex%ButtonCountOneRow * ButtonWidth, TopEdge + staticIndex/ButtonCountOneRow*ButtonHeight, ButtonWidth, ButtonHeight);
                    [UIView animateWithDuration:0.5 animations:^{
                        [self reconfigTopView];
                    }];
                }else{
                    NSLog(@"计算index 超出范围");
                }
            }
        }
    }else if(longPress.state == UIGestureRecognizerStateEnded){
        [touchView inOrOutTouching:NO];
        CGFloat x = touchView.center.x;
        CGFloat y = touchView.center.y;
        if (x < EdgeX || x > ScreenWidth - EdgeX || y < TopEdge || y > TopEdge + self.topHeight || (y < (TopEdge + ButtonHeight) && x < (EdgeX + 2 * ButtonWidth))) {
            NSLog(@"长按手势结束: 超出范围");
            [UIView animateWithDuration:0.5 animations:^{
                touchView.center = _oldCenter;
            }];
        }else{
            _moveIndex = ((int)((y - TopEdge)/ButtonHeight)) * ButtonCountOneRow + (int)(x - EdgeX)/ButtonWidth;
        }
        staticIndex = 0;
        if ([self.topViewArr containsObject:self.clearView]) {
            [self.topViewArr removeObject:self.clearView];
            if (self.clearView.superview) {
                [self.clearView removeFromSuperview];
            }
        }
        if ([self.topDataSource containsObject:self.placeHolderModel]) {
            [self.topDataSource removeObject:self.placeHolderModel];
        }
        if (_moveIndex < self.topViewArr.count && _moveIndex >= 0) {
            [self.topViewArr insertObject:touchView atIndex:_moveIndex];
            if (_moveIndex < self.topDataSource.count && self.touchingModel) {
                [self.topDataSource insertObject:self.touchingModel atIndex:_moveIndex];
            }
        }else{
            [self.topViewArr addObject:touchView];
            if (self.touchingModel) {
                [self.topDataSource addObject:self.touchingModel];
            }
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self reconfigTopView];
        }];
    }else if(longPress.state == UIGestureRecognizerStateCancelled){
    }else if(longPress.state == UIGestureRecognizerStateFailed){
    }
}

#pragma mark - 充当计算属性使用
-(CGFloat)topHeight{
    if (self.topDataSource.count < ButtonCountOneRow) {
        return ButtonHeight;
    }else{
        return ((self.topDataSource.count - 1)/ButtonCountOneRow + 1) * ButtonHeight;
    }
}
-(CGFloat)bottomHeight{
    if (self.bottomDataSource.count < ButtonCountOneRow) {
        return ButtonHeight;
    }else{
        return ((self.bottomDataSource.count - 1)/ButtonCountOneRow + 1) * ButtonHeight;;
    }
}
#pragma mark - 点击编辑或者完成按钮
-(void)editOrderAct:(UIButton *)button{
    _isEditing = !_isEditing;
    [self inOrOutEditWithEditing:_isEditing];
    if (!_isEditing) { //点击完成
    }
}
#pragma mark - 进入或者退出编辑状态
-(void)inOrOutEditWithEditing:(BOOL)isEditing{
    if (isEditing) {
        [self.editBtn setTitle:@"完成" forState:UIControlStateNormal];
        
        if (self.initalTouchView) {
            if (self.locationIndex > 1) {
                self.initalTouchView.contentLabel.textColor = UIColorFromRGB(0X333333);
            }else{
                self.initalTouchView.contentLabel.textColor = UIColorFromRGB(0xc0c0c0);
            }
        }
        
        self.alertLab.hidden = NO;
        for (int i = 0; i < self.topViewArr.count; ++i) {
            TouchView *touchView = self.topViewArr[i];
            if (touchView.pan) {
                touchView.pan.enabled = YES;
                touchView.closeImageView.hidden = NO;
            }
        }
    }else{
        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        if (self.initalTouchView && self.initialIndexModel.isTop) {
            self.initalTouchView.contentLabel.textColor = [UIColor redColor];
        }
        self.alertLab.hidden = YES;
        for (int i = 0; i < self.topViewArr.count; ++i) {
            TouchView *touchView = self.topViewArr[i];
            if (touchView.pan) {
                touchView.pan.enabled = NO;
                touchView.closeImageView.hidden = YES;
            }
        }
    }
}

#pragma mark - 预留的同步到本地的方法
-(void)updateTOsql{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.topDataSource];
    [arr addObjectsFromArray:self.bottomDataSource];
}

#pragma mark - 点击关闭按钮
- (IBAction)arrowListViewAction:(id)sender {
    if (self.initialIndexModel && self.initialIndexModel.isTop) {
        if ([self.topDataSource containsObject:self.initialIndexModel]) {
            if (self.chooseIndexBlock) {
                self.chooseIndexBlock([self.topDataSource indexOfObject:self.initialIndexModel], self.topDataSource, self.bottomDataSource);
            }
        }
    }else{
        if (self.removeInitialIndexBlock) {
            self.removeInitialIndexBlock(self.topDataSource, self.bottomDataSource);
        }
    }
    [UIView animateWithDuration:1.f animations:^{
        if (self.superview) {
            [self removeFromSuperview];
        }
    } completion:^(BOOL finished) {
        [self updateTOsql];

    }];
}

- (UIView *)navView{
    if (_navView == nil) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = LSDDefalutBgColor;
    }
    return _navView;
}
- (UIButton *)arrowBtn{
    if (_arrowBtn == nil) {
        _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_arrowBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_arrowBtn addTarget:self action:@selector(arrowListViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrowBtn;
}

- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = LSDDefalutBgColor;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UILabel *)alertLab{
    if (_alertLab == nil) {
        _alertLab = [[UILabel alloc] init];
        _alertLab.text = @"拖拽可以排序";
        _alertLab.textColor = [UIColor lightGrayColor];
        _alertLab.textAlignment = NSTextAlignmentLeft;
        _alertLab.font = [UIFont systemFontOfSize:13.f];
        _alertLab.hidden = YES;
    }
    return _alertLab;
}

- (UILabel *)myChannelLab{
    if (_myChannelLab == nil) {
        _myChannelLab = [[UILabel alloc] init];
        _myChannelLab.text = @"我的频道";
        _myChannelLab.textColor = [UIColor blackColor];
        _myChannelLab.textAlignment = NSTextAlignmentLeft;
        _myChannelLab.font = [UIFont systemFontOfSize:16.f];
    }
    return _myChannelLab;
}

- (UILabel *)bottomLabel{
    if (_bottomLabel == nil) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.text = @"频道推荐";
        _bottomLabel.textColor = [UIColor blackColor];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return _bottomLabel;
}

- (UIButton *)editBtn{
    if (_editBtn == nil) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_editBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        _editBtn.layer.borderColor = [UIColor redColor].CGColor;
        _editBtn.layer.borderWidth = 1.f;
        [_editBtn addTarget:self action:@selector(editOrderAct:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

- (UIView *)topContentView{
    if (_topContentView == nil) {
        _topContentView = [[UIView alloc] init];
        _topContentView.backgroundColor = LSDDefalutBgColor;
    }
    return _topContentView;
}

- (NSMutableArray <TouchView *>*)topViewArr{
    if (_topViewArr == nil) {
        _topViewArr = [NSMutableArray array];
    }
    return _topViewArr;
}

- (NSMutableArray <TouchView *>*)bottomViewArr{
    if (_bottomViewArr == nil) {
        _bottomViewArr = [NSMutableArray array];
    }
    return _bottomViewArr;
}

#pragma mark - 用于占位的model, 由于计算位置有问题
-(ChannelUnitModel *)placeHolderModel{
    if (!_placeHolderModel) {
        _placeHolderModel = [[ChannelUnitModel alloc] init];
    }
    return _placeHolderModel;
}

#pragma mark - 用于占位的透明label
-(TouchView *)clearView{
    if (!_clearView) {
        _clearView = [[TouchView alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, ButtonWidth - 10, ButtonHeight - 10)];
        imageView.image = [UIImage imageNamed:@"lanmu2"];
        [_clearView addSubview:imageView];
        _clearView.backgroundColor = [UIColor clearColor];
        [_clearView.contentLabel removeFromSuperview];
    }
    return _clearView;
}
@end

