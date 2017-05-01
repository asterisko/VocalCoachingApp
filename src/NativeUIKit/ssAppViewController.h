//
//  CustomAppViewController.h
//  Created by SIL 07/05/13.
//

//#import "ofxiPhoneViewController.h"
#import "ofxiOSViewController.h" // ANDRE
#import "InstrumentListViewController.h"

// @interface ssAppViewController : ofxiPhoneViewController <InstrumentListDelegate>
@interface ssAppViewController : ofxiOSViewController <InstrumentListDelegate>


@property (strong, nonatomic) UIButton     * buttonPlay;
@property (strong, nonatomic) NSString     * sendThisFile;
@property (strong, nonatomic) UIColor      * customBlue;
@property (strong, nonatomic) UIColor      * customGray;
@end
