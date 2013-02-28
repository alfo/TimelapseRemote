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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    rscMgr = [[RscMgr alloc] init];
    [rscMgr setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark RscMgrDelegate Methods

- (void)cableConnected:(NSString *)protocol {
    [rscMgr setBaud:9600];
    [rscMgr open];
}

- (void)cableDisconnected {
    
}

- (void)readBytesAvailable:(UInt32)numBytes {
    int bytesRead = [rscMgr read:rxBuffer Length:numBytes];
    NSLog(@"Read %d bytes from serial.", bytesRead);
    for (int i = 0; i < numBytes; ++i) {
        self.takenLabel.text = [NSString stringWithFormat:@"%c", ((char *)rxBuffer)[i]];
    }
}

- (BOOL)rscMessageReceived:(UInt8 *)msg TotalLength:(int)len {
    return FALSE;
}

- (void)didReceivePortConfig {
    
}

- (void)sendString:(NSString *)command {
    NSString *text = [command stringByAppendingString:@"\n"];
    NSLog(@"Sending '%@'...", text);
    int bytesToWrite = text.length;
    for (int i = 0; i < bytesToWrite; i++) {
        txBuffer[i] = (int)[text characterAtIndex:i];
    }
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
    
    [self sendString:command];
}

- (IBAction)directionChange:(id)sender {
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
    
    [self sendString:command];
}

- (IBAction)intervalChange:(id)sender {
}

- (IBAction)distanceChange:(id)sender {
}
@end
