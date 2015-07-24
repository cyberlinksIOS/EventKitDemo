//
//  ViewController.h
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditEventViewController.h"

@interface ViewController : UIViewController <EditEventViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblEvents;


- (IBAction)showCalendars:(id)sender;

- (IBAction)createEvent:(id)sender;

@end
