//
//  MenuViewController.m
//  Created by SIL 07/05/13.
//

#import "mainAppViewController.h"
#import "ssAppViewController.h"
#import "ssFileListViewController.h"
#import "ssFileListSendMailViewController.h"
#import "MessageComposerFeedbackViewController.h"

#import "ssApp.h"
#import "MidiApp.h"
#import "mainAppDelegate.h"

// Add Email Features
#import <MessageUI/MessageUI.h>

UIView                  * view;
UIView                  * activityIndicatorView2;

extern ssApp            * myApp;
extern mainAppDelegate  * mainAppDelegatePNT;

@interface mainAppViewController () <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate>
@end


@implementation mainAppViewController {
    //UIButton *btn_loadFile;
    UIButton *btn_record;
    //UIButton *btn_sendFeedback;
}

- (void)loadView {

    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImageView* backgroundView;
    backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DSGNbkg.png"]] autorelease];
    [self.view addSubview: backgroundView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGRect scrollViewFrame = CGRectMake(0.f,
                                        0.f,
                                        screenRect.size.width,
                                        screenRect.size.height);
    
    UIScrollView* containerView = [[[UIScrollView alloc] initWithFrame:scrollViewFrame] autorelease];
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    containerView.showsHorizontalScrollIndicator = NO;
    containerView.showsVerticalScrollIndicator = YES;
    containerView.alwaysBounceVertical = NO;            // remove verical drag
    
    [self.view addSubview:containerView];
    

    ///////////////////////////////////////////////////////////////////////////////
    // ADD BUTTONS
    ///////////////////////////////////////////////////////////////////////////////
    NSInteger   buttonY       = 44;     // make room for navigation bar.
    NSInteger   buttonHeigth  = (screenRect.size.width - buttonY+5) / 3;
    NSInteger   buttonWidth   = screenRect.size.height;
    CGRect      buttonRect    = CGRectMake(0, 0, buttonWidth, buttonHeigth);
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // ADD LOAD FILE BUTTON
    ///////////////////////////////////////////////////////////////////////////////
//    btn_loadFile = [self makeButtonWithFrame:CGRectMake(0, buttonY, buttonRect.size.width, buttonRect.size.height)
//                                   andText:@"Load File"];
//    [btn_loadFile setBackgroundImage:[UIImage imageNamed:@"GUI/btn_LoadFile.png"] forState:UIControlStateNormal];
//    [btn_loadFile setBackgroundImage:[UIImage imageNamed:@"GUI/btn_LoadFileMouseOver.png"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
//    [btn_loadFile addTarget:self action:@selector(button1Pressed:) forControlEvents:UIControlEventTouchDown];
//
//    [containerView addSubview:btn_loadFile ];
    
    ///////////////////////////////////////////////////////////////////////////////
    // ADD RECORD BUTTON
    ///////////////////////////////////////////////////////////////////////////////
    btn_record = [self makeButtonWithFrame:CGRectMake(0, buttonY + buttonRect.size.height, buttonRect.size.width, buttonRect.size.height)
                                 andText:@"Live Recording"];
    [btn_record setBackgroundImage:[UIImage imageNamed:@"GUI/btn_LiveRecording.png"] forState:UIControlStateNormal];
    [btn_record setBackgroundImage:[UIImage imageNamed:@"GUI/btn_LiveRecordingMouseOver.png"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [btn_record addTarget:self action:@selector(button2Pressed:) forControlEvents:UIControlEventTouchDown];
    [containerView addSubview:btn_record ];

    ///////////////////////////////////////////////////////////////////////////////
    // ADD Feedback BUTTON
    ///////////////////////////////////////////////////////////////////////////////
//    btn_sendFeedback = [self makeButtonWithFrame:CGRectMake(0, buttonY + 2*buttonRect.size.height, buttonRect.size.width, buttonRect.size.height)
//                                             andText:@"Send FeedBack"];
//    [btn_sendFeedback setBackgroundImage:[UIImage imageNamed:@"GUI/btn_SendFeedback.png"] forState:UIControlStateNormal];
//    [btn_sendFeedback setBackgroundImage:[UIImage imageNamed:@"GUI/btn_SendFeedbackMouseOver.png"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
//    [btn_sendFeedback addTarget:self action:@selector(button3Pressed:) forControlEvents:UIControlEventTouchDown];
//    [containerView addSubview:btn_sendFeedback ];
    
    containerView.contentSize = CGSizeMake(buttonRect.size.width, buttonRect.size.height * 3);
    }

- (void)viewWillAppear:(BOOL)animated {
    }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.navigationBar.opaque  = YES;
    self.navigationController.toolbarHidden         = YES;
    
    //self.navigationController.navigationBar.topItem.title = @"SingingStudio™ - Menu";

//    self.navigationController.toolbar.barTintColor          = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];      // Bottom bar color
//    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];      // Top bar color
//    self.navigationController.navigationBar.tintColor       = [UIColor grayColor];    // Text Color
    }


- (UIButton*) makeButtonWithFrame:(CGRect)frame andText:(NSString*)text {
    
    for (NSString *familyName in [UIFont familyNames]) {
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"%@", fontName);
            }
        }
    
 //   UIFont *font; // old font Georgia
 //   font = [UIFont fontWithName:@"Helvetica Neue" size:68];
/*
    UILabel *label;
    label = [[[ UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
    label.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    label.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
//    label.textColor = [UIColor colorWithRed:0.45 green:0.63 blue:0.48 alpha:1];
    label.text = [text uppercaseString];
    label.textAlignment = UITextAlignmentCenter;
    label.font = font;
    label.userInteractionEnabled = NO;
    label.exclusiveTouch = NO;
*/
    UIButton* button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    [button setBackgroundColor:[UIColor clearColor]];
  //  [button addSubview:label];
    
    return button;
    }

