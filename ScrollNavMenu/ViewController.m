//
//  ViewController.m
//  ScrollNavMenu
//
//  Created by 冯万琦 on 2017/1/13.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import "ViewController.h"
#import "WQNavSliderScrollView.h"
#import "ContentViewController.h"

@interface ViewController ()<WQNavSliderScrollViewDelegate>
{
    NSArray* _titlesArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //导航栏透明会引起scrollview无故偏移问题
    self.navigationController.navigationBar.translucent = NO;
    _titlesArray = @[@"首页", @"推荐", @"国际", @"社会", @"故事汇", @"新闻哥", @"旅行攻略", @"美图", @"葛萨特"];
    CGSize size = [UIScreen mainScreen].bounds.size;
    WQNavSliderScrollView *scroll = [[WQNavSliderScrollView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) TitlesArray:_titlesArray FirstView:[self contentViewByIndex:0] Delegate:self];
    [self.view addSubview:scroll];
}

- (UIView *)contentViewByIndex:(int)index {
    ContentViewController *vc = [[ContentViewController alloc] initWithNibName:NSStringFromClass([ContentViewController class]) bundle:[NSBundle mainBundle]];
    vc.contentLbl.text = _titlesArray[index];
    [self addChildViewController:vc];
    return vc.view;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
