//
//  MainViewController.m
//  TimelapseRemote
//
//  Created by Alex Forey on 28/02/2013.
//  Copyright (c) 2013 Alex Forey. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initialise the serial object
    rscMgr = [[RscMgr alloc] init];
    [rscMgr setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RscMgrDelegate methods

- (void)cableConnected:(NSString *)protocol {
    // Start the serial connection
    [rscMgr setBaud:9600];
    [rscMgr open];
}

- (void)cableDisconnected {
    // I might put a popup here
}

- (void)portStatusChanged {
    // Nothing
}

- (void)readBytesAvailable:(UInt32)numBytes {
    
    // Read the input bytes
    int bytesRead = [rscMgr read:rxBuffer Length:numBytes];
    NSLog(@"Read %d bytes from serial cable.", bytesRead);
    self.takenLabel.text = @"";
    
    // Concat the bytes into a string
    NSMutableString *feedback = [NSMutableString string];
    for (int i = 0; i < numBytes; ++i) {
        [feedback appendString:[NSString stringWithFormat:@"%c", ((char *)rxBuffer)[i]]];
    }
    
    // Is the string a photo count or a status?
    if ([feedback hasPrefix:@"p"]) {
        // It's a photo!
        self.takenLabel.text = feedback;
    } else {
        // It's a status change
        self.feedbackLabel.text = [feedback substringFromIndex:1];
    }
}

- (BOOL) rscMessageReceived:(UInt8 *)msg TotalLength:(int)len {
    // Yeah, just, don't do anything
    return FALSE;
}

- (void) didReceivePortConfig {
    // Nothing
}


- (void)sendString:(NSString *)command {
    
    // Append a newline to the command so it's recognized
    NSString *text = [command stringByAppendingString:@"\n"];
    NSLog(@"Sending '%@'...", text);
    
    // Write the bytes
    int bytesToWrite = text.length;
    for (int i = 0; i < bytesToWrite; i++) {
        txBuffer[i] = (int)[text characterAtIndex:i];
    }
    
    // Tell me about it
    int bytesWritten = [rscMgr write:txBuffer Length:bytesToWrite];
    NSLog(@"Written %d bytes to serial", bytesWritten);
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

- (IBAction)stateChange:(id)sender {
    
    // The start / pause / stop
    
    NSString *command = [[NSString alloc] init];
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            command = @"start";
            break;
        case 1:
            command = @"pause";
            break;
        case 2:
        default:
            command = @"stop";
            break;
    }
    
    // Send it to the Arduino
    [self sendString:command];
}

- (IBAction)directionChange:(id)sender {
    
    // The direction buttons
    
    NSString *command = [[NSString alloc] init];
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            command = @"setDir 1";
        default:
            break;
        case 1:
            command = @"setDir 2";
            break;
    }
    
    // Send it to the Arduino
    [self sendString:command];
}

- (IBAction)intervalChange:(UIStepper *)sender {
    
    // Change the interval by +-500ms
    
    // In Miliseconds
    double value = [sender value];
    int interval = (int)value;
    
    // Convert the miliseconds to seconds with 1dp and display
    float displayInterval = interval / 1000.00;
    self.intervalLabel.text = [NSString stringWithFormat:@"%.1f s", displayInterval];
    
    // Send it to the Arduino
    [self sendString:[NSString stringWithFormat:@"setInt %d", interval]];
    
}

- (IBAction)distanceChange:(UIStepper *)sender {
    
    // Change the distance by +-25ms
    
    double value = [sender value];
    
    // Format it nicely and display
    NSString *distance = [NSString stringWithFormat:@"%.f", value];
    self.distanceLabel.text = [NSString stringWithFormat:@"%@ ms", distance];
    
    // Send it to the Arduino
    [self sendString:[NSString stringWithFormat:@"setDis %@", distance]];
}

- (IBAction)goToMotor:(id)sender {
    // Go to motor button
    // Send string to the Arduino
    [self sendString:@"go 1"];
}

- (IBAction)goFromMotor:(id)sender {
    // Go to other end button
    // Send string to the Arduino
    [self sendString:@"go 2"];
}


@end
