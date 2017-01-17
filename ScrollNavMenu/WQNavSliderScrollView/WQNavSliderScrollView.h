//
//  WQNavSliderScrollView.h
//  DocumentaryChina
//
//  Created by fengwanqi on 14-7-24.
//  Copyright (c) 2014年 com.uwny. All rights reserved.
//
#import <UIKit/UIKit.h>

//标题点击block
typedef void (^SlideBtnClickedBlock) (id sender);

@protocol WQNavSliderScrollViewDelegate <NSObject>
//返回每个显示view
@required
- (UIView *)contentViewByIndex:(int)index;
@optional
- (void)scrollAtIndex:(int)index;
@end


@interface WQNavSliderScrollView : UIView<UIScrollViewDelegate>
@property (nonatomic,copy)SlideBtnClickedBlock slideBtnClickedBlock;

@property (nonatomic, strong)NSMutableArray *contentViewArray;
@property (nonatomic, strong)UIView *currentView;

- (id)initWithFrame:(CGRect)frame TitlesArray:(NSArray *)titlesArray FirstView:(UIView *)firstView Delegate:(id <WQNavSliderScrollViewDelegate>)delegate;

@end
