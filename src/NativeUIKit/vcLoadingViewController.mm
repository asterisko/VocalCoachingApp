//
//  vcLoadingViewController.m
//  MasterStuffs
//
//  Created by Coaching Vocal on 04/04/2017.
//
//

#import "vcAppViewController.h"
#import "ofxiPhoneExtras.h"
#import "ssApp.h"
#import "MidiApp.h"
#import "vcAppDelegate.h"
#import "vcLoadingViewController.h"


UIView                  * view;
UIView                  * activityIndicatorView2;

extern ssApp            * myApp;
extern vcAppDelegate    * vcAppDelegatePNT;

@interface vcLoadingViewController () <UINavigationControllerDelegate>
@end

@implementation vcLoadingViewController {
}


////////////////////////////////////////////////////////////////////
//
//  VIEW CONTROLLERS DEFAULT METHODS
//
////////////////////////////////////////////////////////////////////

- (void)loadView {
    
    [super loadView];
    
    cout << "[Load View] Entering" << endl;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImageView* backgroundView;
    backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DSGNbkg.png"]] autorelease];
    [self.view addSubview: backgroundView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    
    //31_03 CONTAINER VIEW not sure about that
    //    CGRect scrollViewFrame = CGRectMake(0.f,
    //                                        0.f,
    //                                        screenRect.size.width,
    //                                        screenRect.size.height);
    //
    //    UIScrollView* containerView = [[[UIScrollView alloc] initWithFrame:scrollViewFrame] autorelease];
    //
    //    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //
    //    containerView.showsHorizontalScrollIndicator = YES; // 31_03 (alterado de NO para YES)
    //    containerView.showsVerticalScrollIndicator = YES;
    //    containerView.alwaysBounceVertical = NO;            // remove verical drag
    //
    //    [self.view addSubview:containerView];
    
    CGFloat screenWidth = screenRect.size.height;
    CGFloat screenHeight = screenRect.size.width;
    
    //    if(myApp->dbgMode)
    cout << "width: " << screenWidth << "height: " << screenHeight << endl; // ANDRE
    
    CGFloat boxWidth = screenWidth;  // size of box
    CGFloat boxheight = screenHeight; // size of box
    
    CGFloat boxX = screenWidth/2.0 - boxWidth/2.0;  // size of box
    CGFloat boxY = screenHeight/2.0 - boxheight/2.0; // size of box
    
    // Create activityIndicator
    UIActivityIndicatorView *activityIndicatorSwipe = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorSwipe.center = CGPointMake(boxWidth/2.0, boxheight/2.0);
    activityIndicatorSwipe.color = UIColor.whiteColor;
    [activityIndicatorSwipe startAnimating];
    
    // Create activityIndicator View
    activityIndicatorView2 = [[UIView alloc] initWithFrame:CGRectMake(boxX, boxY, boxWidth, boxheight)];
    activityIndicatorView2.opaque = NO;
    activityIndicatorView2.clipsToBounds = YES;
    activityIndicatorView2.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    //activityIndicatorView.layer.cornerRadius = 8;
    // Add Swipe to the view
    [activityIndicatorView2 addSubview:activityIndicatorSwipe];
    
    
    // Create Loading Label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/2.0-80, boxheight/2.0 - 50 + 20, 160, 100)];
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

    
    
    vcAppViewController *viewController;
    
    myApp = new ssApp();
    
    viewController = [[[vcAppViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                             app:myApp] autorelease];
    /////////////////////////////////////////////////////////
    // 2 - Update the Navigation Controller
    /////////////////////////////////////////////////////////
    [self.navigationController pushViewController:viewController animated:YES];
    
    /////////////////////////////////////////////////////////
    // 3 - Remove Activity Indication View From SuperView
    /////////////////////////////////////////////////////////
    [activityIndicatorView2 removeFromSuperview];
    
}



////////////////////////////////////////////////////////////////////
//
//  ROTATIONS METHODS
//
////////////////////////////////////////////////////////////////////

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

-(BOOL)shouldAutorotate {
    return [[self.navigationController navigationController] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations {
    return [[self.navigationController navigationController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.navigationController navigationController] preferredInterfaceOrientationForPresentation];
}

@end
