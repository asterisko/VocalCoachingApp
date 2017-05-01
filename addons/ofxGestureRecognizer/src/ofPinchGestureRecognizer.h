/*
 *  ofPinchGestureRecognizer.h
 *
 *  Created by Ryan Raffa on 5/13/12
 *  Updated 12/1/12
 *  Based on example code by http://www.daanvanhasselt.com
 *
 */

#import <Foundation/Foundation.h>  

typedef enum {
    PinchAxisNone,
    PinchAxisHorizontal,
    PinchAxisVertical
} PinchAxis;


@interface ofPinchGestureRecognizer : NSObject {  
    UIPinchGestureRecognizer *pinchGestureRecognizer;  

@public
    CGFloat                scale;
    CGFloat                lastScale;
    BOOL                   pinching;
    PinchAxis              direction;
    NSInteger              lastTouchPosition;
    CGFloat                distX;
    CGFloat                distY;
    CGFloat                touchMinY;
}

@property(assign,nonatomic) BOOL cancelsTouchesInView;

-(id)initWithView:(UIView*)view;  
-(void)handlePinch:(UIPinchGestureRecognizer *) gr;  

@end