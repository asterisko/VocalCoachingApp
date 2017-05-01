//
//  SSViewController.m
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/18/13.
//
//
#import <AVFoundation/AVFoundation.h>
#import "ssAppViewController.h"
#import "ssCustomCell.h"

#import "ssApp.h"
#import "ofMain.h"

// Mail Stuff
#import <MessageUI/MessageUI.h>
#import "ssFileListSendMailViewController.h"
#import "MessageComposerViewController.h"


extern ssApp * myApp;


@interface ssFileListSendMailViewController()

@end

@implementation ssFileListSendMailViewController {
    UITableView        * tableView;
    ssCustomCell       * lastSelectedCell;
    NSMutableArray     * wavFiles;
    NSString           * fileName;
    UIView             * activityIndicatorView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    
    UIImageView* backgroundView;
    backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DSGNbkg.png"]] autorelease];
    [self.view addSubview: backgroundView];

    
    /////////////////////////////////////////////////////////
    // 1 - Init table view
    /////////////////////////////////////////////////////////
    tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];

    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];

    tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);                                              // Let it scroll to the last cell
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;     // Resize TableView in Landscape mode
    /////////////////////////////////////////////////////////
    // 2 - Get List of Files in Documents Dir
    /////////////////////////////////////////////////////////
    NSArray  * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSArray  * dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
   
    // Filter by type : .wav
    NSArray *extensions = [NSArray arrayWithObjects:@"wav", nil];
    NSArray *auxFilenames = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensions]];
    
    wavFiles = [(NSArray*)auxFilenames mutableCopy];
    
    /////////////////////////////////////////////////////////
    // 3 - Add editing Button to the TabNavigator (TOP-RIGHT)
    /////////////////////////////////////////////////////////
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    
    lastSelectedCell = nil;
    
    /////////////////////////////////////////////////////////
    // 4 - Add Subview to canvas
    /////////////////////////////////////////////////////////
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return [wavFiles count];
}

