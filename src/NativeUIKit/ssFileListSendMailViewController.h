//
//  SSViewController.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/18/13.
//
//

#import <UIKit/UIKit.h>

// Tell the compiler to conform to these protocols
@interface ssFileListSendMailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSIndexPath *indexPathToBeDeleted;
@end

