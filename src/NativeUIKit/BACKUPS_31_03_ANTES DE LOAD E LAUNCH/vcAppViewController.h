//
//  Header.h
//  MasterStuffs
//
//  Created by Coaching Vocal on 31/03/2017.
//
//

#import <UIKit/UIKit.h>

#import "ofxiOSViewController.h" // ANDRE
#import "InstrumentListViewController.h"

//@interface mainAppViewController : UIViewController <UITableViewDataSource> {
//    
//}

@interface vcAppViewController : ofxiOSViewController <InstrumentListDelegate>

@property (strong, nonatomic) UIButton     * buttonPlay;
@property (strong, nonatomic) NSString     * sendThisFile;
@property (strong, nonatomic) UIColor      * customBlue;
@property (strong, nonatomic) UIColor      * customGray;

//@property (nonatomic, retain) UITableView * tableView;

@end
