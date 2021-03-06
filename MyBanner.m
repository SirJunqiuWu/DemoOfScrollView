//
//  MyBanner.m
//  MyBanner
//
//  Created by 蔡成汉 on 15/8/18.
//  Copyright (c) 2015年 蔡成汉. All rights reserved.
//

#import "MyBanner.h"
#import "MyPageControl.h"
#import "UIImageView+WebCache.h"

@interface MyBanner ()<UIScrollViewDelegate>
{
    /**
     *  banner数据源数组
     */
    NSMutableArray *dataArray;
    
    /**
     *  当前的scrollView加载的View
     */
    NSMutableArray *currentViews;
    
    /**
     *  底层scrollView
     */
    UIScrollView *myScrollView;
    
    /**
     *  pageControl
     */
    MyPageControl *myPageControl;
    
    /**
     *  当前页面 -- 默认为0
     */
    NSInteger currentPage;
    
    /**
     *  总页面数
     */
    NSInteger totalPage;
    
    /**
     *  计时器
     */
    NSTimer *timer;
}
@end

@implementation MyBanner

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        /**
         *  初始化dataArray
         */
        dataArray = [NSMutableArray array];
        
        /**
         *  初始化currentViews
         */
        currentViews = [NSMutableArray array];
        [self initiaMyBanner];
    }
    return self;
}

-(void)initiaMyBanner
{
    /**
     *  构建底层scrollView
     */
    myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    myScrollView.backgroundColor = [UIColor clearColor];
    myScrollView.showsHorizontalScrollIndicator = NO;
    myScrollView.showsVerticalScrollIndicator = NO;
    myScrollView.bounces = YES;
    myScrollView.pagingEnabled = YES;
    myScrollView.delegate = self;
    myScrollView.contentSize = CGSizeMake(self.frame.size.width*3, self.frame.size.height);
    myScrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    [self addSubview:myScrollView];
    
    /**
     *  构建pageControl
     */
    myPageControl = [[MyPageControl alloc]initWithFrame:CGRectMake(self.frame.size.width - 80, self.frame.size.height - 30, 80, 30)];
    myPageControl.backgroundColor = [UIColor clearColor];
    myPageControl.userInteractionEnabled = NO;
    myPageControl.pageIndicatorTintColor = [UIColor blueColor];
    myPageControl.currentPageIndicatorTintColor = [UIColor redColor];
    [self addSubview:myPageControl];
    
    /**
     *  默认当前页面
     */
    currentPage = 0;
}

/**
 *  对外方法，获取banner数据
 *
 *  @param array banner数据
 */
-(void)setMyBannerWithArray:(NSArray *)array
{
    [self setMyBannerWithArray:array isAuto:YES];
}

/**
 *  对外方法，获取banner数据
 *
 *  @param array  banner数据
 *  @param isAuto 是否自动执行滑动
 */
-(void)setMyBannerWithArray:(NSArray *)array isAuto:(BOOL)isAuto
{
    if (array != nil && array.count >0)
    {
        /**
         *  获取数据
         */
        [dataArray removeAllObjects];
        [dataArray addObjectsFromArray:array];
        
        totalPage = dataArray.count;
        myPageControl.numberOfPages = totalPage;
        
        /**
         *  加载数据
         */
        [self loadData];
        
        if (isAuto == YES)
        {
            /**
             *  计时器启动 -- 自动滑动
             */
            [self creatTimer];
        }
    }
}

/**
 *  加载数据
 */
-(void)loadData
{
    myPageControl.currentPage = currentPage;
    
    /**
     *  移除scrollView上所有的subView
     */
    NSArray *subViews = myScrollView.subviews;
    if (subViews.count >0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [currentViews removeAllObjects];
    [currentViews addObjectsFromArray:[self getDisplayViews:currentPage]];
    
    /**
     *  添加tap手势
     */
    for (int i = 0; i<3; i++)
    {
        UIView *tpView = [currentViews objectAtIndex:i];
        tpView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecognizer:)];
        [tpView addGestureRecognizer:tapGestureRecognizer];
        
        tpView.frame = CGRectOffset(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), self.frame.size.width*i, 0);
        [myScrollView addSubview:tpView];
    }
    
    /**
     *  scrollView滚动调整
     */
    myScrollView.contentOffset = CGPointMake(myScrollView.frame.size.width, 0);
}

/**
 *  获取当前的scrollView需要加载的View
 *
 *  @param page 当前的页码数
 *
 *  @return 需要加载的Views
 */
-(NSArray *)getDisplayViews:(NSInteger)page
{
    NSInteger pre = [self validPageValue:currentPage - 1];
    NSInteger last = [self validPageValue:currentPage + 1];
    
    NSMutableArray *tpArray = [NSMutableArray array];
    
    [tpArray addObject:[self creatViewWithIndex:pre]];
    [tpArray addObject:[self creatViewWithIndex:page]];
    [tpArray addObject:[self creatViewWithIndex:last]];
    
    return tpArray;
}

/**
 *  页面转换
 *
 *  @param value <#value description#>
 *
 *  @return <#return value description#>
 */
-(NSInteger)validPageValue:(NSInteger)value
{
    if (value == -1)
    {
        value = totalPage - 1;
    }
    else if (value == totalPage)
    {
        value = 0;
    }
    return value;
}

/**
 *  根据index构建一个目标View
 *
 *  @param index 目标页面的索引
 *
 *  @return 构建出来的目标View
 */
-(UIView *)creatViewWithIndex:(NSInteger)index
{
    UIImageView *tpImageView = [[UIImageView alloc]init];
    tpImageView.backgroundColor = [UIColor clearColor];
    tpImageView.contentMode = UIViewContentModeScaleAspectFill;
    tpImageView.clipsToBounds = YES;
    [tpImageView sd_setImageWithURL:[NSURL URLWithString:[dataArray objectAtIndex:index]] placeholderImage:nil];
    return tpImageView;
}

#pragma mark - 页面手势点击事件

-(void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"%ld",currentPage);
}

/**
 *  创建计时器并开始运行
 */
-(void)creatTimer
{
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refreshTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

/**
 *  计时器事件 -- 计时器图片逻辑处理
 */
-(void)refreshTimer
{
    [myScrollView setContentOffset:CGPointMake(self.frame.size.width*2, 0) animated:YES];
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger x = scrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*self.frame.size.width))
    {
        currentPage = [self validPageValue:currentPage+1];
        [self loadData];
    }
    
    //往上翻
    if(x <= 0)
    {
        currentPage = [self validPageValue:currentPage-1];
        [self loadData];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [myScrollView setContentOffset:CGPointMake(myScrollView.frame.size.width, 0) animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
