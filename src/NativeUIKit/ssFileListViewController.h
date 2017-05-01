//
//  SSViewController.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/18/13.
//
//

#import <UIKit/UIKit.h>

// Tell the compiler to conform to these protocols
@interface ssFileListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
@property (strong, nonatomic) NSIndexPath  * indexPathToBeDeleted;
@property (strong, nonatomic) NSString     * sendThisFile;
@property (strong, nonatomic) NSString     * fileType;
@end

