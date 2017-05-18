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
    
    
    CGFloat screenWidth = screenRect.size.height;
    CGFloat screenHeight = screenRect.size.width;
    
    //    if(myApp->dbgMode)
    cout << "width: " << screenWidth << "height: " << screenHeight << endl; // ANDRE
    
    CGFloat boxWidth = screenWidth;  // size of box
    CGFloat boxheight = screenHeight; // size of box
    
    CGFloat boxX = screenWidth/2.0 - boxWidth/2.0;  // size of box
    CGFloat boxY = screenHeight/2.0 - boxheight/2.0; // size of box
    
    
    
    vcAppViewController *viewController;
    
    myApp = new ssApp();
    
    viewController = [[[vcAppViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                             app:myApp] autorelease];
    /////////////////////////////////////////////////////////
    // 2 - Update the Navigation Controller
    /////////////////////////////////////////////////////////
    [self.navigationController pushViewController:viewController animated:NO];
    
    /////////////////////////////////////////////////////////
    // 3 - Remove Activity Indication View From SuperView
    /////////////////////////////////////////////////////////
//    [activityIndicatorView2 removeFromSuperview];
    
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
