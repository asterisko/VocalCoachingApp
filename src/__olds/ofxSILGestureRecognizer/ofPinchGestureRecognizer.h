//
//  ofPinchGestureRecognizer.h
//  xmlSettingsExample
//
//  Created by base on 30/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>  


@interface ofPinchGestureRecognizer : NSObject {

	UIPinchGestureRecognizer *pinchGestureRecognizer;  
}

-(id)initWithView:(UIView*)view; 
- (void)handleGesture:(UIPinchGestureRecognizer *)gestureRecognizer;

@end
