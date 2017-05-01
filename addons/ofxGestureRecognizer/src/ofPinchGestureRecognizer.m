/*
 *  ofPinchGestureRecognizer.m
 *
 *  Created by Ryan Raffa on 5/13/12.
 *  Based on example code by http://www.daanvanhasselt.com
 *
 */
#import "ofPinchGestureRecognizer.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation ofPinchGestureRecognizer

@synthesize cancelsTouchesInView;

-(id)initWithView:(UIView*)view{  
    if((self = [super init])){  
        pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];  
        [view addGestureRecognizer:pinchGestureRecognizer];  
    }  
    return self;  
}  

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)handlePinch:(UIPinchGestureRecognizer *) gr{
    

    
    if([gr state] == UIGestureRecognizerStateBegan){
        pinching = true;
        lastScale = [gr scale];
    //    NSLog(@"Start Pinch!");
    }
    
    if([gr state] == UIGestureRecognizerStateChanged){
       // scale = [gr scale];
        
        CGFloat currentScale = [[[gr view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 0.5;
        
        scale = 1 -  (lastScale - [gr scale]);
        scale = MIN(scale, kMaxScale / currentScale);
        scale = MAX(scale, kMinScale / currentScale);
    //    CGAffineTransform transform = CGAffineTransformScale([[gr view] transform], scale, scale);
    //    [gr view].transform = transform;
        
        lastScale = [gr scale];  // Store the previous scale factor for the next pinch gesture call

        if(gr.numberOfTouches == 2){
            pinching = true; // force pinching state
            UIView *view = gr.view;
            CGPoint touch0 = [gr locationOfTouch:0 inView:view];
            CGPoint touch1 = [gr locationOfTouch:1 inView:view];
            CGFloat tangent = fabsf((touch1.y - touch0.y) / (touch1.x - touch0.x));
        
            touchMinY =  touch0.y < touch1.y ? touch0.y : touch1.y;

            distX = fabsf(touch1.x - touch0.x);
            distY = fabsf(touch1.y - touch0.y);
            
            if (tangent <= tanf(DEGREES_TO_RADIANS(45.0f)))
                direction = PinchAxisHorizontal;
            else if (tangent >= tanf(DEGREES_TO_RADIANS(45.0f)))
                direction = PinchAxisVertical;
            else direction =  PinchAxisNone;
        }
        //    NSLog(@"SCALE:::::::::::::::::::::::::::::::::::%f", scale);
    }
    
    if([gr state] == UIGestureRecognizerStateEnded){
        pinching = false;
    //    NSLog(@"End Pinch!");
    }
}  

-(void)dealloc{  
    [pinchGestureRecognizer release];  
    [super dealloc];  
}

@end