//
//  CustomAppViewController.m
//  Created by SIL 07/05/13.
//

#import "ssAppViewController.h"
#import "ofxiPhoneExtras.h"
#import "ssApp.h"
#import "mainAppDelegate.h"
//#import "mainAppViewController.h" // 28_03

//#import "MidiApp.h" // 30_03

// Add Email Features
#import <MessageUI/MessageUI.h>

extern ssApp            * myApp;
extern mainAppDelegate  * mainAppDelegatePNT;
ssAppViewController     * mySsAppViewController;

UIColor  * customBlue = [UIColor colorWithRed:0.33 green:0.78 blue:1.0 alpha:1.0];
UIColor  * customGray = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];

//30_03
//UIView                  * view;
//UIView                  * activityIndicatorView2;

@interface ssAppViewController () <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate>
@end

@implementation ssAppViewController {
    UIPopoverController             * popover;
    UIButton                        * buttonRecord;
    UIButton                        * buttonNewRecording; // 28_03
    NSString                        * fileName;
    }

//################## ANDRE - tentar colocar o load e launch app no load view ########################


//- (void)loadView {
//    
//    [super loadView];
//    
//    self.view.backgroundColor = [UIColor clearColor];
//    
//    UIImageView* backgroundView;
//    backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DSGNbkg.png"]] autorelease];
//    [self.view addSubview: backgroundView];
//    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    
//    CGRect scrollViewFrame = CGRectMake(0.f,
//                                        0.f,
//                                        screenRect.size.width,
//                                        screenRect.size.height);
//    
//    UIScrollView* containerView = [[[UIScrollView alloc] initWithFrame:scrollViewFrame] autorelease];
//    
//    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    containerView.showsHorizontalScrollIndicator = NO;
//    containerView.showsVerticalScrollIndicator = YES;
//    containerView.alwaysBounceVertical = NO;            // remove verical drag
//    
//    [self.view addSubview:containerView];
//
//    
//    /////////////////////////////////////////////////////////
//    // 2 - Add Activity Indicator View and lunch in parallel the Singing Studio App
//    /////////////////////////////////////////////////////////
////    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.height;
//    CGFloat screenHeight = screenRect.size.width;
//    
//    cout << "width: " << screenWidth << "height: " << screenHeight << endl; // ANDRE
//    
//    //    screenHeight = 2048;
//    //    screenWidth = 1536;
//    
//    CGFloat boxWidth = screenWidth;  // size of box
//    CGFloat boxHeigth = screenHeight; // size of box
//    
//    CGFloat boxX = screenWidth/2.0 - boxWidth/2.0;  // size of box
//    CGFloat boxY = screenHeight/2.0 - boxHeigth/2.0; // size of box
//    
//    // Create activityIndicator
//    UIActivityIndicatorView *activityIndicatorSwipe = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    activityIndicatorSwipe.center = CGPointMake(boxWidth/2.0, boxHeigth/2.0);
//    activityIndicatorSwipe.color = UIColor.whiteColor;
//    [activityIndicatorSwipe startAnimating];                         //Or whatever UI Change you need to make
//    
//    // Create activityIndicator View
//    activityIndicatorView2 = [[UIView alloc] initWithFrame:CGRectMake(boxX, boxY, boxWidth, boxHeigth)];
//    activityIndicatorView2.opaque = NO;
//    activityIndicatorView2.clipsToBounds = YES;
//    activityIndicatorView2.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
//    //activityIndicatorView.layer.cornerRadius = 8;
//    // Add Swipe to the view
//    [activityIndicatorView2 addSubview:activityIndicatorSwipe];
//    
//    // Create Label Loading...
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/2.0-80, boxHeigth/2.0 - 50 + 20, 160, 100)];
//    label.text = @"Loading...";
//    label.textColor = UIColor.whiteColor;
//    label.backgroundColor = UIColor.clearColor;
//    //label.textAlignment = UITextAlignmentCenter;
//    label.textAlignment = NSTextAlignmentCenter; // ANDRE
//    label.numberOfLines = 0;
//    //label.lineBreakMode = UILineBreakModeWordWrap;
//    label.lineBreakMode = NSLineBreakByWordWrapping; // ANDRE
//    [activityIndicatorView2 addSubview:label];           // Add Label to the view
//    
//    [self.view addSubview:activityIndicatorView2];
//    
////    [self performSelector: @selector(launchSingingStudioApp)    //perform time-consuming tasks
////               withObject: nil
////               afterDelay: 0.1];
//    
//    // [label release];
//    // [activityIndicatorSwipe release];
//}