// -------------------------------------------------------------------------------
//	BUTTON1 STUFF
// -------------------------------------------------------------------------------
//- (void)button1Pressed:(id)sender {
//    NSLog(@"In  button1Pressed");
//    UIButton *button = (UIButton *)sender;
//    if(!button.selected)
//        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(highlightButton1:) userInfo:button repeats:NO];
//    }
//
//-(void)highlightButton1:(id)sender{
//    UIButton *button = (UIButton *)[sender userInfo];
//    button.highlighted = YES;
//    button.selected = YES;
//    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(loadFilesBrowser:) userInfo:button repeats:NO];
//}
//
//-(void)loadFilesBrowser:(id)sender{
//    UIButton *button = (UIButton *)[sender userInfo];
//    button.highlighted = NO;
//    button.selected = NO;
//    
//    ssFileListViewController * mySSFileListViewController;
//    mySSFileListViewController = [[ssFileListViewController alloc] init];
//    [self.navigationController pushViewController:mySSFileListViewController animated:YES];
//
//    [mySSFileListViewController release];
//}

// -------------------------------------------------------------------------------
//	BUTTON2 STUFF
// -------------------------------------------------------------------------------
- (void)button2Pressed:(id)sender {
    NSLog(@"In  button2Pressed");
    
    UIButton *button = (UIButton *)sender;
    
    if(!button.selected)
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(highlightButton2:) userInfo:button repeats:NO];
}

-(void)highlightButton2:(id)sender{
    UIButton *button = (UIButton *)[sender userInfo];
    button.highlighted = YES;
    button.selected = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(loadSingingStudioApp:) userInfo:button repeats:NO];
}

-(void)loadSingingStudioApp:(id)sender{
    
    /////////////////////////////////////////////////////////
    // 2 - Add Activity Indicator View and lunch in parallel the Singing Studio App
    /////////////////////////////////////////////////////////
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.height;
    CGFloat screenHeight = screenRect.size.width;
    
    cout << "width: " << screenWidth << "height: " << screenHeight << endl; // ANDRE
    
//    screenHeight = 2048;
//    screenWidth = 1536;
    
    CGFloat boxWidth = screenWidth;  // size of box
    CGFloat boxHeigth = screenHeight; // size of box
    
    CGFloat boxX = screenWidth/2.0 - boxWidth/2.0;  // size of box
    CGFloat boxY = screenHeight/2.0 - boxHeigth/2.0; // size of box
    
    // Create activityIndicator
    UIActivityIndicatorView *activityIndicatorSwipe = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorSwipe.center = CGPointMake(boxWidth/2.0, boxHeigth/2.0);
    activityIndicatorSwipe.color = UIColor.whiteColor;
    [activityIndicatorSwipe startAnimating];                         //Or whatever UI Change you need to make
    
    // Create activityIndicator View
    activityIndicatorView2 = [[UIView alloc] initWithFrame:CGRectMake(boxX, boxY, boxWidth, boxHeigth)];
    activityIndicatorView2.opaque = NO;
    activityIndicatorView2.clipsToBounds = YES;
    activityIndicatorView2.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    //activityIndicatorView.layer.cornerRadius = 8;
    // Add Swipe to the view
    [activityIndicatorView2 addSubview:activityIndicatorSwipe];
    
    // Create Label Loading...
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/2.0-80, boxHeigth/2.0 - 50 + 20, 160, 100)];
    label.text = @"Loading...";
    label.textColor = UIColor.whiteColor;
    label.backgroundColor = UIColor.clearColor;
    //label.textAlignment = UITextAlignmentCenter;
    label.textAlignment = NSTextAlignmentCenter; // ANDRE
    label.numberOfLines = 0;
    //label.lineBreakMode = UILineBreakModeWordWrap;
    label.lineBreakMode = NSLineBreakByWordWrapping; // ANDRE
    [activityIndicatorView2 addSubview:label];           // Add Label to the view
    
    [self.view addSubview:activityIndicatorView2];
    
    [self performSelector: @selector(launchSingingStudioApp)    //perform time-consuming tasks
               withObject: nil
               afterDelay: 0.1];

   // [label release];
   // [activityIndicatorSwipe release];
}

