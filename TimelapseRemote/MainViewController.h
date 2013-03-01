//
//  MainViewController.h
//  TimelapseRemote
//
//  Created by Alex Forey on 28/02/2013.
//  Copyright (c) 2013 Alex Forey. All rights reserved.
//

#import "FlipsideViewController.h"
#import "RscMgr.h"
#import <CoreData/CoreData.h>

#define BUFFER_LEN 1024

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, RscMgrDelegate> {
    RscMgr *rscMgr;
    UInt8 rxBuffer[BUFFER_LEN];
    UInt8 txBuffer[BUFFER_LEN];
}

- (void)sendString:(NSString *)text;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (IBAction)stateChange:(id)sender;
- (IBAction)directionChange:(id)sender;
- (IBAction)intervalChange:(id)sender;
- (IBAction)distanceChange:(id)sender;
- (IBAction)goToMotor:(id)sender;
- (IBAction)goFromMotor:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *takenLabel;
@property (strong, nonatomic) IBOutlet UILabel *intervalLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *feedbackLabel;

@end
