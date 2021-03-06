/*
     File: MessageComposerViewController.m
 Abstract: UIViewController that includes a UIButton and a UILabel.
 The button responds to an IBAction that will bring up the MFMessageComposeViewController for composing a new SMS text message. The label will show a feedback message of whether the SMS text message has been sent.
 
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import <MessageUI/MessageUI.h>
#import "MessageComposerSendFilesViewController.h"


@interface MessageComposerSendFilesViewController () <
    MFMailComposeViewControllerDelegate,
    MFMessageComposeViewControllerDelegate,
    UINavigationControllerDelegate
>
// UILabel for displaying the result of the sending the message.
@end

@implementation MessageComposerSendFilesViewController

@synthesize fileName;
@synthesize fileType;

#pragma mark - Rotation

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
// -------------------------------------------------------------------------------
//	shouldAutorotateToInterfaceOrientation:
//  Disable rotation on iOS 5.x and earlier.  Note, for iOS 6.0 and later all you
//  need is "UISupportedInterfaceOrientations" defined in your Info.plist
// -------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}
#endif

#pragma mark - Actions

// -------------------------------------------------------------------------------
//	showMailPicker:
//  IBAction for åthe Compose Mail button.
// -------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];

    // You must check that the current device can send email messages before you
    // attempt to create an instance of MFMailComposeViewController.  If the
    // device can not send email messages,
    // [[MFMailComposeViewController alloc] init] will return nil.  Your app
    // will crash when it calls -presentViewController:animated:completion: with
    // a nil view controller.
    if ([MFMailComposeViewController canSendMail])
    // The device can send email.
    {
        [self displayMailComposerSheet];
    }
    else
    // The device can not send email.
    {
    //    self.feedbackMsg.hidden = NO;
	//	self.feedbackMsg.text = @"Device not configured to send mail.";
    }
}


#pragma mark - Compose Mail/SMS

// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
- (void)displayMailComposerSheet {
    
    // Get Directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Remove extension from Filename
    fileName = [[fileName componentsSeparatedByString: @".wav"] objectAtIndex: 0];

    // Create Mail composer Object
	MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
	mailComposer.mailComposeDelegate = self;

    // Add Email Subject
    [mailComposer setSubject:[@"[MasterPitch™ Song Files] : " stringByAppendingString:fileName]];

    // Generate Filenames
    NSString *fileNameWav = [fileName stringByAppendingString:@".wav"];
    NSString *fileNameMid = [fileName stringByAppendingString:@".mid"];

    if ([fileType isEqualToString:@"Wav"]||[fileType isEqualToString:@"Both"]){
        // Attach WAV FILE
        NSString *pathWav = [documentsDirectory stringByAppendingPathComponent:fileNameWav];
        NSData *myDataWav = [NSData dataWithContentsOfFile:pathWav];
        [mailComposer addAttachmentData:myDataWav mimeType:@"audio/x-wav" fileName:fileNameWav];
        }
    
    if ([fileType isEqualToString:@"Midi"]||[fileType isEqualToString:@"Both"]){
        // Attach Midi FILE
        NSString *pathMid = [documentsDirectory stringByAppendingPathComponent:fileNameMid];
        NSData *myDataMid = [NSData dataWithContentsOfFile:pathMid];
        [mailComposer addAttachmentData:myDataMid mimeType:@"audio/midi" fileName:fileNameMid];
        }
	
	// Fill out the email body text
	NSString *emailBody = @"Hi,\n\nAttached you can find the files generated by the MasterPitch™ App.\n\nMasterPitch™ Team";
	[mailComposer setMessageBody:emailBody isHTML:NO];
	
    mailComposer.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:mailComposer animated:YES completion:NULL];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    
}


#pragma mark - Delegate Methods

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller 
		didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
//	self.feedbackMsg.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
//			self.feedbackMsg.text = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
//			self.feedbackMsg.text = @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
//			self.feedbackMsg.text = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
//			self.feedbackMsg.text = @"Result: Mail sending failed";
			break;
		default:
//			self.feedbackMsg.text = @"Result: Mail not sent";
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:NULL];
    [super.navigationController popViewControllerAnimated:YES];
}

@end
