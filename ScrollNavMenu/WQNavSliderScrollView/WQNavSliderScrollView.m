//
//  WQNavSliderScrollView.m
//  DocumentaryChina
//
//  Created by fengwanqi on 14-7-24.
//  Copyright (c) 2014年 com.uwny. All rights reserved.
//
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]







#define MAINSCROLLCOLOR [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]

//标题
//标题滚动栏高度
static CGFloat const Title_SV_Height = 44;
//标题字号
#define TITLE_NORMAL_FONT [UIFont systemFontOfSize:14]
//标题颜色
#define TITLE_NORMAL_COLOR [UIColor blackColor]
//标题选中字号
#define TITLE_SELECTED_FONT [UIFont boldSystemFontOfSize:16]
//标题选中颜色
#define TITLE_SELECTED_COLOR [UIColor redColor]
//标题tag起始值
static NSInteger const Title_Tag_Start = 1000;

//分割线
//分割线图片名称(为1像素高度图片)
static NSString* const Split_Line_Img_Name = @"scrollMenuSplit";
//分割线高度
static CGFloat const Split_Line_Height = 2.0;

//下划线
//下划线颜色
#define UNDERLINED_COLOR TITLE_SELECTED_COLOR
//下划线高度
static CGFloat const Underlined_Height = 2.0;



#import "WQNavSliderScrollView.h"
//#import "UIColor+Dice.h"
#import "WQNavSliderButton.h"

@interface WQNavSliderScrollView()

@property (nonatomic, assign)id<WQNavSliderScrollViewDelegate> delegate;
@end

@implementation WQNavSliderScrollView
{
    UIScrollView *_titleSV;
    UIScrollView *_contentSV;
    NSArray *_titlesArray;
    
    UILabel *_underlinedLbl;
    UIButton *_selectedTitleBtn;
    
    //内容滚动栏当前偏移位置、用来确定滚动方向
    CGFloat _contentSVCurrentOffX;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    
        _contentSVCurrentOffX = 0.0;
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame TitlesArray:(NSArray *)titlesArray FirstView:(UIView *)firstView Delegate:(id<WQNavSliderScrollViewDelegate>)delegate
{
    self = [self initWithFrame:frame];
    if (self) {
        
        self.delegate = delegate;
        _titlesArray=titlesArray;
        _contentViewArray= [NSMutableArray arrayWithArray:titlesArray];
        
        //初始化标题滚动栏
        _titleSV=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, Title_SV_Height)];
        _titleSV.delegate = self;
        _titleSV.showsHorizontalScrollIndicator = NO;
        _titleSV.showsVerticalScrollIndicator = NO;
        _titleSV.pagingEnabled = NO;
        _titleSV.scrollEnabled = YES;
        _titleSV.backgroundColor=[UIColor yellowColor];
        [self addSubview:_titleSV];
        
        //标题、内容分割线
        UIImageView *splitLineIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleSV.frame), _titleSV.frame.size.width, Split_Line_Height)];
        splitLineIV.image = [UIImage imageNamed:Split_Line_Img_Name];
        [self addSubview:splitLineIV];
        
        //添加标题按钮
        float title_space = 10.0;    //标题间距
        float title_X = 0.0;    //标题x
        for (int i = 0 ; i < _titlesArray.count; i++)
        {
            //初始化
            WQNavSliderButton *button = [WQNavSliderButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = TITLE_NORMAL_FONT;
            [button setTitleColor:TITLE_NORMAL_COLOR forState:UIControlStateNormal];
            [button setTitleColor:TITLE_SELECTED_COLOR forState:UIControlStateSelected];
            NSString *title = [_titlesArray objectAtIndex:i];
            [button setTitle:title forState:UIControlStateNormal];
            button.tag = Title_Tag_Start+i;
            //根据标题长度分配长度
            float buttonHeight = CGRectGetHeight(_titleSV.frame);
            CGSize size = [title sizeWithFont:TITLE_SELECTED_FONT constrainedToSize:CGSizeMake(MAXFLOAT, buttonHeight) lineBreakMode:NSLineBreakByWordWrapping];
            button.frame = CGRectMake(title_space + title_X, 0, size.width, buttonHeight);
            [button addTarget:self action:@selector(titleClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_titleSV addSubview:button];
            title_X = CGRectGetMaxX(button.frame);
            
            //下划线
            if (i==0) {
                _underlinedLbl=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(button.frame), CGRectGetHeight(_titleSV.frame) - Underlined_Height, CGRectGetWidth(button.frame)+4, Underlined_Height)];
                _underlinedLbl.backgroundColor=UNDERLINED_COLOR;
                _underlinedLbl.center = CGPointMake(button.center.x, _underlinedLbl.center.y);
                button.selected=YES;
                _underlinedLbl.tag=button.tag+100;
                _selectedTitleBtn=button;
                _selectedTitleBtn.titleLabel.font = TITLE_SELECTED_FONT;
                [_titleSV addSubview:_underlinedLbl];
            }
        }
        //标题滚动栏内容size
        _titleSV.contentSize = CGSizeMake(title_X + title_space, 0.0);
        
        //内容滚动栏
        _contentSV=[[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(splitLineIV.frame), frame.size.width, frame.size.height - Title_SV_Height)];
        _contentSV.delegate = self;
        _contentSV.contentSize = CGSizeMake(self.bounds.size.width * titlesArray.count, 0);
        _contentSV.showsHorizontalScrollIndicator = NO;
        _contentSV.pagingEnabled = YES;
        [self addSubview:_contentSV];
        
        //首页设置
        UIView *view=firstView;
        view.frame=CGRectMake(0, 0, _contentSV.frame.size.width, _contentSV.frame.size.height);
        [_contentSV addSubview:view];
        [_contentViewArray replaceObjectAtIndex:0 withObject:view];
    }
    return self;
}
#pragma mark- ScrollView Delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==_contentSV) {
        _contentSVCurrentOffX = scrollView.contentOffset.x;
        
        int x = _contentSV.contentOffset.x/_contentSV.frame.size.width;
        WQNavSliderButton *titleBtn=(WQNavSliderButton *)[self viewWithTag:(x+Title_Tag_Start)];
        
        //内容view添加，如果未初始化初始化
        [self addCotentViewByIndex:x];
        
        [self updateTitleBtnCenter:titleBtn];
        
        [self changeTitleBtnState:titleBtn];
        
        [self scrollAtIndex:x];
        
        _underlinedLbl.frame=CGRectMake(CGRectGetMinX(titleBtn.frame), _underlinedLbl.frame.origin.y, CGRectGetWidth(titleBtn.frame), _underlinedLbl.frame.size.height);
        
