//
//  MessageListViewController.m
//  MessageList
//
//  Created by 刘超 on 13-11-12.
//  Copyright (c) 2013年 刘超. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MessageListViewController.h"
#import "RegexKitLite.h"
#import "SCGIFImageView.h"
#import "CustomLongPressGestureRecognizer.h"

@interface MessageListViewController ()

@end

@implementation MessageListViewController
@synthesize ui_tableView;
@synthesize ui_imageView;
@synthesize ui_textField;
@synthesize ui_sendButton;

- (void)moveInputBarWithKeyboardHeight:(float)keyboardHeight withDuration:(NSTimeInterval)animationDuration
{
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.ui_tableView.frame = CGRectMake(0, 45, 320, 380-keyboardHeight);
        self.ui_imageView.frame = CGRectMake(self.ui_imageView.frame.origin.x, 426-keyboardHeight, self.ui_imageView.frame.size.width, self.ui_imageView.frame.size.height);
        self.ui_textField.frame = CGRectMake(self.ui_textField.frame.origin.x, 428-keyboardHeight, self.ui_textField.frame.size.width, self.ui_textField.frame.size.height);
        self.ui_sendButton.frame = CGRectMake(self.ui_sendButton.frame.origin.x, 426-keyboardHeight, self.ui_sendButton.frame.size.width, self.ui_sendButton.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.m_textArray = [NSMutableArray array];
    [self.m_textArray addObject:[CustomMethod escapedString:@"这是一个测试Demo"]];
    [self.m_textArray addObject:[CustomMethod escapedString:@"测试的内容是什么呢？"]];
    [self.m_textArray addObject:[CustomMethod escapedString:@"[大笑][难过][伤心][尴尬][疑惑][喜欢][期待][呆萌][惊讶][生气][害羞][开心]"]];
    [self.m_textArray addObject:[CustomMethod escapedString:@"文字表情同时存在，网址链接，电话链接等等"]];
    [self.m_textArray addObject:[CustomMethod escapedString:@"[大笑]肺结核[难过]韩国的部分就[伤心][尴尬]的风格和部分的[疑惑][喜欢][期待]东方既白国[大笑][大笑]际法的不干净[呆萌][惊讶][生气]大家回复不[伤心]过基本的房[大笑][害羞]间关闭的房间不个[伤心]百分点时刻表[害羞][开心]京东方[伤心][伤心]还不赶紧发的[伤心]是北京的世[伤心]界观的房间"]];
    [self.m_textArray addObject:[CustomMethod escapedString:@"爱到底18092293443修复返回北京的司法鉴定http://www.code4app.com"]];
    [self.m_textArray addObject:[CustomMethod escapedString:@"029-88888888金汉斯[害羞]佛本是道0917-9090909见到你[难过]会计法0917-98293929可拒付深v看029-9829291"]];
    [self.m_textArray addObject:[CustomMethod escapedString:@"发生地方[大开心]法撒旦[大开心]冯绍峰[大开心][大开心][大开心]而威尔额外"]];
    [self.m_textArray addObject:[CustomMethod escapedString:@"测试http://code4app.com/ios/MessageList/5282e8776803faeb61000001"]];
    
    NSArray *wk_paceImageNumArray = [[NSArray alloc]initWithObjects:@"emoji_0.png",@"emoji_1.png",@"emoji_2.png",@"emoji_3.png",@"emoji_4.png",@"emoji_5.png",@"emoji_6.png",@"emoji_7.png",@"emoji_8.png",@"emoji_9.png",@"emoji_10.png",@"emoji_11.png", nil];
    NSArray *wk_paceImageNameArray = [[NSArray alloc]initWithObjects:@"[大笑]",@"[难过]",@"[伤心]",@"[尴尬]",@"[疑惑]",@"[喜欢]",@"[期待]",@"[呆萌]",@"[惊讶]",@"[生气]",@"[害羞]",@"[开心]", nil];
    self.m_emojiDic = [[NSDictionary alloc] initWithObjects:wk_paceImageNumArray forKeys:wk_paceImageNameArray];
    
    self.m_labelArray = [NSMutableArray array];
    self.m_rowHeights = [NSMutableArray array];
    
    [self creatLabelArray];
}

- (IBAction)onSendButton:(id)sender
{
    if (self.ui_textField.text == nil || [self.ui_textField.text isEqualToString:@""]) {
        UIAlertView *ui_alertView =[[UIAlertView alloc]initWithTitle:@"不能发送空消息" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [ui_alertView show];
    }else{
        [self.m_textArray addObject:[CustomMethod escapedString:self.ui_textField.text]];
        self.ui_textField.text = @"";
    }
    [self creatLabelArray];
    [self.ui_tableView reloadData];
    [self.ui_textField resignFirstResponder];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)creatLabelArray
{
    NSLog(@"%@",self.m_textArray);
    if (self.m_labelArray.count > 0) {
        [self.m_labelArray removeAllObjects];
    }
    if (self.m_rowHeights.count > 0) {
        [self.m_rowHeights removeAllObjects];
    }
    for (int i = 0; i < [self.m_textArray count]; i++) {
#warning 家校需要提取的地方
        OHAttributedLabel *label = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
        NSString *text = [self.m_textArray objectAtIndex:i];
        [self creatAttributedLabel:text Label:label];
        NSNumber *heightNum = [[NSNumber alloc] initWithFloat:label.frame.size.height];
        [self.m_labelArray addObject:label];
        [CustomMethod drawImage:label];
        [self.m_rowHeights addObject:heightNum];
    }
}

#warning 家校需要提取的地方
- (void)creatAttributedLabel:(NSString *)o_text Label:(OHAttributedLabel *)label
{
    [label setNeedsDisplay];
    NSMutableArray *httpArr = [CustomMethod addHttpArr:o_text];
    NSMutableArray *phoneNumArr = [CustomMethod addPhoneNumArr:o_text];
    NSMutableArray *emailArr = [CustomMethod addEmailArr:o_text];
    
    NSString *text = [CustomMethod transformString:o_text emojiDic:self.m_emojiDic];
    text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",text];
    
    MarkupParser *wk_markupParser = [[MarkupParser alloc] init];
    NSMutableAttributedString* attString = [wk_markupParser attrStringFromMarkup: text];
    [attString setFont:[UIFont systemFontOfSize:16]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setAttString:attString withImages:wk_markupParser.images];
    
    NSString *string = attString.string;
    
    if ([emailArr count]) {
        for (NSString *emailStr in emailArr) {
            [label addCustomLink:[NSURL URLWithString:emailStr] inRange:[string rangeOfString:emailStr]];
        }
    }
    
    if ([phoneNumArr count]) {
        for (NSString *phoneNum in phoneNumArr) {
            [label addCustomLink:[NSURL URLWithString:phoneNum] inRange:[string rangeOfString:phoneNum]];
        }
    }
    
    if ([httpArr count]) {
        for (NSString *httpStr in httpArr) {
            [label addCustomLink:[NSURL URLWithString:httpStr] inRange:[string rangeOfString:httpStr]];
        }
    }

    label.delegate = self;
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].height;
    label.frame = labelRect;
    label.underlineLinks = YES;//链接是否带下划线
    [label.layer display];
}

- (BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    NSString *requestString = [linkInfo.URL absoluteString];
    NSLog(@"%@",requestString);
    if ([[UIApplication sharedApplication]canOpenURL:linkInfo.URL]) {
        [[UIApplication sharedApplication]openURL:linkInfo.URL];
    }
    
    return NO;
}

#pragma mark
#pragma mark -  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.m_textArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 3 == 0) {
        return([[self.m_rowHeights objectAtIndex:indexPath.row] floatValue] + 45);
    }else{
        return([[self.m_rowHeights objectAtIndex:indexPath.row] floatValue] + 25);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *view = [[UIView alloc] init];
        view.tag = 201;
        //添加背景图片imageView
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 202;
        [view addSubview:imageView];
        
        //添加手势
        CustomLongPressGestureRecognizer *wk_longPressGestureRecognizer = [[CustomLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [wk_longPressGestureRecognizer setMinimumPressDuration:0.5];
        [view addGestureRecognizer:wk_longPressGestureRecognizer];
        [cell.contentView addSubview:view];
        
        [cell bringSubviewToFront:view];
    }
    
    //重用Cell的时候移除label
    UIView *view = (UIView *)[cell viewWithTag:201];
    view.frame = CGRectMake(20, 0, cell.contentView.frame.size.width-80, [[self.m_rowHeights objectAtIndex:indexPath.row] floatValue]+20);
    
    for (UIView *subView in [view subviews]) {
        if ([subView isKindOfClass:[OHAttributedLabel class]]) {
            [subView removeFromSuperview];
        }
    }
    
    NSArray *wk_labelArray = [cell.contentView subviews];
    for (int i = 0; i < wk_labelArray.count; i++) {
        if ([[wk_labelArray objectAtIndex:i] isKindOfClass:[UILabel class]]) {
            [[wk_labelArray objectAtIndex:i] removeFromSuperview];
        };
    }
    
    NSArray *wk_headButtonArray = [cell.contentView subviews];
    for (int i = 0; i < wk_headButtonArray.count; i++) {
        if ([[wk_headButtonArray objectAtIndex:i] isKindOfClass:[UIButton class]]) {
            [[wk_headButtonArray objectAtIndex:i] removeFromSuperview];
        };
    }
    
    NSDate *wk_currentTime = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd  HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:wk_currentTime];
    
    UILabel *wk_timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 15)];
    wk_timeLabel.text = timeString;
    wk_timeLabel.textColor = [UIColor lightGrayColor];
    wk_timeLabel.backgroundColor = [UIColor clearColor];
    wk_timeLabel.textAlignment = NSTextAlignmentCenter;
    wk_timeLabel.font = [UIFont systemFontOfSize:12.0f];
    [cell.contentView addSubview:wk_timeLabel];
    
    UIButton *wk_button = [[UIButton alloc]init];
    [cell.contentView addSubview:wk_button];
    
    float sysVersion = [[[UIDevice currentDevice]systemVersion] floatValue];
    UIImage *image;//气泡图片
    if (sysVersion < 5.0) {
        if (indexPath.row % 3 == 0) {
            wk_timeLabel.hidden = NO;
            [wk_button setFrame:CGRectMake(5, 25, 35, 35)];
            [wk_button setBackgroundImage:[UIImage imageNamed:@"user_detault_avatar2.jpg"] forState:UIControlStateNormal];
            view.frame = CGRectMake(20, 0, cell.contentView.frame.size.width-80, [[self.m_rowHeights objectAtIndex:indexPath.row] floatValue]+40);
            image = [[UIImage imageNamed:@"message_send_box_other1.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:30];
        }else {
            wk_timeLabel.hidden = YES;
            [wk_button setFrame:CGRectMake(275, 5, 35, 35)];
            [wk_button setBackgroundImage:[UIImage imageNamed:@"user_detault_avatar1.jpg"] forState:UIControlStateNormal];
            image = [[UIImage imageNamed:@"message_send_box_self1.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:30];
        }
    }else {
        if (indexPath.row % 3 == 0) {
            wk_timeLabel.hidden = NO;
            [wk_button setFrame:CGRectMake(5, 25, 35, 35)];
            [wk_button setBackgroundImage:[UIImage imageNamed:@"user_detault_avatar2.jpg"] forState:UIControlStateNormal];
            view.frame = CGRectMake(20, 0, cell.contentView.frame.size.width-80, [[self.m_rowHeights objectAtIndex:indexPath.row] floatValue]+40);
            image = [[UIImage imageNamed:@"message_send_box_other1.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)];
        }else {
            wk_timeLabel.hidden = YES;
            [wk_button setFrame:CGRectMake(275, 5, 35, 35)];
            [wk_button setBackgroundImage:[UIImage imageNamed:@"user_detault_avatar1.jpg"] forState:UIControlStateNormal];
            image = [[UIImage imageNamed:@"message_send_box_self1.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)];
        }
    }
    
    
    [self tableView:self.ui_tableView heightForRowAtIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[view viewWithTag:202];
    imageView.image = image;
    imageView.frame = view.frame;
    
    CustomLongPressGestureRecognizer *recognizer = (CustomLongPressGestureRecognizer *)[view.gestureRecognizers objectAtIndex:0];
    //view内添加上label视图
    OHAttributedLabel *label = [self.m_labelArray objectAtIndex:indexPath.row];
    [label setCenter:view.center];
    [recognizer setLabel:label];
    
    if (indexPath.row % 3 == 0) {
        label.frame = CGRectMake(view.frame.origin.x+20, view.frame.origin.y+30, recognizer.label.frame.size.width, label.frame.size.height);
        imageView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y+20, recognizer.label.frame.size.width+40, label.frame.size.height+20);
    }else{
        label.frame = CGRectMake(320-recognizer.label.frame.size.width-70-20, view.frame.origin.y+10, recognizer.label.frame.size.width, label.frame.size.height);
        
        imageView.frame = CGRectMake(label.frame.origin.x-20, view.frame.origin.y, recognizer.label.frame.size.width+40, label.frame.size.height+20);
    }
    
    [view addSubview:label];
    
    return cell;
}

#pragma mark
#pragma mark -  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
    [view setTag:301];
    [view setBackgroundColor:[UIColor lightGrayColor]];
    [view setAlpha:0.5];
    [cell addSubview:view];
}

- (void)longPress:(CustomLongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        currentLabel = gestureRecognizer.label;
        NSIndexPath *pressedIndexPath = [self.ui_tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.ui_tableView]];
        currentIndexRow = pressedIndexPath.row;//长按手势在哪个Cell内
        UIAlertView *wk_alertView =  [[UIAlertView alloc] initWithTitle:@"确定复制该消息？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [wk_alertView setTag:100];
        [wk_alertView show];
    }
}

#pragma mark
#pragma mark -  UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            NSString* o_text = [self.m_textArray objectAtIndex:currentIndexRow];//根据Cell Index 获取复制内容
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:o_text];
        }
    }
    
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
}

@end
