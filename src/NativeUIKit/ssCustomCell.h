//
//  SSCustomCell.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/18/13.
//
//

#import <UIKit/UIKit.h>

// extends UITableViewCell
@interface ssCustomCell : UITableViewCell

// now only showing one label, you can add more yourself
@property (nonatomic, strong) UILabel *filenameLabel;
@property (nonatomic, strong) UILabel *infoLabel;

@end
