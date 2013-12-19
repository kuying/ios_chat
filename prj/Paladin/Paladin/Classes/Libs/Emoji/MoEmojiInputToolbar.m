//
//  MoEmojiInputToolbar.m
//  Paladin
//
//  Created by 库颖 on 13-12-19.
//  Copyright (c) 2013年 库颖. All rights reserved.
//

#import "MoEmojiInputToolbar.h"

@implementation MoEmojiInputToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"]];
        
        NSError *error;
        id emoji = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
        
        if ([emoji isKindOfClass:[NSArray class]]) {
            for (id emojid in emoji) {
                NSLog(@"%04x - %@", emojid, emojid);
            }
        }
        else {
            NSLog(@"fail");
        }
        
    }
    return self;
}

@end
