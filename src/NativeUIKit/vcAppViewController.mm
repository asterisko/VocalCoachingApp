//
//  vcAppViewController.m
//  MasterStuffs
//
//  Created by Coaching Vocal on 31/03/2017.
//
//

#import "vcAppDelegate.h"
#import "vcLoadingViewController.h"
#import "vcAppViewController.h"

#import "ssApp.h"
#import "MidiApp.h"

#import "ofxiPhoneExtras.h"


extern ssApp            * myApp;
extern vcAppDelegate    * vcAppDelegatePNT;
vcAppViewController     * myVcAppViewController;

UIColor  * customBlue = [UIColor colorWithRed:0.33 green:0.78 blue:1.0 alpha:1.0];
UIColor  * customGray = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];

@interface vcAppViewController () <UINavigationControllerDelegate>
@end

@implementation vcAppViewController {
    UIPopoverController             * popover;
    UIButton                        * buttonRecord;
//    UIButton                        * buttonNewRecording; // Added 28_03
    NSString                        * fileName;
}



////////////////////////////////////////////////////////////////////
//
//  VIEW CONTROLLERS DEFAULT METHODS
//
////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cout << "[View Did Load] Entering" << endl;
    
    myVcAppViewController = self;
    
    ////////////////////////////////////////////////////////////////////
    // SPACER
    ////////////////////////////////////////////////////////////////////
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil
                               action:nil];
    ////////////////////////////////////////////////////////////////////
    // NAVBAR BUTTONS
    ////////////////////////////////////////////////////////////////////
    
    // REMOVER a TOOL BAR AQUI CASO NECESSARIO
    vcAppDelegatePNT.navigationController.toolbarHidden=NO;
    ////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////
    // TOOLBAR BUTTONS
    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    // Button Play/Pause
    ////////////////////////////////////////////////////////////////////
//    UIImage *imagePlay = [UIImage imageNamed:@"GUI/btn_play_normal.png"];
//    UIImage *imagePlaySelected = [UIImage imageNamed:@"GUI/btn_play_.png"];
//    _buttonPlay = [UIButton buttonWithType:UIButtonTypeCustom];
//    _buttonPlay.bounds = CGRectMake( 0, 0, imagePlay.size.width, imagePlay.size.height );
//    [_buttonPlay addTarget:self action:@selector(playPauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [_buttonPlay setImage:imagePlay         forState:UIControlStateNormal];
//    [_buttonPlay setImage:imagePlaySelected forState:UIControlStateSelected];
//    
//    if (myApp->appWorkingMode==RECORD_MODE)
//        _buttonPlay.hidden=YES;
//    
//    UIBarButtonItem *btn_playPause = [[UIBarButtonItem alloc] initWithCustomView:_buttonPlay];
    
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
    UIImage *imageRecord = [UIImage imageNamed:@"GUI/start_button.png"];
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
    // Button New Recording
    ////////////////////////////////////////////////////////////////////
//    UIImage *imageNewRecording = [UIImage imageNamed:@"GUI/btn_midi_.png"];
//    UIImage *imageNewRecordingSelected = [UIImage imageNamed:@"GUI/btn_midi_on.png"];
//    //UIButton *buttonNewRecording = [UIButton buttonWithType:UIButtonTypeCustom];
//    buttonNewRecording = [UIButton buttonWithType:UIButtonTypeCustom];
//    buttonNewRecording.bounds = CGRectMake( 0, 0, imageNewRecording.size.width, imageNewRecording.size.height );
//    [buttonNewRecording addTarget:self action:@selector(newRecordingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    //[buttonNewRecording addTarget:self action:@selector(button2Pressed:) forControlEvents:UIControlEventTouchUpInside]; // 28_03
//    [buttonNewRecording setImage:imageNewRecording forState:UIControlStateNormal];
//    [buttonNewRecording setImage:imageNewRecordingSelected forState:UIControlStateSelected];
//    
//    // Depending on the appWorkingMode hide Record button
//    //if (myApp->appStateMachine->execState == STATE_RECORDING || myApp->appStateMachine->execState == STATE_RECORDING_PAUSE)
//    if (myApp->appWorkingMode == RECORD_MODE)
//        buttonNewRecording.hidden=YES;
//    
//    UIBarButtonItem *btn_newRecording = [[UIBarButtonItem alloc] initWithCustomView:buttonNewRecording];

    
    ////////////////////////////////////////////////////////////////////
    // LABEL VOLUME
    ////////////////////////////////////////////////////////////////////
    
