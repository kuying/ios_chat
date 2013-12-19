//
//  MoViewController.h
//  Paladin
//
//  Created by 库颖 on 13-12-19.
//  Copyright (c) 2013年 库颖. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface MoViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;

@end