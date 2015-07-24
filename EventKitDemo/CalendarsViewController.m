//
//  CalendarsViewController.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "CalendarsViewController.h"
#import "AppDelegate.h"


@interface CalendarsViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) NSArray *arrCalendars;

@property (nonatomic) NSUInteger indexOfCalendarToDelete;



-(void)loadEventCalendars;

-(void)createCalendar;

-(void)confirmCalendarDeletion;

@end

@implementation CalendarsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Make self the delegate and datasource of the table view.
    self.tblCalendars.delegate = self;
    self.tblCalendars.dataSource = self;
    
    // Instantiate the appDelegate property.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    // Load all local event calendars.
    [self loadEventCalendars];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.tblCalendars.isEditing) {
        return self.arrCalendars.count;
    }
    else{
        return self.arrCalendars.count + 1;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellCalendar"];
    
    if (self.tblCalendars.isEditing) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idCellEdit"];
            
            UITextField *textfield = (UITextField *)[cell viewWithTag:10];
            textfield.delegate = self;
        }
    }
    
    if (!self.tblCalendars.isEditing || (self.tblCalendars.isEditing && indexPath.row != 0)) {
        NSInteger row = self.tblCalendars.isEditing ? indexPath.row - 1 : indexPath.row;
        
        EKCalendar *currentCalendar = [self.arrCalendars objectAtIndex:row];
        
        cell.textLabel.text = currentCalendar.title;
        
        if (!self.tblCalendars.isEditing) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if (self.appDelegate.eventManager.selectedCalendarIdentifier.length > 0) {
                if ([currentCalendar.calendarIdentifier isEqualToString:self.appDelegate.eventManager.selectedCalendarIdentifier]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else{
                
                if (indexPath.row == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
        }
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Deselect the tapped row.
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    // Keep the identifier value of the selected calendar.
    self.appDelegate.eventManager.selectedCalendarIdentifier = [[self.arrCalendars objectAtIndex:indexPath.row] calendarIdentifier];
    
    // Reload the table view.
    [self.tblCalendars reloadData];
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return UITableViewCellEditingStyleInsert;
    }
    else{
        return UITableViewCellEditingStyleDelete;
    }
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self createCalendar];
    }
    else{
        // Keep the row index of the calendar that's about to be deleted.
        self.indexOfCalendarToDelete = indexPath.row - 1;
        
        // Show the confirmation alert view.
        [self confirmCalendarDeletion];
    }
}


#pragma mark - IBAction method implementation

- (IBAction)editCalendars:(id)sender {
    // Set the table in editing mode.
    [self.tblCalendars setEditing:!self.tblCalendars.isEditing animated:YES];
    
    // Reload the table view.
    [self.tblCalendars reloadData];
}


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self createCalendar];
    
    return YES;
}


#pragma mark - UIAlertViewDelegate method implementation

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Delete the selected calendar if user selected so.
    if (buttonIndex == 1) {
        NSString *identifier = [[self.arrCalendars objectAtIndex:self.indexOfCalendarToDelete] calendarIdentifier];
        
        EKCalendar *calendarToDelete = [self.arrCalendars objectAtIndex:self.indexOfCalendarToDelete];
        
        NSError *error;
        if ([self.appDelegate.eventManager.eventStore removeCalendar:calendarToDelete commit:YES error:&error]) {
            // Check if the calendar that's about to be deleted is the selected one.
            if ([self.appDelegate.eventManager.selectedCalendarIdentifier isEqualToString:identifier]) {
                // In this case, set the empty string as the selectedCalendarIdentifier property's value.
                self.appDelegate.eventManager.selectedCalendarIdentifier = @"";
            }
            
            // Remove the current identifier from the collection of the custom calendar identifiers.
            [self.appDelegate.eventManager removeCalendarIdentifier:identifier];
            
            // Load the calendars once again.
            [self loadEventCalendars];
        }
        else{
            // Simply log the error description.
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}


#pragma mark - Private method implementation

-(void)loadEventCalendars{
    // Load all local event calendars.
    self.arrCalendars = [self.appDelegate.eventManager getLocalEventCalendars];
    
    // Reload the table view.
    [self.tblCalendars reloadData];
}


-(void)createCalendar{
    // Hide the keyboard. To do so, it's necessary to access the textfield of the first cell.
    UITextField *textfield = (UITextField *)[[self.tblCalendars cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:10];
    [textfield resignFirstResponder];
    
    // In case that no text was typed in the textfield then do nothing.
    if (textfield.text.length == 0) {
        return;
    }
    
    
    // Create a new calendar.
    EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent
                                                  eventStore:self.appDelegate.eventManager.eventStore];
    
    // Set the calendar title.
    calendar.title = textfield.text;
    
    // Find the proper source type value.
    for (int i=0; i<self.appDelegate.eventManager.eventStore.sources.count; i++) {
        EKSource *source = (EKSource *)[self.appDelegate.eventManager.eventStore.sources objectAtIndex:i];
        EKSourceType currentSourceType = source.sourceType;
        
        if (currentSourceType == EKSourceTypeLocal) {
            calendar.source = source;
            break;
        }
    }
    
    
    // Save and commit the calendar.
    NSError *error;
    [self.appDelegate.eventManager.eventStore saveCalendar:calendar commit:YES error:&error];
    
    // If no error occurs then turn the editing mode off, store the new calendar identifier and reload the calendars.
    if (error == nil) {
        // Turn off the edit mode.
        [self.tblCalendars setEditing:NO animated:YES];
        
        // Store the calendar identifier.
        [self.appDelegate.eventManager saveCustomCalendarIdentifier:calendar.calendarIdentifier];
        
        // Reload all calendars.
        [self loadEventCalendars];
    }
    else{
        // Display the error description to the debugger.
        NSLog(@"%@", [error localizedDescription]);
    }
}


-(void)confirmCalendarDeletion{
    // Check if the selected calendar is a custom one and can be actually deleted.
    NSString *identifier = [[self.arrCalendars objectAtIndex:self.indexOfCalendarToDelete] calendarIdentifier];
    if (![self.appDelegate.eventManager checkIfCalendarIsCustomWithIdentifier:identifier]) {
        // The selected calendar was not created by our app, so we shouldn't delete it.
        // Show a message to the user.
        [[[UIAlertView alloc] initWithTitle:@"EventKitDemo"
                                    message:@"You are not allowed to delete this calendar."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Okay", nil] show];
    }
    else{
        // The calendar can be deleted, but first ask for confirmation.
        // Ask for delete confirmation.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EventKitDemo"
                                                        message:@"Are you sure you want to delete the selected calendar?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes, delete", nil];
        
        [alert show];
    }
}

@end