//    UIImage *imageLabelVolume = [UIImage imageNamed:@"GUI/lbl_volume.png"];
//    UIButton * buttonImageLabelVolume = [UIButton buttonWithType:UIButtonTypeCustom];
//    buttonImageLabelVolume.bounds = CGRectMake( 0, 0, imageLabelVolume.size.width, imageLabelVolume.size.height );
//    [buttonImageLabelVolume addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
//    [buttonImageLabelVolume setImage:imageLabelVolume forState:UIControlStateNormal];
//    [buttonImageLabelVolume setImage:imageLabelVolume forState:UIControlStateHighlighted];
//    UIBarButtonItem *sliderVolumeLabel = [[UIBarButtonItem alloc] initWithCustomView:buttonImageLabelVolume];
    
    
    ////////////////////////////////////////////////////////////////////
    // SLIDER VOLUME
    ////////////////////////////////////////////////////////////////////
//    UISlider *sliderVolume = [[UISlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 30.0)];
//    [sliderVolume addTarget:self action:@selector(sliderVolumeValueChanged:) forControlEvents:UIControlEventValueChanged];
//    [sliderVolume setBackgroundColor:[UIColor clearColor]];
//    sliderVolume.minimumValue = 0.0;
//    sliderVolume.maximumValue = 1.0;
//    sliderVolume.continuous = YES;
//    [sliderVolume setValue:1.0];
//    sliderVolume.minimumTrackTintColor = customBlue;
//    sliderVolume.maximumTrackTintColor =  [UIColor whiteColor];
//    UIBarButtonItem *sliderVolumeBtn = [[UIBarButtonItem alloc] initWithCustomView:sliderVolume];
    

    ////////////////////////////////////////////////////////////////////
    // TOOLBAR ITEMS
    ////////////////////////////////////////////////////////////////////
//    self.toolbarItems = @[spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,btn_playPause,btn_stop,btn_record,btn_newRecording,spacer,sliderVolumeLabel,sliderVolumeBtn,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer];
    
    self.toolbarItems = @[spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,btn_record,btn_stop,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer];

}

- (void)viewWillAppear:(BOOL)animated {
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    cout << "[View Did Appear] Entering App" << endl;
    
    self.navigationController.navigationBar.hidden = YES;
    
//    self.navigationController.navigationBar.topItem.title = @"Vocal Coach";
    
//    self.navigationController.navigationBar.topItem.title = [NSString stringWithCString:(myApp->loadFileName+".wav").c_str() encoding:[NSString defaultCStringEncoding]];
    
//    self.navigationController.navigationBar.opaque  = YES;
    self.navigationController.toolbar.opaque        = YES;
    self.navigationController.toolbarHidden         = NO;
    
    self.navigationController.toolbar.barTintColor          = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];      // Bottom bar color
//    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];      // Top bar color
//    self.navigationController.navigationBar.tintColor       = [UIColor grayColor];    // Text Color
}


////////////////////////////////////////////////////////////////////
//
//  BUTTON AND SLIDER METHODS
//
////////////////////////////////////////////////////////////////////

