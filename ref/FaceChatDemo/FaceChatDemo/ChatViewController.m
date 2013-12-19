

#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ChatCustomCell.h"

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300


#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

@interface ChatViewController (Private)

- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;

@end

@implementation ChatViewController
@synthesize titleString = _titleString;
@synthesize chatArray = _chatArray;
@synthesize chatTableView = _chatTableView;
@synthesize messageTextField = _messageTextField;
@synthesize phraseViewController = _phraseViewController;
@synthesize udpSocket = _udpSocket;
@synthesize messageString = _messageString;
@synthesize phraseString = _phraseString;
@synthesize lastTime = _lastTime;

@synthesize basetempController;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"backitem.png"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [backBtn setBackgroundImage:image forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:backBtn ];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];

    self.phraseViewController.chatViewController = self;
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"资料"
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:nil];
	self.navigationItem.rightBarButtonItem = rightItem;
	[rightItem release];
    
   	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.chatArray = tempArray;
	[tempArray release];
	
    NSMutableString *tempStr = [[NSMutableString alloc] initWithFormat:@""];
    self.messageString = tempStr;
    [tempStr release];
		
	NSDate   *tempDate = [[NSDate alloc] init];
	self.lastTime = tempDate;
	[tempDate release];
    
    
    //监听键盘高度的变换 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的  
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif

}

-(void) dismissSelf{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];

    

	self.title = @"IM通信";
	[self openUDPServer];
	
	[self.messageTextField setText:self.messageString];
	[self.chatTableView reloadData];
}


-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  
}


- (void)dealloc {
	[_lastTime release];
	[_phraseString release];
	[_messageString release];
	[_udpSocket release];
	[_phraseViewController release];
	[_messageTextField release];
	[_chatArray release];
	[_titleString release];
	[_chatTableView release];
    
    [super dealloc];
}


//建立基于UDP的Socket连接
-(void)openUDPServer{
	//初始化udp
	AsyncUdpSocket *tempSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
	self.udpSocket=tempSocket;
	[tempSocket release];
	//绑定端口
	NSError *error = nil;
	[self.udpSocket bindToPort:4333 error:&error];
    [self.udpSocket joinMulticastGroup:@"224.0.0.1" error:&error];
    
   	//启动接收线程
	[self.udpSocket receiveWithTimeout:-1 tag:0];
  
}
//发送消息
-(IBAction)sendMessage_Click:(id)sender
{	
	NSString *messageStr = self.messageTextField.text;
    self.messageString = self.messageTextField.text;
    
    if (messageStr == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送失败！" message:@"发送的内容不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }else
    {
    [self sendMassage:messageStr];
    }
	self.messageTextField.text = @"";
    self.messageString = self.messageTextField.text;
	[_messageTextField resignFirstResponder];


}
//通过UDP,发送消息
-(void)sendMassage:(NSString *)message
{   
    
	NSDate *nowTime = [NSDate date];
	
	NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
	[sendString appendString:message];
	//开始发送
	BOOL res = [self.udpSocket sendData:[sendString dataUsingEncoding:NSUTF8StringEncoding] 
								 toHost:@"224.0.0.1"
								   port:4333 
							withTimeout:-1 
	
                                   tag:0];
    

   	if (!res) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"发送失败"
													   delegate:self
											  cancelButtonTitle:@"取消"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
        return;
	}
	
	if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	// 发送后生成泡泡显示出来
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval >5) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}	
    UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"me",nil), message] 
								   from:YES];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"text", @"self", @"speaker", chatView, @"view", nil]];
       
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] 
							  atScrollPosition: UITableViewScrollPositionBottom 
									  animated:YES];
}
//选择系统表情
-(IBAction)showPhraseInfo:(id)sender
{   
    self.messageString =[NSMutableString stringWithFormat:@"%@",self.messageTextField.text];
	[self.messageTextField resignFirstResponder];
	if (self.phraseViewController == nil) {
		FaceViewController *temp = [[FaceViewController alloc] initWithNibName:@"FaceViewController" bundle:nil];
		self.phraseViewController = temp;
		[temp release];
	}
	[self presentModalViewController:self.phraseViewController animated:YES];
}


