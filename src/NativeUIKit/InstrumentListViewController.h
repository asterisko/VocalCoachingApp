//
//  ColorPickerViewController.h
//  MathMonsters
//
//  Created by Transferred on 1/12/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstrumentListDelegate <NSObject>

@required
-(void)selectedInstrument:(NSString *)newInstrument;
@end

@interface InstrumentListViewController : UITableViewController

@property (nonatomic, strong) id<InstrumentListDelegate> delegate;
@end
