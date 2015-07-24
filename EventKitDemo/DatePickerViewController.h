//
//  DatePickerViewController.h
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerViewControllerDelegate

-(void)dateWasSelected:(NSDate *)selectedDate;

@end


@interface DatePickerViewController : UIViewController

@property (nonatomic, strong) id<DatePickerViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIDatePicker *dtDatePicker;


- (IBAction)acceptDate:(id)sender;

@end