/*
 生成泡泡UIView
 */
#pragma mark -
#pragma mark Table view methods
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf {
	// build single chat bubble cell with given text
    UIView *returnView =  [self assembleMessageAtIndex:text from:fromSelf];
    returnView.backgroundColor = [UIColor clearColor];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    
       UIImageView *headImageView = [[UIImageView alloc] init];
    
    if(fromSelf){
        [headImageView setImage:[UIImage imageNamed:@"face_test.png"]];
        returnView.frame= CGRectMake(9.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f );
        cellView.frame = CGRectMake(265.0f-bubbleImageView.frame.size.width, 0.0f,bubbleImageView.frame.size.width+50.0f, bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width, cellView.frame.size.height-50.0f, 50.0f, 50.0f);
    }
	else{
        [headImageView setImage:[UIImage imageNamed:@"default_head_online.png"]];
        returnView.frame= CGRectMake(65.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
       bubbleImageView.frame = CGRectMake(50.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f);
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f);
         headImageView.frame = CGRectMake(0.0f, cellView.frame.size.height-50.0f, 50.0f, 50.0f);
    }
    

    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:headImageView];
    [cellView addSubview:returnView];
    [bubbleImageView release];
    [returnView release];
    [headImageView release];
	return [cellView autorelease];
    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark UDP Delegate Methods
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{   
    
    NSLog(@"host---->%@",host);
    [self.udpSocket receiveWithTimeout:-1 tag:0];
   	//接收到数据回调，用泡泡VIEW显示出来
	NSString *info=[[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"%@",info);
	
    UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@:%@",@"other", info] 
								   from:NO];

	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:info, @"text", @"other", @"speaker", chatView, @"view", nil]];
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] 
							  atScrollPosition: UITableViewScrollPositionBottom 
									  animated:YES];
	//已经处理完毕
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	//无法发送时,返回的异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{   
	//无法接收时，返回异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

#pragma mark -
#pragma mark Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		return 30;
	}else {
		UIView *chatView = [[self.chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
		return chatView.frame.size.height+10;
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CommentCellIdentifier = @"CommentCell";
	ChatCustomCell *cell = (ChatCustomCell*)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatCustomCell" owner:self options:nil] lastObject];
	}
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		// Set up the cell...
		NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yy-MM-dd HH:mm"];
		NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:[self.chatArray objectAtIndex:[indexPath row]]]];
		[formatter release];
				
		[cell.dateLabel setText:timeString];
		

	}else {
		// Set up the cell...
		NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
		UIView *chatView = [chatInfo objectForKey:@"view"];
		[cell.contentView addSubview:chatView];
	}
    return cell;
}
#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.messageTextField resignFirstResponder];
}
#pragma mark -
#pragma mark TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(textField == self.messageTextField)
	{
//		[self moveViewUp];
	}
}

-(void) autoMovekeyBoard: (float) h{
    
    
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
	toolbar.frame = CGRectMake(0.0f, (float)(480.0-h-108.0), 320.0f, 44.0f);
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f,(float)(480.0-h-108.0));
    
}

#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self autoMovekeyBoard:keyboardRect.size.height];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    

    [self autoMovekeyBoard:0];
}




//图文混排

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
            [array addObject:message];
        }
}

#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 150
-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:13.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *str=[data objectAtIndex:i];
            NSLog(@"str--->%@",str);
                if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 150;
                    Y = upY;
                }
                NSLog(@"str(image)---->%@",str);
                NSString *imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                [img release];
                upX=KFacialSizeWidth+upX;
                if (X<150) X = upX;
                    
                
            } else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = 150;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.font = fon;
                    la.text = temp;
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    [la release];
                    upX=upX+size.width;
                    if (X<150) {
                        X = upX;
                    }
                }
            }
        }
    }
    returnView.frame = CGRectMake(15.0f,1.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    NSLog(@"%.1f %.1f", X, Y);
    return returnView;
}

@end
