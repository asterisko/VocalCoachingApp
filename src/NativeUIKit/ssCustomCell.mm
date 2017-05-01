//
//  SSCustomCell.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/18/13.
//
//

#import "ssCustomCell.h"

#import <MessageUI/MessageUI.h>
#import "ssFileListSendMailViewController.h"

@implementation ssCustomCell

@synthesize filenameLabel = _filenameLabel;
@synthesize infoLabel = _infoLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UIColor *clearC = [UIColor clearColor];
    
    self.backgroundColor = clearC;
    
    
    if (self) {
        // configure control(s)
        self.filenameLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 20, 900, 40)];
        self.filenameLabel.backgroundColor = clearC ;
        self.filenameLabel.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.filenameLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:32.0f];
        
        [self addSubview:self.filenameLabel];

        self.infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 55, 900, 40)];
        self.infoLabel.backgroundColor = clearC;
        self.infoLabel.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.infoLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0f];
        
        [self addSubview:self.infoLabel];
        }
    return self;
    }

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    NSLog (@"setHighlighted:%@ animated:%@", (highlighted?@"YES":@"NO"), (animated?@"YES":@"NO"));
}

@end