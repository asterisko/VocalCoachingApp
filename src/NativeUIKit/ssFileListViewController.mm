//
//  SSViewController.m
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/18/13.
//
//
#import <AVFoundation/AVFoundation.h>
#import "ssAppViewController.h"
#import "ssFileListViewController.h"
#import "ssCustomCell.h"

#import "ofMain.h"

#import <MessageUI/MessageUI.h>

#import "mainAppDelegate.h"
#import "ssApp.h"

extern ssApp                * myApp;
extern mainAppDelegate      * mainAppDelegatePNT;
extern ssAppViewController  * mySsAppViewController;

#define kAlertViewOne 1
#define kAlertViewTwo 2

@interface ssFileListViewController () < MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate>
@end

@implementation ssFileListViewController {
    UITableView        * tableView;
    ssCustomCell       * lastSelectedCell;
    NSMutableArray     * wavFiles;
    NSString           * fileName;
    UIView             * activityIndicatorView;
    NSInteger          selectedIndexPath;
    }


- (void)viewDidLoad {
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
    tableView.backgroundColor = [UIColor clearColor];
    
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
    selectedIndexPath = -1;
    /////////////////////////////////////////////////////////
    // 4 - Add Subview to canvas
    /////////////////////////////////////////////////////////
    [self.view addSubview:tableView];
    }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //set statusbar to the desired rotation position
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationLandscapeLeft animated:NO];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO]; // ANDRE
    mainAppDelegatePNT.navigationController.toolbarHidden=YES;
    self.navigationController.navigationBar.topItem.title = @"Load File";
    }

- (void)viewWillAppear:(BOOL)animated {
    }

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    return 1;
    }

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    return [wavFiles count];
    }