//        [UIView animateWithDuration:0.4 animations:^{
//            
//            _underlinedLbl.tag=titleBtn.tag+100;
//        } completion:^(BOOL finished) {
//            _selectedTitleBtn.selected=NO;
//            _selectedTitleBtn.titleLabel.font = TITLE_NORMAL_FONT;
//            _selectedTitleBtn=titleBtn;
//            _selectedTitleBtn.titleLabel.font = TITLE_SELECTED_FONT;
//            titleBtn.selected=YES;
//            
//        }];
        
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger tag = 1;
    if (scrollView == _contentSV) {
        if (scrollView.contentOffset.x < _contentSVCurrentOffX) {
            //向左偏移
            tag = -1;
        }
        
    
        WQNavSliderButton *nextBtn = [_titleSV viewWithTag:_selectedTitleBtn.tag + tag];
        
        
        CGFloat w = (CGRectGetMaxX(nextBtn.frame) - CGRectGetMaxX(_selectedTitleBtn.frame)) / CGRectGetWidth(_titleSV.frame);
        CGFloat offX = scrollView.contentOffset.x * w;
        
        [self translateUnderlinedLblX:offX];
    }
}

#pragma mark- Private Function
//标题按钮点击执行方法
-(void)titleClicked:(WQNavSliderButton *)titleBtn
{
    if (titleBtn.tag==_underlinedLbl.tag-100) {
        //点击当前显示的
        return;
    }
    
    [self updateTitleBtnCenter:titleBtn];
    [self changeTitleBtnState:titleBtn];
    
    
    long x = titleBtn.tag-Title_Tag_Start;
    [self addCotentViewByIndex:x];
    [_contentSV setContentOffset:CGPointMake(_contentSV.frame.size.width*(titleBtn.tag-Title_Tag_Start), _contentSV.contentOffset.y) animated:YES];
    
    [self scrollAtIndex:(int)x];
}
//滚动时改变标题按钮状态
- (void)changeTitleBtnState:(WQNavSliderButton *)titleBtn {
    _underlinedLbl.tag=titleBtn.tag+100;
    _selectedTitleBtn.selected=NO;
    _selectedTitleBtn.titleLabel.font = TITLE_NORMAL_FONT;
    _selectedTitleBtn=titleBtn;
    _selectedTitleBtn.titleLabel.font = TITLE_SELECTED_FONT;
    titleBtn.selected=YES;
}
//滚动完成获取内容view
- (void)addCotentViewByIndex:(NSInteger)index {
    if (![_contentViewArray[index] isKindOfClass:[UIView class]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewByIndex:)]) {
            UIView *view = [self.delegate contentViewByIndex:(int)index];
            self.currentView = view;
            view.frame=CGRectMake(_contentSV.frame.size.width*index, 0, _contentSV.frame.size.width, _contentSV.frame.size.height);
            [_contentSV addSubview:view];
            [_contentViewArray replaceObjectAtIndex:index withObject:view];
        }
    }
}

//标题按钮跟着移动
-(void)updateTitleBtnCenter:(UIButton *)titleBtn {
    CGPoint point = [_titleSV convertPoint:titleBtn.center toView:_titleSV.superview];
    if (CGRectGetWidth(_titleSV.frame) / 2 > titleBtn.center.x) {
        [_titleSV setContentOffset:CGPointMake(0, 0) animated:YES];
    }else if ((_titleSV.contentSize.width - titleBtn.center.x) < CGRectGetWidth(_titleSV.frame) /2){
        [_titleSV setContentOffset:CGPointMake(_titleSV.contentSize.width - CGRectGetWidth(_titleSV.frame), _titleSV.contentOffset.y) animated:YES];
    }else {
        float space = point.x - CGRectGetWidth(_titleSV.superview.frame)/2;
        //float space = CGRectGetMinX(titleBtn.frame) - CGRectGetMinX(_selectedTitleBtn.frame);
        [_titleSV setContentOffset:CGPointMake(_titleSV.contentOffset.x+space, _titleSV.contentOffset.y) animated:YES];
    }
}
- (void)scrollAtIndex:(int)aIndex {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollAtIndex:)]) {
        [self.delegate scrollAtIndex:aIndex];
    }
}
-(void)scrollToIndex:(int)index {
//    [self titleClicked:_buttonArray[index]];
    [self translateUnderlinedLblX:_selectedTitleBtn.center.x - _underlinedLbl.center.x];
}

//下划线位移
- (void)translateUnderlinedLblX:(CGFloat)x {
    _underlinedLbl.transform =CGAffineTransformMakeTranslation(x, 0);
}
@end
