//
//  FlipsideViewController.m
//  TimelapseRemote
//
//  Created by Alex Forey on 28/02/2013.
//  Copyright (c) 2013 Alex Forey. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

@synthesize logWindow;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, true);
    NSString *log = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ns.log"];
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:log];
    
    [fh seekToEndOfFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData:) name:@"NSFileHandleReadCompletionNotification" object:fh];
    
    [fh readInBackgroundAndNotify];
    firstOpen = true;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, true);
    NSString *log = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ns.log"];
    
    if (firstOpen) {
        NSString *content = [NSString stringWithContentsOfFile:log encoding:NSUTF8StringEncoding error:NULL];
        if (content) {
            logWindow.editable = true;
            logWindow.text = [logWindow.text stringByAppendingString: content];
            logWindow.editable = false;
        }
        firstOpen = false;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma NSLog Redirection Methods

- (void)getData:(NSNotification *)aNotification {
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length]) {
        NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        logWindow.editable = true;
        logWindow.text = [logWindow.text stringByAppendingString: aString];
        logWindow.editable = false;
        
        [self setWindowScrollToVisible];
        [[aNotification object] readInBackgroundAndNotify];
    } else {
        [self performSelector:@selector(refreshLog:) withObject:aNotification afterDelay:1.0];
    }
}

- (void)refreshLog:(NSNotification *)aNotification {
    [[aNotification object] readInBackgroundAndNotify];
}

- (void)setWindowScrollToVisible {
    NSRange txtOutputRange;
    txtOutputRange.location = [[logWindow text] length];
    txtOutputRange.length = 0;
    logWindow.editable = true;
    [logWindow scrollRangeToVisible:txtOutputRange];
    [logWindow setSelectedRange:txtOutputRange];
    logWindow.editable = false;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
