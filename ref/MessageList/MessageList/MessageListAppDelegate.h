//
//  MessageListAppDelegate.h
//  MessageList
//
//  Created by 刘超 on 13-11-12.
//  Copyright (c) 2013年 刘超. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageListViewController;

@interface MessageListAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MessageListViewController *viewController;

@end