// Force the Cell Heigth to a fixed Value
- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.width;
    return screenHeight/8;
    }

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    /////////////////////////////////////////////////////////
    // 1 - Get Filename and add it to UITableViewCell
    /////////////////////////////////////////////////////////
    ssCustomCell *cell = (ssCustomCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[ssCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

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

    //[filePath release];
    //[sound release];

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
    
 //   [formatter release];
    
    unsigned long long size = [attrs fileSize];
    NSString *strFileSizeMB = [NSString stringWithFormat:@"%02.02f",(float) size/1024/1024]; // Result in Megabytes
    
    NSString *strAux = [@"Duration: " stringByAppendingString:strTimeDuration];

              strAux = [strAux stringByAppendingString:@"            WAV/PCM | 22050Hz | 16bits | Mono            Creation Date: " ];

              strAux = [strAux stringByAppendingString:strCreationDate];

              strAux = [strAux stringByAppendingString:@"            Size: "];
    
              strAux = [strAux stringByAppendingString:strFileSizeMB];
    
              strAux = [strAux stringByAppendingString:@" Mb"];
    
    cell.infoLabel.text = strAux;
    
//    if (selectedIndexPath == indexPath.row)
//        {
//        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;    // Add Disclosure Button
        //cell.backgroundColor = [UIColor colorWithRed:(0.38) green:(0.57) blue:(0.41) alpha:(.8)];
//        }
//    else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.backgroundColor = [UIColor clearColor];
//        }
    
    
    /////////////////////////////////////////////////////////
    // Add Email Button Image
    /////////////////////////////////////////////////////////
    UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    emailButton.frame = CGRectMake(885.0f, 15.0f, 60.0f, 40.0f);
    //  emailButton.backgroundColor = [UIColor redColor];
    //   [emailButton setTitle:@"Send" forState:UIControlStateNormal];
    [emailButton addTarget:self action:@selector(myButtonClick:)    forControlEvents:UIControlEventTouchUpInside];
    
    UIImage * image = [UIImage imageNamed:@"images/emailSymbol.png"];
    //    UIImage * newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
    [emailButton setBackgroundImage:image forState:UIControlStateNormal];

    UIImage * imagePressed = [UIImage imageNamed:@"images/emailSymbolDown.png"];
    //    UIImage * newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
    [emailButton setBackgroundImage:imagePressed forState:UIControlStateHighlighted];
    emailButton.tag = indexPath.row;
    emailButton.backgroundColor = [UIColor clearColor];
    [cell addSubview:emailButton];
    
    //[emailButton release];
    
    return cell;
    }

-(void) myButtonClick:(id) sender {
    NSInteger tid = ((UIControl *) sender).tag;
    NSLog(@"you clicked on button with id %d ",tid);
    self.sendThisFile = [NSString stringWithFormat:@"%@",[wavFiles objectAtIndex:tid]];
    UIAlertView *alertView2 = [[UIAlertView alloc]
                          initWithTitle:@"Warning"
                          message:@"Select the files you want to send. Note that .wav files may be too large!"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Midi", @"Wav", @"Both",nil];
    alertView2.tag = kAlertViewTwo;
    [alertView2 show];
    [alertView2 release];
    }

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected %d row", indexPath.row);
    selectedIndexPath = indexPath.row;
    
    // Add Disclosure Button to Selected Cell
    ssCustomCell *cell = (ssCustomCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    // Change UITableViewCellAccessoryDetailButton
    UIImage *openImage = [UIImage imageNamed:@"images/openSymbolDown.png"];
    UIImage *openImageDown = [UIImage imageNamed:@"images/openSymbolDown.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(44.0, 44.0, 44, 44);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchDown];
    [button setImage:openImage forState:UIControlStateNormal];
    [button setImage:openImageDown forState:UIControlStateSelected];
    cell.accessoryView = button;

//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        cell.accessoryType =  UITableViewCellAccessoryDetailButton;
//        }
//    else {
//        cell.accessoryType =  UITableViewCellAccessoryDetailDisclosureButton;
//        }
    
    // Change cell text and symbols color
    [cell setTintColor:[UIColor whiteColor]];

    // Change Selected BackGround
    UIView *selectionBackground = [[UIView alloc] init];
    selectionBackground.backgroundColor = [UIColor colorWithRed:0.33 green:0.78 blue:0.99 alpha:0.7];
    cell.selectedBackgroundView = selectionBackground;
    
    //[selectionBackground release];
    
    if (lastSelectedCell != nil && cell !=lastSelectedCell)
        {
        // Remove Disclosure Button 
        //lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
        lastSelectedCell.accessoryView = nil;
        }
        
    // Update last selected cell index
    lastSelectedCell = cell;
    }

- (void)tapButton:(UIButton *)button {
    [button setSelected:NO];
    ssCustomCell *cell = (ssCustomCell*) button.superview.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)tableView:(UITableView *)_tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath {
    NSLog(@"selected %d row", indexPath.row);
    
    /////////////////////////////////////////////////////////
    // 1 - Get Filename of Selected Row when clicking in its Closure Button
    /////////////////////////////////////////////////////////
    ssCustomCell *cell = (ssCustomCell *)[_tableView cellForRowAtIndexPath:indexPath];
    fileName = cell.filenameLabel.text;

    /////////////////////////////////////////////////////////
    // 2 - Add Activity Indicator View and lunch in parallel the Singing Studio App    
    /////////////////////////////////////////////////////////
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.height;
    CGFloat screenHeight = screenRect.size.width;
    
    CGFloat boxWidth = screenWidth;  // size of box
    CGFloat boxHeigth = screenHeight; // size of box
    
    CGFloat boxX = screenWidth/2.0 - boxWidth/2.0;  // size of box
    CGFloat boxY = screenHeight/2.0 - boxHeigth/2.0; // size of box

    // Create activityIndicator
    UIActivityIndicatorView *activityIndicatorSwipe = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorSwipe.center = CGPointMake(boxWidth/2.0, boxHeigth/2.0);
    activityIndicatorSwipe.color = UIColor.whiteColor;
    [activityIndicatorSwipe startAnimating];                         //Or whatever UI Change you need to make

    // Create activityIndicator View
    activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(boxX, boxY, boxWidth, boxHeigth)];
    activityIndicatorView.opaque = NO;
    activityIndicatorView.clipsToBounds = YES;
    activityIndicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    //activityIndicatorView.layer.cornerRadius = 8;
    // Add Swipe to the view
    [activityIndicatorView addSubview:activityIndicatorSwipe];
    
  // [activityIndicatorSwipe release];
    
    // Create Label Loading...
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/2.0-80, boxHeigth/2.0 - 50 + 20, 160, 100)];
    label.text = @"Loading...";
    label.textColor = UIColor.whiteColor;
    label.backgroundColor = UIColor.clearColor;
    //label.textAlignment = UITextAlignmentCenter;
    label.textAlignment = NSTextAlignmentCenter; // ANDRE
    label.numberOfLines = 0;
    //label.lineBreakMode = UILineBreakModeWordWrap;
    label.lineBreakMode = NSLineBreakByWordWrapping; // ANDRE
    [activityIndicatorView addSubview:label];           // Add Label to the view
    
  //  [label release];
    
    [self.view addSubview:activityIndicatorView];

    [self performSelector: @selector(launchSingingStudioApp)    //perform time-consuming tasks
               withObject: nil
               afterDelay: 0.1];
    }

