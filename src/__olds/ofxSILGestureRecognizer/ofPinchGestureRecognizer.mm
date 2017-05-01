//
//  ofPinchGestureRecognizer.m
//  xmlSettingsExample
//
//  Created by base on 30/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ofPinchGestureRecognizer.h"
#include "ofPinchEvent.h"

extern ofEvent<ofPinchEventArgs> pinchEvent;

@implementation ofPinchGestureRecognizer

-(id)initWithView:(UIView*)view{  
    if((self = [super init])){  
        pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];  
        [view addGestureRecognizer:pinchGestureRecognizer];  
    }  
    return self;  
}  

-(void)handleGesture:(UIPinchGestureRecognizer *) gestureRecognizer{  
//    if([gestureRecognizer state] == UIGestureRecognizerStateRecognized){
//        NSLog(@"pinches!");
		ofPinchEventArgs p([gestureRecognizer scale], [gestureRecognizer velocity]);
		ofNotifyEvent(pinchEvent, p);
 //   }
}  

-(void)dealloc{  
    [pinchGestureRecognizer release];  
    [super dealloc];  
}  


@end
