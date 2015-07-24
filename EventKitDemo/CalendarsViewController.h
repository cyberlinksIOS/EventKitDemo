//
//  CalendarsViewController.h
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblCalendars;


- (IBAction)editCalendars:(id)sender;

@end
