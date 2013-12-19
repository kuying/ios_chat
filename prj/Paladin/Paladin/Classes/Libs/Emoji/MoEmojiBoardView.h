//
//  MoEmojiBoardView.h
//  Paladin
//
//  Created by ku ying on 13-12-20.
//  Copyright (c) 2013年 库颖. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoEmojiSelectDelegate <NSObject>

-(void)onSelectEmoji:(NSString*)str;

@end


@interface MoEmojiBoardView : UIView

@property(nonatomic,retain) id<MoEmojiSelectDelegate> delegate;

@end