//- (void) launchSingingStudioApp {
//    NSLog(@"In  launchSingingStudioApp");
//    
//    /////////////////////////////////////////////////////////
//    // 1 - Create new instance of SS
//    /////////////////////////////////////////////////////////
//    ssAppViewController *viewController;
//    
//    myApp = new ssApp();
//    
//    viewController = [[[ssAppViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]
//                                                             app:myApp] autorelease];
//    /////////////////////////////////////////////////////////
//    // 2 - Update the Navigation Controller
//    /////////////////////////////////////////////////////////
//    [self.navigationController pushViewController:viewController animated:YES];
//    
//    /////////////////////////////////////////////////////////
//    // 3 - Remove Activity Indication View From SuperView
//    /////////////////////////////////////////////////////////
//    [activityIndicatorView2 removeFromSuperview];
////    [btn_record setSelected:NO];
////    [btn_record setHighlighted:NO];
//    
//    //   button.highlighted = NO;
//    //   button.selected = NO;
//    
//}



//################## ANDRE ##########################################################################



- (void)viewDidLoad {
    [super viewDidLoad];
    
    mySsAppViewController = self;
    
    ////////////////////////////////////////////////////////////////////
    // SPACER
    ////////////////////////////////////////////////////////////////////
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil
                               action:nil];
    ////////////////////////////////////////////////////////////////////
    // Costumize NavigationBar Buttons
    ///////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////
    // Costumize ToolBar Buttons
    ////////////////////////////////////////////////////////////////////
    // REMOVER a TOOL BAR AQUI CASO NECESSARIO
    mainAppDelegatePNT.navigationController.toolbarHidden=NO;
    ////////////////////////////////////////////////////////////////////
    

    ////////////////////////////////////////////////////////////////////
    // Button Play/Pause
    ////////////////////////////////////////////////////////////////////
    UIImage *imagePlay = [UIImage imageNamed:@"GUI/btn_play_normal.png"];
    UIImage *imagePlaySelected = [UIImage imageNamed:@"GUI/btn_play_.png"];
    _buttonPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonPlay.bounds = CGRectMake( 0, 0, imagePlay.size.width, imagePlay.size.height );
    [_buttonPlay addTarget:self action:@selector(playPauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonPlay setImage:imagePlay         forState:UIControlStateNormal];
    [_buttonPlay setImage:imagePlaySelected forState:UIControlStateSelected];
    
    if (myApp->appWorkingMode==RECORD_MODE)
        _buttonPlay.hidden=YES;
    
    UIBarButtonItem *btn_playPause = [[UIBarButtonItem alloc] initWithCustomView:_buttonPlay];


    ////////////////////////////////////////////////////////////////////
    // Button Stop
    ////////////////////////////////////////////////////////////////////
    UIImage *imageStop = [UIImage imageNamed:@"GUI/btn_stop_.png"];
    UIImage *imageStopHighLi = [UIImage imageNamed:@"GUI/btn_stop_on.png"];
    UIButton *buttonStop = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonStop.bounds = CGRectMake( 0, 0, imageStop.size.width, imageStop.size.height );
    [buttonStop addTarget:self action:@selector(stopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonStop setImage:imageStop forState:UIControlStateNormal];
    [buttonStop setImage:imageStopHighLi forState:UIControlStateHighlighted];
    UIBarButtonItem *btn_stop = [[UIBarButtonItem alloc] initWithCustomView:buttonStop];

    ////////////////////////////////////////////////////////////////////
    // Button Record
    ////////////////////////////////////////////////////////////////////
    UIImage *imageRecord = [UIImage imageNamed:@"GUI/btn_record_.png"];
    UIImage *imageRecordSelected = [UIImage imageNamed:@"GUI/btn_record_on.png"];
    buttonRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonRecord.bounds = CGRectMake( 0, 0, imageRecord.size.width, imageRecord.size.height );
    [buttonRecord addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRecord setImage:imageRecord forState:UIControlStateNormal];
    [buttonRecord setImage:imageRecordSelected forState:UIControlStateSelected];
    
    // Depending on the appWorkingMode hide Record button
    if (myApp->appWorkingMode==PLAY_MODE)
        buttonRecord.hidden=YES;
    
    UIBarButtonItem *btn_record = [[UIBarButtonItem alloc] initWithCustomView:buttonRecord];
    
    
    ////////////////////////////////////////////////////////////////////
    // Button NewRecording
    ////////////////////////////////////////////////////////////////////
    UIImage *imageNewRecording = [UIImage imageNamed:@"GUI/btn_midi_.png"];
    UIImage *imageNewRecordingSelected = [UIImage imageNamed:@"GUI/btn_midi_on.png"];
    //UIButton *buttonNewRecording = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNewRecording = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNewRecording.bounds = CGRectMake( 0, 0, imageNewRecording.size.width, imageNewRecording.size.height );
    [buttonNewRecording addTarget:self action:@selector(newRecordingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //[buttonNewRecording addTarget:self action:@selector(button2Pressed:) forControlEvents:UIControlEventTouchUpInside]; // 28_03
    [buttonNewRecording setImage:imageNewRecording forState:UIControlStateNormal];
    [buttonNewRecording setImage:imageNewRecordingSelected forState:UIControlStateSelected];
    
    // Depending on the appWorkingMode hide New Recording button
    if (myApp->appWorkingMode == RECORD_MODE)
        buttonNewRecording.hidden=YES;
    
    UIBarButtonItem *btn_newRecording = [[UIBarButtonItem alloc] initWithCustomView:buttonNewRecording];

    ////////////////////////////////////////////////////////////////////
    // Labels
    ////////////////////////////////////////////////////////////////////
//    UILabel *labelVolume = [[UILabel alloc] initWithFrame:CGRectMake(100, -40, 60, 44)];
//    labelVolume.text = @"Volume";
//    labelVolume.backgroundColor = [UIColor clearColor];
//    labelVolume.textColor = [UIColor whiteColor];
//    UIBarButtonItem *sliderVolumeLabel = [[UIBarButtonItem alloc] initWithCustomView:labelVolume];

    UIImage *imageLabelVolume = [UIImage imageNamed:@"GUI/lbl_volume.png"];
    UIButton * buttonImageLabelVolume = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonImageLabelVolume.bounds = CGRectMake( 0, 0, imageLabelVolume.size.width, imageLabelVolume.size.height );
    [buttonImageLabelVolume addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [buttonImageLabelVolume setImage:imageLabelVolume forState:UIControlStateNormal];
    [buttonImageLabelVolume setImage:imageLabelVolume forState:UIControlStateHighlighted];
    UIBarButtonItem *sliderVolumeLabel = [[UIBarButtonItem alloc] initWithCustomView:buttonImageLabelVolume];
    
    ////////////////////////////////////////////////////////////////////
    // SLIDERS
    ////////////////////////////////////////////////////////////////////
    UISlider *sliderVolume = [[UISlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 30.0)];
    [sliderVolume addTarget:self action:@selector(sliderVolumeValueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderVolume setBackgroundColor:[UIColor clearColor]];
    sliderVolume.minimumValue = 0.0;
    sliderVolume.maximumValue = 1.0;
    sliderVolume.continuous = YES;
    [sliderVolume setValue:1.0];
    sliderVolume.minimumTrackTintColor = customBlue;
    sliderVolume.maximumTrackTintColor =  [UIColor whiteColor];
    UIBarButtonItem *sliderVolumeBtn = [[UIBarButtonItem alloc] initWithCustomView:sliderVolume];


    //self.toolbarItems = @[spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,btn_playPause,btn_stop,btn_record,spacer,sliderVolumeLabel,sliderVolumeBtn,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,sliderWavLabel,sliderMixerBtn,sliderMidiLabel,spacer,btn_MidiList,spacer,spacer,spacer,spacer,spacer,spacer];
    
    // ANDRE
    self.toolbarItems = @[spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,btn_playPause,btn_stop,btn_record,btn_newRecording,spacer,sliderVolumeLabel,sliderVolumeBtn,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer];

    
   /*
    [btn_playPause release];
    [spacer release];
    [btn_stop release];
    [btn_record release];
    [sliderVolumeLabel release];
    [sliderVolumeBtn release];
    [sliderWavLabel release];
    [sliderMixerBtn release];
    [sliderMidiLabel release];
    [btn_MidiList release];  */
    }

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // ACRESCENTAR AS CENAS DO MENU À MAIN VIEW
    //########################## ANDRE #############################
    
    
    mainAppDelegatePNT.navigationController.navigationBar.topItem.title = @"SingingStudio™ - Menu";
    
    mainAppDelegatePNT.navigationController.toolbar.barTintColor          = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];      // Bottom bar color
    mainAppDelegatePNT.navigationController.navigationBar.barTintColor    = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];      // Top bar color
    mainAppDelegatePNT.navigationController.navigationBar.tintColor       = [UIColor grayColor];    // Text Color

    
    //########################## ANDRE #############################
    
    

    mainAppDelegatePNT.navigationController.navigationBar.topItem.title = [NSString stringWithCString:(myApp->loadFileName+".wav").c_str() encoding:[NSString defaultCStringEncoding]];

    mainAppDelegatePNT.navigationController.navigationBar.opaque  = YES;
    mainAppDelegatePNT.navigationController.toolbar.opaque        = YES;
    mainAppDelegatePNT.navigationController.toolbarHidden         = NO;
    ////////////////////////////////////////////////////////////////////
    
    //[mainAppDelegatePNT.navigationController.toolbar setFrame:CGRectMake(0, 668, 1024, 100)];

    
    mainAppDelegatePNT.navigationController.toolbar.barTintColor          = customGray;               // Bottom bar color
    mainAppDelegatePNT.navigationController.navigationBar.barTintColor    = customGray;               // Top bar color
    mainAppDelegatePNT.navigationController.navigationBar.tintColor       = [UIColor grayColor];      // Text Color
    
    }

//- (
//   void)emailButtonClicked:(id)sender {
//    UIAlertView *alertView = [[UIAlertView alloc]
//                               initWithTitle:@"Warning"
//                               message:@"Select the files you want to send. Note that .wav files may be too large!"
//                               delegate:self
//                               cancelButtonTitle:@"Cancel"
//                               otherButtonTitles:@"Midi", @"Wav", @"Both",nil];
//    [alertView show];
//    [alertView release];
//    }

- (void)playPauseButtonClicked:(id)sender {
    UIButton * btn = ((UIButton *) sender);
    
    if (myApp->appStateMachine->execState == STATE_IDLE){
        myApp->appStateMachine->setNewExecState(STATE_PLAYING);
        [btn setSelected:YES];
        }
    else if (myApp->appStateMachine->execState == STATE_PLAYING){
        myApp->appStateMachine->setNewExecState(STATE_PLAYING_PAUSE);
        [btn setSelected:NO];
        }
    else if (myApp->appStateMachine->execState == STATE_PLAYING_PAUSE){
        myApp->appStateMachine->setNewExecState(STATE_PLAYING);
        [btn setSelected:YES];
        }
    }

- (void)stopButtonClicked:(id)sender {
    if (myApp->appStateMachine->execState == STATE_RECORDING_PAUSE || myApp->appStateMachine->execState == STATE_RECORDING){
        buttonRecord.hidden=YES;
        _buttonPlay.hidden=NO;
        buttonNewRecording.hidden=NO; // 28_03
    }

    myApp->appStateMachine->setNewExecState(STATE_IDLE);
    [_buttonPlay setSelected:NO];
    [buttonRecord setSelected:NO];
    [buttonNewRecording setSelected:NO];
    }


//- (void)newRecordingButtonClicked:(id)sender {
//    
//    UIButton * btn = ((UIButton *) sender);
//    
//    myApp->appStateMachine->setNewExecState(STATE_IDLE);
//    //myApp->appStateMachine->setNewExecState(STATE_RECORDING);
//    _buttonPlay.hidden=YES;
//    buttonRecord.hidden=NO;
//    buttonNewRecording.hidden=YES;
//        
//    [btn setSelected:YES];
//
//}

- (void)newRecordingButtonClicked:(id)sender { // 29_03
    
    UIButton * btn = ((UIButton *) sender);
    
    //myApp->exit();
    
    delete myApp->wavFile;
//    delete myApp;
//    
//    ssApp *myApp = new ssApp;
    
    [btn setSelected:YES];
    
    }



- (void)recordButtonClicked:(id)sender {
    
    UIButton * btn = ((UIButton *) sender);

    if (myApp->appStateMachine->execState == STATE_IDLE){
        myApp->appStateMachine->setNewExecState(STATE_RECORDING);
        [btn setSelected:YES];
        }
    else if (myApp->appStateMachine->execState == STATE_RECORDING) {
        myApp->appStateMachine->setNewExecState(STATE_RECORDING_PAUSE);
        [btn setSelected:NO];
        }
    else if (myApp->appStateMachine->execState == STATE_RECORDING_PAUSE) {
        myApp->appStateMachine->setNewExecState(STATE_RECORDING);
        [btn setSelected:YES];
        }
    }

- (void)sliderVolumeValueChanged:(id)sender {
    UISlider * slider = ((UISlider *) sender);
    myApp->ssGui->volume = slider.value;
    slider.minimumTrackTintColor = [UIColor colorWithRed:0.33 green:0.78 blue:1.0 alpha:1.0];
    slider.maximumTrackTintColor =  [UIColor whiteColor];
    }


//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//    if([title isEqualToString:@"Cancel"]){
//        // Do nothing
//        }
//    else {
//        [self displayMailSendFilesComposerSheet:title];
//        }
//    }

- (id) initWithFrame:(CGRect)frame app:(ofxiPhoneApp *)app {
    //ofxiPhoneGetOFWindow()->setOrientation( OF_ORIENTATION_DEFAULT );   //-- default portait orientation.
    ofxiPhoneGetOFWindow()->setOrientation( OF_ORIENTATION_90_LEFT );   //-- landscape left portait ANDRE orientation.
    return self = [super initWithFrame:frame app:app];
    }


// -------------------------------------------------------------------------------
//	handle rotation
// -------------------------------------------------------------------------------
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

