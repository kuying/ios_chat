//
//  MessageListViewController.h
//  MessageList
//
//  Created by 刘超 on 13-11-12.
//  Copyright (c) 2013年 刘超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAttributedString+Attributes.h"
#import "MarkupParser.h"
#import "OHAttributedLabel.h"
#import "CustomMethod.h"

@class OHAttributedLabel;

@interface MessageListViewController : UIViewController
<OHAttributedLabelDelegate,UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UITableView *_tableView;
    BOOL singleLine;
    int currentIndexRow;
    OHAttributedLabel *currentLabel;
}
@property (nonatomic,assign) dispatch_queue_t m_drawImageQueue;
@property (nonatomic, strong) IBOutlet UITableView *ui_tableView;
@property (nonatomic, strong) IBOutlet UIImageView *ui_imageView;
@property (nonatomic, strong) IBOutlet UITextField *ui_textField;
@property (nonatomic, strong) IBOutlet UIButton *ui_sendButton;

@property (nonatomic, strong) NSMutableArray *m_textArray;
@property (nonatomic, strong) NSMutableArray *m_rowHeights;
@property (nonatomic, strong) NSMutableArray *m_labelArray;
@property (nonatomic, strong) NSDictionary *m_emojiDic;

- (IBAction)onSendButton:(id)sender;

@end