//- (void)playPauseButtonClicked:(id)sender {
//    UIButton * btn = ((UIButton *) sender);
//    
//    if (myApp->appStateMachine->execState == STATE_IDLE){
//        myApp->appStateMachine->setNewExecState(STATE_PLAYING);
//        [btn setSelected:YES];
//    }
//    else if (myApp->appStateMachine->execState == STATE_PLAYING){
//        myApp->appStateMachine->setNewExecState(STATE_PLAYING_PAUSE);
//        [btn setSelected:NO];
//    }
//    else if (myApp->appStateMachine->execState == STATE_PLAYING_PAUSE){
//        myApp->appStateMachine->setNewExecState(STATE_PLAYING);
//        [btn setSelected:YES];
//    }
//}

- (void)stopButtonClicked:(id)sender {
    if (myApp->appStateMachine->execState == STATE_RECORDING_PAUSE || myApp->appStateMachine->execState == STATE_RECORDING){
        buttonRecord.hidden=NO;
//        _buttonPlay.hidden=NO;
//        buttonNewRecording.hidden=NO; // 28_03
    }
    
    myApp->appStateMachine->setNewExecState(STATE_IDLE);
    
//    [_buttonPlay setSelected:NO];
    [buttonRecord setSelected:NO];
//    [buttonNewRecording setSelected:NO];
}

// NEW RECORDING BUTTON

//- (void)newRecordingButtonClicked: (id)sender {
//    
//    cout << "New Recording button clicked" << endl;
//    
//    UIButton * btn = ((UIButton *) sender);
//    
//    // NOT SURE ABOUT THIS
//    delete myApp;
//    
//    ssApp * myApp;
//    
//    myApp = new ssApp();
//    
//    // ANDRE: not sure about whether I should re-initialize a vcAppViewController or a vcLoadingViewController
//    
//    
//    ///////////////////////////
//    // vcLoadingViewController
//    ///////////////////////////
//    
////    vcLoadingViewController *newLoadingViewController;
////    
////    newLoadingViewController =  [[[vcLoadingViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]
////                                                                            app:myApp] autorelease];
////    
////    [self.navigationController pushViewController:newLoadingViewController animated:YES];
//    
//    
//    
//    //////////////////////////
//    // vcAppViewController
//    //////////////////////////
//    
//    vcAppViewController *newViewController;
//
//    newViewController = [[[vcAppViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]
//                                                             app:myApp] autorelease];
//
//    [self.navigationController pushViewController:newViewController animated:YES];
//    
//    
//    [btn setSelected:YES];
//}

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

//- (void)newRecordingButtonClicked:(id)sender { // 29_03
//    
//    UIButton * btn = ((UIButton *) sender);
//    
//    //myApp->exit();
//    
//    delete myApp->wavFile;
//    //    delete myApp;
//    //
//    //    ssApp *myApp = new ssApp;
//    
//    [btn setSelected:YES];
//    
//}

- (void)recordButtonClicked:(id)sender {
    
    UIButton * btn = ((UIButton *) sender);
    
    if (myApp->appStateMachine->execState == STATE_IDLE){
        myApp->appStateMachine->setNewExecState(STATE_RECORDING);
        myApp->appWorkingMode = RECORD_MODE;
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

//- (void)sliderVolumeValueChanged:(id)sender {
//    UISlider * slider = ((UISlider *) sender);
//    myApp->ssGui->volume = slider.value;
//    slider.minimumTrackTintColor = [UIColor colorWithRed:0.33 green:0.78 blue:1.0 alpha:1.0];
//    slider.maximumTrackTintColor =  [UIColor whiteColor];
//}


- (id) initWithFrame:(CGRect)frame app:(ofxiPhoneApp *)app {
    //ofxiPhoneGetOFWindow()->setOrientation( OF_ORIENTATION_DEFAULT );   //-- default portait orientation.
    ofxiPhoneGetOFWindow()->setOrientation( OF_ORIENTATION_90_LEFT );   //-- landscape left portrait orientation.
    return self = [super initWithFrame:frame app:app];
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
