//
//  InstructorFeedTableViewController.m
//  Ketchup
//
//  Created by Jon Savage on 3/28/15.
//  Copyright (c) 2015 Jon Savage. All rights reserved.
//

#import "InstructorFeedTableViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface InstructorFeedTableViewController()

@property (strong, nonatomic) NSMutableArray *questions;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addQuestionButton;

@end

@implementation InstructorFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addQuestionButton.enabled = ![PFUser currentUser][@"isInstructor"]; // If the user is an instructor, disable the add question button.
                                                                             // Note that this does not change any functionality on that page,
                                                                             // It only stops the user from being able to access it (segue to it)
    
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; // Get a pointer to the appDelegate
    self.questions = [[NSMutableArray alloc] init]; // init an array which we will use to hold data which we will display in the tableview.
    
    [self reloadTable]; // Load the tableview cells.
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Start a timer which will call the method timerFireMethod every 2 seconds.
    // We will use this to check for new posts.
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                  target: self
                                                selector:@selector(timerFireMethod:)
                                                userInfo: nil repeats:YES];
}

// Called by our timer
- (void)timerFireMethod:(NSTimer *)timer {
    [self reloadTable]; // Reload the posts
}

// Reload the tableView
-(void)reloadTable {
    
    // Make a PFQuery which we will use to ask Parse for the feed.
    PFQuery *query = [PFQuery queryWithClassName:@"Feed"];
    
    // Require that the classId of the returned PFObjects match the class which we are currently in.
    [query whereKey:@"classId" equalTo:[self.appDelegate classId]];
    [query orderByDescending:@"createdAt"]; // Order the returned PFObjects by created date

    // Async task to find objects on Parse matching our query.
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // The code inside this block is run when the Query is complete.
        // Using an Async task allows us to do the heavy lifting (interacting with the backend) on a seperate thread
        // while we continue on interacting with the user. Performing this sequentially would make for a laggy UI.

        if(error == nil) { // Success! Lets process the response!
            
            if(self.questions.count != objects.count) { // If something has been added to the 'Feed' (the number of objects is different)
                self.questions = objects; // Replace our questions with the returned questions.
                
                if([PFUser currentUser][@"isInstructor"]) { // If the user is logged in as an instructor.
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //Vibrate when new questions are posted to the feed.
                }
            }
        } else { NSLog(@"error getting questions"); } // Something went wrong.
        
        [self.tableView reloadData]; // Reload the cells in the tableview.
    }];
}


-(void)viewDidAppear:(BOOL)animated {
    if(self.appDelegate != nil) {
        [self reloadTable]; // Every time that this view appears it's data will be refreshed form Parse.
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

// Return number of rows in section. This will be the number of questions in the feed.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"%d",self.questions.count);
    return self.questions.count;
}

// Returns a cell for a index. tableviews require this as they use it to populate the rows. Basically this just
// injects cells with data.
// Another Note. Tableviews only use the number of cells that they need. So if you have 100 rows but can only see
// 10 on your screen at a time the tableview will reuse the cells which are not currently being displayed.
// As you scroll the tableview will automatically reuse a cell container that just went out of view as the next cell to
// be shows on the other side. [ Cell [ data to show] ]
//
// A note about artifacts:
// Say that your cell may contain an image, if one exits for the related data. In the case that a particuliar cell comes into view
// who has no image it is important to clear the cell's image or else the old image will apear with the new data. This problem helps
// solidify what is going on behind the scenes.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"]; // Initially the tableview has no cells to reuse
                                                                                                            // In that case we will init them.
    }
    // self.question is our sorted array of questions still in their PFObjects returned from Parse.
    cell.textLabel.text = [self.questions objectAtIndex:indexPath.row][@"question"]; // get the text for the question
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

// Executed when the user hits the ( + ) button. This performs a segue to the addquestion view.
- (IBAction)addQuestionButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"addQuestion" sender:self];
}

@end