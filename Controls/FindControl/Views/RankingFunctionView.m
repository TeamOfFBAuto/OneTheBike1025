//
//  RankingFunctionView.m
//  OneTheBike
//
//  Created by soulnear on 14-10-20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "RankingFunctionView.h"

@implementation RankingFunctionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)layoutSubviews
{
    [self.today setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self.weekend setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self.month setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
    self.today.selected = YES;
    
    currentPage = 1;
    
    self.type_label.userInteractionEnabled = YES;
    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
    //[self.type_label addGestureRecognizer:tap];
    
    
}

-(void)doTap:(UITapGestureRecognizer *)sender
{
    UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0,30,100,50)];
    aView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:aView];
    NSArray * array = [NSArray arrayWithObjects:@"里程","时间",nil];
    
    for (int i = 0;i < 2;i++)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0,25*i,100,25);
        button.tag = 1000 + i;
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [aView addSubview:button];
    }
}



- (IBAction)todayTap:(id)sender
{
    NSLog(@"今天排行情况");
    
    self.today.selected = YES;
    self.weekend.selected = NO;
    self.month.selected = NO;
    
    ranking_view_block(1);
}

- (IBAction)weekendTap:(id)sender
{NSLog(@"本周排行情况");
    self.today.selected = NO;
    self.weekend.selected = YES;
    self.month.selected = NO;
    ranking_view_block(2);
}

- (IBAction)monthTap:(id)sender {
    NSLog(@"本月排行情况");
    self.today.selected = NO;
    self.weekend.selected = NO;
    self.month.selected = YES;
    ranking_view_block(3);
}

-(void)setRankingBlock:(RankingFunctionViewBlock)block
{
    ranking_view_block = block;
}


@end
