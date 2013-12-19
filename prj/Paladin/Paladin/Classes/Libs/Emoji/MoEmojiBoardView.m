//
//  MoEmojiBoardView.m
//  Paladin
//
//  Created by ku ying on 13-12-20.
//  Copyright (c) 2013年 库颖. All rights reserved.
//

#import "MoEmojiBoardView.h"

@interface MoEmojiBoardView() <UIScrollViewDelegate> {
    NSArray *emoji_faces;
    
    UIScrollView *scrollView;
    UIPageControl *pageControl;
}

@end

@implementation MoEmojiBoardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self loadEmojiFaces];
        
        [self initSubViewsWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
    }
    return self;
}

- (void)loadEmojiFaces
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"]];
    
    NSError *error;
    id emoji = [NSJSONSerialization JSONObjectWithData:data
                                               options:NSJSONReadingAllowFragments
                                                 error:&error];
    if ([emoji isKindOfClass:[NSArray class]]) {
        emoji_faces = emoji;
    }
    else {
        NSLog(@"load emoji face file fail");
    }
}

- (void)initSubViewsWithFrame:(CGRect)frame
{
    const static CGFloat PAGCONTROL_HEIGHT = 30;
    const static CGFloat PAGCONTROL_POS_Y = 120;
    const static CGFloat EMOJI_WIDTH = 33;
    const static CGFloat EMOJI_HEIGHT = 33;
    const static NSInteger EMOJI_COL = 9;
    const static NSInteger EMOJI_ROW = 3;
    
    // init scroll view
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - PAGCONTROL_POS_Y)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    
    NSInteger emoji_num = emoji_faces.count;
    NSInteger emoji_num_in_page = EMOJI_COL * EMOJI_ROW - 1;
    NSInteger emoji_pages = emoji_num / emoji_num_in_page + 1;
    for (int i = 0; i < emoji_num; i++) {
        NSInteger page_idx = i / emoji_num_in_page;
        NSInteger row_idx = i % emoji_num_in_page / EMOJI_COL;
        NSInteger col_idx = 1 % emoji_num_in_page % EMOJI_COL;
        
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(frame.size.width * page_idx + col_idx * EMOJI_WIDTH, row_idx * EMOJI_HEIGHT, EMOJI_WIDTH, EMOJI_HEIGHT)];
        [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
        [button setTitle:emoji_faces[i] forState:UIControlStateNormal];
        button.tag = i;
        
        [button addTarget:self action:@selector(selectEmoji:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
    }
    
    for (int i = 0; i < emoji_pages; i++) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(frame.size.width * i + (EMOJI_COL - 1) * EMOJI_WIDTH, (EMOJI_ROW - 1) * EMOJI_HEIGHT, EMOJI_WIDTH, EMOJI_HEIGHT)];
        [button setImage:[UIImage imageNamed:@"ic_face_delete"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteEmoji:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
    }

    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    scrollView.contentSize = CGSizeMake(frame.size.width * emoji_pages, frame.size.height - PAGCONTROL_POS_Y);
    scrollView.pagingEnabled=YES;
    scrollView.delegate=self;
    
    [self addSubview:scrollView];
    
    // init page control
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, PAGCONTROL_POS_Y, frame.size.width, PAGCONTROL_HEIGHT)];
    [pageControl setCurrentPage:0];
    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:197/255.0
                                                         green:179/255.0
                                                          blue:163/255.0
                                                         alpha:1];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:132/255.0
                                                                green:104/255.0
                                                                 blue:77/255.0
                                                                alpha:1];
    pageControl.numberOfPages = emoji_pages;
    [pageControl setBackgroundColor:[UIColor clearColor]];
    pageControl.hidden=YES;
    [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    [self addSubview:pageControl];
}

- (void)selectEmoji:(UIButton*)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(onSelectEmoji:)]){
        [_delegate onSelectEmoji:emoji_faces[sender.tag]];
    }
}

- (void)deleteEmoji:(UIButton*)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(onSelectEmoji:)]){
        [_delegate onSelectEmoji:@"delete"];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    pageControl.currentPage = page;
}

- (void)changePage:(id)sender {
    int page = pageControl.currentPage;
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * page, 0) animated:YES];
}



@end
