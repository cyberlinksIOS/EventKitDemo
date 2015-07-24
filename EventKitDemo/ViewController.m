//
//  ViewController.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


@interface ViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) NSArray *arrEvents;


-(void)requestAccessToEvents;

-(void)loadEvents;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Instantiate the appDelegate property.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Make self the delegate and datasource of the table view.
    self.tblEvents.delegate = self;
    self.tblEvents.dataSource = self;
    
    
    // Request access to events.
    [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.4];
    
    // Load the events with a small delay, so the store event gets ready.
    [self performSelector:@selector(loadEvents) withObject:nil afterDelay:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"idSegueEvent"]) {
        EditEventViewController *editEventViewController = [segue destinationViewController];
        editEventViewController.delegate = self;
    }
}


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrEvents.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellEvent"];
    
    // Get each single event.
    EKEvent *event = [self.arrEvents objectAtIndex:indexPath.row];
    
    // Set its title to the cell's text label.
    cell.textLabel.text = event.title;
    
    // Get the event start date as a string value.
    NSString *startDateString = [self.appDelegate.eventManager getStringFromDate:event.startDate];
    
    // Get the event end date as a string value.
    NSString *endDateString = [self.appDelegate.eventManager getStringFromDate:event.endDate];
    
    // Add the start and end date strings to the detail text label.
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Keep the identifier of the event that's about to be edited.
    self.appDelegate.eventManager.selectedEventIdentifier = [[self.arrEvents objectAtIndex:indexPath.row] eventIdentifier];
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEvent" sender:self];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected event.
        [self.appDelegate.eventManager deleteEventWithIdentifier:[[self.arrEvents objectAtIndex:indexPath.row] eventIdentifier]];
        
        // Reload all events and the table view.
        [self loadEvents];
    }
}


#pragma mark - EditEventViewControllerDelegate method implementation

-(void)eventWasSuccessfullySaved{
    // Reload all events.
    [self loadEvents];
}


#pragma mark - IBAction method implementation

- (IBAction)showCalendars:(id)sender {
    if (self.appDelegate.eventManager.eventsAccessGranted) {
        [self performSegueWithIdentifier:@"idSegueCalendars" sender:self];
    }
}


- (IBAction)createEvent:(id)sender {
    if (self.appDelegate.eventManager.eventsAccessGranted) {
        [self performSegueWithIdentifier:@"idSegueEvent" sender:self];
    }
}


#pragma mark - Private method implementation

-(void)requestAccessToEvents{
    [self.appDelegate.eventManager.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (error == nil) {
            // Store the returned granted value.
            self.appDelegate.eventManager.eventsAccessGranted = granted;
        }
        else{
            // In case of error, just log its description to the debugger.
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


-(void)loadEvents{
    if (self.appDelegate.eventManager.eventsAccessGranted) {
        self.arrEvents = [self.appDelegate.eventManager getEventsOfSelectedCalendar];
        
        [self.tblEvents reloadData];
    }
}

@end
