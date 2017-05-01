//
//  vcAppViewController.m
//  MasterStuffs
//
//  Created by Coaching Vocal on 31/03/2017.
//
//

//#import <Foundation/Foundation.h>

#import "vcAppViewController.h"
#import "ofxiPhoneExtras.h"
#import "ssApp.h"
#import "MidiApp.h"
#import "vcAppDelegate.h"

// ???
UIView                  * view;
UIView                  * activityIndicatorView2;

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
    UIButton                        * buttonNewRecording; // 28_03
    NSString                        * fileName;
}

// TIRADO DO MAIN APP VIEW CONTROLLER (PRECISA PROVAVELMENTE DE ALTERAÇÕES)
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
    
     //31_03 CONTAINER VIEW not sure about that
    
    UIScrollView* containerView = [[[UIScrollView alloc] initWithFrame:scrollViewFrame] autorelease];
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    containerView.showsHorizontalScrollIndicator = YES; // 31_03 (alterado de NO para YES)
    containerView.showsVerticalScrollIndicator = YES;
    containerView.alwaysBounceVertical = NO;            // remove verical drag
    
    [self.view addSubview:containerView];

    
}

// TIRADO DO SS APP VIEW CONTROLLER
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    // LABEL VOLUME
    ////////////////////////////////////////////////////////////////////
    
    UIImage *imageLabelVolume = [UIImage imageNamed:@"GUI/lbl_volume.png"];
    UIButton * buttonImageLabelVolume = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonImageLabelVolume.bounds = CGRectMake( 0, 0, imageLabelVolume.size.width, imageLabelVolume.size.height );
    [buttonImageLabelVolume addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [buttonImageLabelVolume setImage:imageLabelVolume forState:UIControlStateNormal];
    [buttonImageLabelVolume setImage:imageLabelVolume forState:UIControlStateHighlighted];
    UIBarButtonItem *sliderVolumeLabel = [[UIBarButtonItem alloc] initWithCustomView:buttonImageLabelVolume];
    
    
    ////////////////////////////////////////////////////////////////////
    // SLIDER VOLUME
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
    

    ////////////////////////////////////////////////////////////////////
    // TOOLBAR ITEMS
    ////////////////////////////////////////////////////////////////////
    self.toolbarItems = @[spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,btn_playPause,btn_stop,btn_record,spacer,sliderVolumeLabel,sliderVolumeBtn,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer,spacer];
    

}

- (void)viewWillAppear:(BOOL)animated {
    
}

// PENSO QUE É NECESSÁRIO USAR SELF E NAO VC APP DELEGATE PNT
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.navigationController.navigationBar.topItem.title = @"VocalCoach™";
    
    self.navigationController.navigationBar.topItem.title = [NSString stringWithCString:(myApp->loadFileName+".wav").c_str() encoding:[NSString defaultCStringEncoding]];
    
    self.navigationController.navigationBar.opaque  = YES;
    self.navigationController.toolbar.opaque        = YES;
    self.navigationController.toolbarHidden         = NO;
    
    self.navigationController.toolbar.barTintColor          = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];      // Bottom bar color
    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];      // Top bar color
    self.navigationController.navigationBar.tintColor       = [UIColor grayColor];    // Text Color
}

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

// NEW RECORDING BUTTON (EDITAR)

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


// DE SS APP VIEW CONTROLLER
- (id) initWithFrame:(CGRect)frame app:(ofxiPhoneApp *)app {
    //ofxiPhoneGetOFWindow()->setOrientation( OF_ORIENTATION_DEFAULT );   //-- default portait orientation.
    ofxiPhoneGetOFWindow()->setOrientation( OF_ORIENTATION_90_LEFT );   //-- landscape left portait ANDRE orientation.
    return self = [super initWithFrame:frame app:app];
}

// ROTATIONS
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
