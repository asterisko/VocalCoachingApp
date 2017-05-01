//
//  ColorPickerViewController.m
//  MathMonsters
//
//  Created by Transferred on 1/12/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import "InstrumentListViewController.h"

@implementation InstrumentListViewController {
    NSMutableArray *instrumentNames;
    }

#pragma mark - Init
-(id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];

    if (self != nil) {
        //Initialize the array
        instrumentNames = [NSMutableArray array];
        //Set up the array of colors.
        [instrumentNames addObject:@"Piano"];
        [instrumentNames addObject:@"Trombone"];
        [instrumentNames addObject:@"Vibraphone"];
        
        //Make row selections persist.
        self.clearsSelectionOnViewWillAppear = NO;
        
        //Calculate how tall the view should be by multiplying the individual row height
        //by the total number of rows.
        NSInteger rowsCount = [instrumentNames count];
        NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSInteger totalRowsHeight = rowsCount * singleRowHeight;
        
        //Calculate how wide the view should be by finding how wide each string is expected to be
        CGFloat largestLabelWidth = 0;
        for (NSString *colorName in instrumentNames) {
            //Checks size of text using the default font for UITableViewCell's textLabel. 
            CGSize labelSize = [colorName sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]];
            if (labelSize.width > largestLabelWidth) {
                largestLabelWidth = labelSize.width;
                }
            }
        
        //Add a little padding to the width
        CGFloat popoverWidth = largestLabelWidth + 100;
        
        //Set the property to tell the popover container how big this view will be.
        self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, totalRowsHeight);
        }
    return self;
    }

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:[self tableView] didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    }

- (void)viewWillAppear:(BOOL)animated {
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    }

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
    }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [instrumentNames count];
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    
    // Configure the cell...
    NSString *strAux =  [instrumentNames objectAtIndex:indexPath.row];
    cell.textLabel.text = strAux;

    return cell;
    }

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected %d row", indexPath.row);
    
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString *selectedInstrumentName = cell.textLabel.text;
    
    // Change cell text and symbols color
    [cell setTintColor:[UIColor whiteColor]];
    
    // Change Selected BackGround
    UIView *selectionBackground = [[UIView alloc] init];
    selectionBackground.backgroundColor = [UIColor colorWithRed:0.33 green:0.78 blue:1.0 alpha:1.0];
    cell.selectedBackgroundView = selectionBackground;

    //Notify the delegate if it exists.
    if (_delegate != nil)
        [_delegate selectedInstrument:selectedInstrumentName];
    
//    [selectionBackground release];
    
    }

@end
