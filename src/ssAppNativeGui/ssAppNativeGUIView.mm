//
//  ssAppNativeGUIView.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/18/13.
//
//

#include "ofxiPhoneExtras.h"
#import "ssAppNativeGUIView.h"
#import "ssApp.h"

extern ssApp *myApp;

@interface ssAppNativeGUIView ()

@end

@implementation ssAppNativeGUIView

@synthesize mySlider, myStepSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //set the view background to white
    self.view.backgroundColor = [UIColor clearColor];
    
    //frame for the slider
    CGRect myFrame = CGRectMake(100.0f, 100.0f, 250.0f, 25.0f);
    //create and initialize the slider
    self.mySlider = [[UISlider alloc] initWithFrame:myFrame];
    //set the minimum value
    self.mySlider.minimumValue = 0.0f;
    //set the maximum value
    self.mySlider.maximumValue = 100.0f;
    //set the initial value
    self.mySlider.value = 25.0f;
    
    //set this to true if you want the changes in the sliders value
    //to generate continuous update events
    [self.mySlider setContinuous:false];
    
    //attach action so that you can listen for changes in value
    [self.mySlider addTarget:self
                      action:@selector(getSliderValue:)
            forControlEvents:UIControlEventValueChanged];
    //add the slider to the view
    [self.view addSubview:self.mySlider];
    
    
    //move the origin for the Step Slider
    myFrame.origin.y += myFrame.size.height + 20.0f;
    self.myStepSlider = [[UISlider alloc] initWithFrame:myFrame];
    self.myStepSlider.minimumValue = 0.0f;
    self.myStepSlider.maximumValue = 100.0f;
    self.myStepSlider.value = 30.0f;
    [self.myStepSlider setContinuous:false];
    [self.myStepSlider addTarget:self
                          action:@selector(getSliderValue:)
                forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.myStepSlider];

    self.view.userInteractionEnabled=true;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // If the hitView is THIS view, return the view that you want to receive the touch instead:
    if (hitView == self) {
        return nil;
    }
    // Else return the hitView (as it could be one of this view's buttons):
    return hitView;
}

- (void) getSliderValue:(UISlider *)paramSender{
    
    //if this is my Step Slider then change the value
    if ([paramSender isEqual:self.myStepSlider]){
        float newValue = paramSender.value /10;
        paramSender.value = floor(newValue) * 10;
        }
    NSLog(@"Current value of slider is %f", paramSender.value);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
