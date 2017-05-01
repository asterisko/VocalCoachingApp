//
//  mainAppDelegate.m
//  Created by SIL 07/05/13.
//

#import "mainAppDelegate.h"
#import "mainAppViewController.h"
#import "ssApp.h"
#import "ssAppViewController.h"

mainAppDelegate * mainAppDelegatePNT;
extern ssAppViewController     * mySsAppViewController; // 30_03
extern ssApp * myApp;   // Global Pointer to mainApp

@implementation mainAppDelegate

@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [super applicationDidFinishLaunching:application];
    
    //////////////////////////////////////////////////////////
    // Copy File to Documents Dir
    //////////////////////////////////////////////////////////
  
    NSFileManager *fmngr = [[NSFileManager alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"./songs/Intermezzo.wav" ofType:nil];
    NSError *error;

    /*
    if(![fmngr copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/Documents/Intermezzo.wav", NSHomeDirectory()] error:&error]) {
        // handle the error
        NSLog(@"Error creating the file: %@", [error description]);
        
    }
    
    filePath = [[NSBundle mainBundle] pathForResource:@"./songs/Cheek to Cheek.wav" ofType:nil];
    if(![fmngr copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/Documents/Cheek to Cheek.wav", NSHomeDirectory()] error:&error]) {
        // handle the error
        NSLog(@"Error creating the file: %@", [error description]);
    }
    */
    
    // 31_03
    filePath = [[NSBundle mainBundle] pathForResource:@"./songs/test-Do2-Si5.wav" ofType:nil];
    if(![fmngr copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/Documents/test-Do2-Si5.wav", NSHomeDirectory()] error:&error]) {
        // handle the error
        NSLog(@"Error creating the file: %@", [error description]);
        
    }
    
    filePath = [[NSBundle mainBundle] pathForResource:@"./songs/test-Do4-Si7.wav" ofType:nil];
    if(![fmngr copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/Documents/test-Do4-Si7.wav", NSHomeDirectory()] error:&error]) {
        // handle the error
        NSLog(@"Error creating the file: %@", [error description]);
    
    }
    [fmngr release];
    ////////////////////////////////////////////////////////
    
    /**
     *
     *  Below is where you insert your own UIViewController and take control of the App.
     *  In this example im creating a UINavigationController and adding it as my RootViewController to the window. (this is essential)
     *  UINavigationController is handy for managing the navigation between multiple view controllers, more info here,
     *  http://developer.apple.com/library/ios/#documentation/uikit/reference/UINavigationController_Class/Reference/Reference.html
     *
     *  I then push MyAppViewController onto the UINavigationController stack.
     *  MyAppViewController is a custom view controller with a 3 button menu.
     *
     **/
    
    self.navigationController = [[[UINavigationController alloc] init] autorelease];
    
    //[self.window setRootViewController:self.navigationController];
    self.window.rootViewController = self.navigationController;
    
    [self.navigationController pushViewController:[[[mainAppViewController alloc] init] autorelease]
                                         animated:YES];
    
//    [self.navigationController pushViewController:[[[ssAppViewController alloc] init] autorelease] // ANDRE
//                                         animated:YES];

    
    //--- style the UINavigationController
    // TOP Navigation Controller
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    // Pointer to Customize Bottom ToolBar
    mainAppDelegatePNT = self;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    ofSetFrameRate(0);

    /*
     Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an
     incoming phone call or SMS message) or when the user quits the application
     and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down
     OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

    /*
     Use this method to release shared resources, save user data, invalidate
     timers, and store enough application state information to restore your
     application to its current state in case it is terminated later.
     If your application supports background execution, this method is called
     instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

    
    /*
     Called as part of the transition from the background to the inactive state;
     here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    ofSetFrameRate(30);
    
    if (myApp!=nil) {
        myApp->recogPintch->pinching=false;
        [mySsAppViewController viewDidAppear:YES];
        }
    /*
     Restart any tasks that were paused (or not yet started) while the
     application was inactive. If the application was previously in the
     background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void) dealloc {
    self.navigationController = nil;
    [super dealloc];
}

@end