- (void) launchSingingStudioApp {
    NSLog(@"In  launchSingingStudioApp");
    
    /////////////////////////////////////////////////////////
    // 1 - Create new instance of SS
    /////////////////////////////////////////////////////////
    ssAppViewController *viewController;
    
    myApp = new ssApp();
    
    viewController = [[[ssAppViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                             app:myApp] autorelease];
    /////////////////////////////////////////////////////////
    // 2 - Update the Navigation Controller
    /////////////////////////////////////////////////////////
    [self.navigationController pushViewController:viewController animated:YES];
    
    /////////////////////////////////////////////////////////
    // 3 - Remove Activity Indication View From SuperView
    /////////////////////////////////////////////////////////
    [activityIndicatorView2 removeFromSuperview];
    [btn_record setSelected:NO];
    [btn_record setHighlighted:NO];

    //   button.highlighted = NO;
    //   button.selected = NO;

}

// -------------------------------------------------------------------------------
//	BUTTON3 STUFF
// -------------------------------------------------------------------------------
//- (void)button3Pressed:(id)sender {
//    NSLog(@"In  button3Pressed");
//    
//    UIButton *button = (UIButton *)sender;
//    
//    if(!button.selected)
//        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(highlightButton3:) userInfo:button repeats:NO];
//    }
//
//-(void)highlightButton3:(id)sender{
//    UIButton *button = (UIButton *)[sender userInfo];
//    button.highlighted = YES;
//    button.selected = YES;
//    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(loadMailFeedbackComposer:) userInfo:button repeats:NO];
//}
//
//-(void)loadMailFeedbackComposer:(id)sender{
//    [self displayMailFeedbackComposerSheet];
//    }
//
// -------------------------------------------------------------------------------
//	handle rotation
// -------------------------------------------------------------------------------
-(BOOL)shouldAutorotate {
    return [[self.navigationController navigationController] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations {
    return [[self.navigationController navigationController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.navigationController navigationController] preferredInterfaceOrientationForPresentation];
}

// -------------------------------------------------------------------------------
//	displayMailFeedbackComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
//- (void)displayMailFeedbackComposerSheet {
//    
//    // Create Mail composer Object
//	MFMailComposeViewController *myMailComposeViewController = [[MFMailComposeViewController alloc] init];
//	myMailComposeViewController.mailComposeDelegate = self;
//    
//    // Add Email Destination
//    NSArray *usersTo = [NSArray arrayWithObject: @"voicestudies@fe.up.pt"];
//    [myMailComposeViewController setToRecipients:usersTo];
//    
//    // Add Email Subject
//    [myMailComposeViewController setSubject:@"SingingStudio™ User Feedback"];
//	
//	// Fill out the email body text
//	NSString *emailBody = @"Hi SingingStudio™ Team,\n\n\n\n";
//    
//	[myMailComposeViewController setMessageBody:emailBody isHTML:NO];
//	
//    // myMailComposeViewController = UIModalPresentationFullScreen;
//	[self presentViewController:myMailComposeViewController animated:YES completion:^{  btn_sendFeedback.highlighted = NO;
//                                                                                        btn_sendFeedback.selected = NO;
//                                                                                        }];
//    }

#pragma mark - Delegate Methods
// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
//- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
//	// Notifies users about errors associated with the interface
//    
//    UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle: @"Mail Message"
//                          message: nil
//                          delegate: nil
//                          cancelButtonTitle:@"OK"
//                          otherButtonTitles:nil];
//    switch (result) {
//		case MFMailComposeResultCancelled:
//            alert.message=@"Mail sending canceled";
// 			break;
//		case MFMailComposeResultSaved:
//            alert.message=@"Mail saved";
//			break;
//		case MFMailComposeResultSent:
//            alert.message=@"Mail sent";
//			break;
//		case MFMailComposeResultFailed:
//            alert.message=@"Mail sending failed";
//			break;
//		default:
//            alert.message=@"Mail not sent";
//			break;
//        }
//    
////    [alert show];
////    [alert release];
//	[self dismissViewControllerAnimated:YES completion:NULL];
//    [btn_sendFeedback setSelected:NO];
//    }

@end