- (void) launchSingingStudioApp {
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
    //self.navigationController.navigationBar.topItem.title = fileName;
    //self.navigationController.navigationBar.topItem.title = @"Load File";
    
    /////////////////////////////////////////////////////////
    // 3 - Remove Activity Indication View From SuperView
    /////////////////////////////////////////////////////////
    [activityIndicatorView removeFromSuperview];
    
    }

-(void) setEditing:(BOOL)editing animated:(BOOL)animated {
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


- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Removing file from Documents Directory");
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.indexPathToBeDeleted = indexPath;
        
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Warning! The file will be permanently deleted."
                                                        message:@"Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
        alertView1.tag = kAlertViewOne;
        [alertView1 show];
        }
    }

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == kAlertViewOne) { // FIRST ALERT VIEW (ASK TO DELETE FILE)
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:@"NO"]) NSLog(@"Nothing to do here");
        else if([title isEqualToString:@"YES"]){
            NSLog(@"Delete the cell");
            /////////////////////////////////////////////////////////
            // 1- Delete File from the Documents Folder
            /////////////////////////////////////////////////////////
            NSString *filePath = ofxStringToNSString(ofxiPhoneGetDocumentsDirectory());
            NSString *filename =  [wavFiles objectAtIndex:[self.indexPathToBeDeleted row]];
            NSString *fullfilepath = [filePath stringByAppendingString:filename];
            // you need to write a function to get to that directory
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath]){
                NSError *error;
                if (![fileManager removeItemAtPath:fullfilepath error:&error]){
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
    else if(alertView.tag == kAlertViewTwo) { // SECOND ALERT VIEW (ASK TO ATACH FILES TO EMAIL)

        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

        if([title isEqualToString:@"Cancel"]){
            // Do nothing
            }
        else
            [self displayMailSendFilesComposerSheet:title];
        }
    }

// -------------------------------------------------------------------------------
//	displayMailFeedbackComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
- (void) displayMailSendFilesComposerSheet:(NSString*)title {
    NSLog(@"In  ssFileListViewController::displayMailFeedbackComposerSheet");
    
    if([MFMailComposeViewController canSendMail]) {
        // Get Directory path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        // Remove extension from Filename
        fileName = [[self.sendThisFile componentsSeparatedByString: @".wav"] objectAtIndex: 0];
        // Create Mail composer Object
        MFMailComposeViewController *myMailComposer = [[MFMailComposeViewController alloc] init];
        myMailComposer.mailComposeDelegate = self;
        
        // Add Email Subject
        [myMailComposer setSubject:[@"[SingingStudio™ Song Files] : " stringByAppendingString:fileName]];
        
        // Generate Filenames
        NSString *fileNameWav = [fileName stringByAppendingString:@".wav"];
        NSString *fileNameMid = [fileName stringByAppendingString:@".mid"];
        
        if ([title isEqualToString:@"Wav"]||[title isEqualToString:@"Both"]){
            // Attach WAV FILE
            NSString *pathWav = [documentsDirectory stringByAppendingPathComponent:fileNameWav];
            NSData *myDataWav = [NSData dataWithContentsOfFile:pathWav];
            [myMailComposer addAttachmentData:myDataWav mimeType:@"audio/x-wav" fileName:fileNameWav];
            }
        
        if ([title isEqualToString:@"Midi"]||[title isEqualToString:@"Both"]){
            // Attach Midi FILE
            NSString *pathMid = [documentsDirectory stringByAppendingPathComponent:fileNameMid];
            NSData *myDataMid = [NSData dataWithContentsOfFile:pathMid];
            [myMailComposer addAttachmentData:myDataMid mimeType:@"audio/midi" fileName:fileNameMid];
            }
        
        // Fill out the email body text
        NSString *emailBody = @"Hi,\n\nAttached you can find the files generated by the SingingStudio™ App.\n\SingingStudio™ Team";
        [myMailComposer setMessageBody:emailBody isHTML:NO];
        
        //  myMailComposer.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:myMailComposer animated:YES completion:NULL];
        }
    }

#pragma mark - Delegate Methods
// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Mail Message"
                          message: nil
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    switch (result) {
		case MFMailComposeResultCancelled:
                alert.message=@"Mail sending canceled";
 			break;
		case MFMailComposeResultSaved:
                alert.message=@"Mail saved";
			break;
		case MFMailComposeResultSent:
                alert.message=@"Mail sent";
			break;
		case MFMailComposeResultFailed:
                alert.message=@"Mail sending failed";
			break;
		default:
                alert.message=@"Mail not sent";
			break;
        }
//    [alert show];
//    [alert release];
	[self dismissViewControllerAnimated:YES completion:NULL];
    }

@end