// Force the Cell Heigth to a fixed Value
- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.width;

    return screenHeight/8;
}
// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    
    /////////////////////////////////////////////////////////
    // 1 - Get Filename and add it to UITableViewCell
    /////////////////////////////////////////////////////////
    ssCustomCell *cell = (ssCustomCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ssCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;    // Add Disclosure Button
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
     //   cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];

    }
    
    cell.filenameLabel.text = [NSString stringWithFormat:@"%@",[wavFiles objectAtIndex:indexPath.row]];
    
    /////////////////////////////////////////////////////////
    // 2 - Get WavFile Settings, i.e Duration, SampleRate and BitDepth
    /////////////////////////////////////////////////////////
    // Get File URL
    NSString *filePath = ofxStringToNSString(ofxiPhoneGetDocumentsDirectory());
    NSString *filename =  [wavFiles objectAtIndex:indexPath.row];
    NSString *fullfilepath = [filePath stringByAppendingString:filename];

    // Get File Duration throught AVAudioPlayer
    AVAudioPlayer * sound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fullfilepath] error:nil];
    // NSLog([NSString stringWithFormat:@"%f", sound.duration]);
    // Convert to HH:mm:ss format
    NSUInteger audioDurationSeconds = sound.duration;
    NSUInteger dHours = floor(audioDurationSeconds / 3600);
    NSUInteger dMinutes = floor(audioDurationSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(audioDurationSeconds % 3600 % 60);
    
    NSString *strTimeDuration = [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];

    // Get File Setting throught AVAudioPlayer
//    NSString * sampleRate = [sound.settings sampleRatevalueForKey:AVSampleRateKey];
//    NSString * PCMBitDepth = [sound.settings valueForKey:AVLinearPCMBitDepthKey];
//    NSString * PCMIsNonInterleaved = [sound.settings valueForKey:AVLinearPCMIsNonInterleaved];

    /////////////////////////////////////////////////////////
    // 2 - Get Generic File Metadata, i.e. Filesize and CreationDate
    /////////////////////////////////////////////////////////
    // Get File Data Creation Date 
    NSFileManager* filemanager = [NSFileManager defaultManager];
    NSDictionary* attrs = [filemanager attributesOfItemAtPath:fullfilepath error:nil];
    NSDate *creationDate = (NSDate*)[attrs objectForKey: NSFileCreationDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    NSString *strCreationDate = [formatter stringFromDate:creationDate];
    
    unsigned long long size = [attrs fileSize];
    NSString *strFileSizeMB = [NSString stringWithFormat:@"%02.02f",(float) size/1024/1024]; // Result in Megabytes
    
    NSString *strAux = [@"Duration: " stringByAppendingString:strTimeDuration];

              strAux = [strAux stringByAppendingString:@"            WAV/PCM | 22050Hz | 16bits | Mono            Creation Date: " ];

              strAux = [strAux stringByAppendingString:strCreationDate];

              strAux = [strAux stringByAppendingString:@"            Size: "];
    
              strAux = [strAux stringByAppendingString:strFileSizeMB];
    
              strAux = [strAux stringByAppendingString:@" Mb"];
    
    cell.infoLabel.text = strAux;
    
    return cell;
}

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %d row", indexPath.row);
    
    // Add Disclosure Button to Selected Cell
    ssCustomCell *cell = (ssCustomCell *)[_tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;    // Add Disclosure Button
    
    if (lastSelectedCell != nil && cell !=lastSelectedCell)
        {
        // Remove Disclosure Button
        lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;             
        }

    // Update last selected cell index
    lastSelectedCell = cell;

    // Change Cell Background Color
//    cell.contentView.backgroundColor = [UIColor clearColor];
//    example: [UIColor colorWithRed:(100) green:(200) blue:(100) alpha:(.8)];
}

- (void)tableView:(UITableView *)_tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath
{
    NSLog(@"selected %d row", indexPath.row);
    
    /////////////////////////////////////////////////////////
    // 1 - Get Filename of Selected Row when clicking in its Closure Button
    /////////////////////////////////////////////////////////
    ssCustomCell *cell = (ssCustomCell *)[_tableView cellForRowAtIndexPath:indexPath];
    fileName = cell.filenameLabel.text;

    MessageComposerViewController * myMessageComposerViewController;
    
    myMessageComposerViewController = [[MessageComposerViewController alloc] init];
        
    [self.navigationController pushViewController:myMessageComposerViewController animated:YES];
    self.navigationController.navigationBar.topItem.title = @"Send Midi File";

}

- (void) launchSingingStudioApp
{
    NSLog(@"In  launchSingingStudioApp");
    
    /////////////////////////////////////////////////////////
    // 1 - Create new instance of SS
    /////////////////////////////////////////////////////////
    ssAppViewController *viewController;
    
    myApp = new ssApp(ofxNSStringToString(fileName));
    viewController = [[[ssAppViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                             app:myApp] autorelease];
    /////////////////////////////////////////////////////////
    // 2 - Update the Navigation Controller
    /////////////////////////////////////////////////////////
    [self.navigationController pushViewController:viewController animated:YES];
    self.navigationController.navigationBar.topItem.title = fileName;
    
    /////////////////////////////////////////////////////////
    // 3 - Remove Activity Indication View From SuperView
    /////////////////////////////////////////////////////////
    [activityIndicatorView removeFromSuperview];

}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    /////////////////////////////////////////////////////////
    // 1 - Manage Editing mode
    /////////////////////////////////////////////////////////
    [super setEditing:editing animated:animated];
    [tableView setEditing:editing animated:animated];

    if (editing)
        {
        NSLog(@"editMode on");
        self.editButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel");
        [tableView setEditing:TRUE];
        }
    else {
        NSLog(@"editMode off");
        self.editButtonItem.title = NSLocalizedString(@"Edit", @"Edit");
        [tableView setEditing:FALSE];
        }
}

// REMOVE DELETE SWIPE BUTTON
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return self.editing ;
//}


- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Removing file from Documents Directory");
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.indexPathToBeDeleted = indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning! The file will be permanently deleted."
                                                        message:@"Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
        [alert show];
        // do not delete it here. So far the alter has not even been shown yet. It will not been shown to the user before this current method is finished.
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This method is invoked in response to the user's action. The altert view is about to disappear (or has been disappeard already - I am not sure)
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"NO"])
    {
        NSLog(@"Nothing to do here");
    }
    else if([title isEqualToString:@"YES"])
    {
        NSLog(@"Delete the cell");
    
        /////////////////////////////////////////////////////////
        // 1- Delete File from the Documents Folder
        /////////////////////////////////////////////////////////
        NSString *filePath = ofxStringToNSString(ofxiPhoneGetDocumentsDirectory());
        NSString *filename =  [wavFiles objectAtIndex:[self.indexPathToBeDeleted row]];
        NSString *fullfilepath = [filePath stringByAppendingString:filename];
        
        // you need to write a function to get to that directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath])
        {
            NSError *error;
            if (![fileManager removeItemAtPath:fullfilepath error:&error])
            {
                NSLog(@"Error removing file: %@", error);
            };
        }
        
        /////////////////////////////////////////////////////////
        // 2 - Remove the Correspondent row from data model
        /////////////////////////////////////////////////////////
        [wavFiles removeObjectAtIndex:[self.indexPathToBeDeleted row]];
        
        /////////////////////////////////////////////////////////
        // 3 - Request table view to reload
        /////////////////////////////////////////////////////////
        [tableView reloadData];
    }
}

@end