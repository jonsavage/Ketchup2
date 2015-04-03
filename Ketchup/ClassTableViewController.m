//
//  ClassTableViewController.m
//  Ketchup
//
//  Created by Jon Savage on 3/29/15.
//  Copyright (c) 2015 Jon Savage. All rights reserved.
//

#import "ClassTableViewController.h"
#import "AppDelegate.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface ClassTableViewController ()

@property (strong, nonatomic) NSMutableArray *classes;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; // Get a pointer to the appDelegate
    
    self.classes = [[NSMutableArray alloc] init]; // A list of classes
    
    if (![PFUser currentUser]) { // No user logged in. Show the login view
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    else {
            [self reloadTable]; // If someone is logged in then reload the tableview.
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// Reloads the table of classes from parse.
-(void)reloadTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Feed"]; // Create a query which will be sent to Parse to give us back goodies.
    
    [query selectKeys:@[@"classId"]]; // Tell the query to only bring back the list of classIds
    
    // Async task to get the list of classIds matching our query.
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // The code inside this block is run when the Query is complete.
        // Using an Async task allows us to do the heavy lifting (interacting with the backend) on a seperate thread
        // while we continue on interacting with the user. Performing this sequentially would make for a laggy UI.

        if(error == nil) { // Success!
            
            for(PFObject *i in objects) { // for each PRObject returned by the query.
                
                if(![self.classes containsObject: i[@"classId"]]) { // if the PRObject has a classId
                    [self.classes addObject:i[@"classId"]]; // Add the class to our array which is loaded as a row.
                }
            }
            
        } else { NSLog(@"error getting questions"); } // There was an error getting the data from Parse.
        
        [self.tableView reloadData]; // Reload the tableview.
    }];
}


// Called whenever the view appeared.
-(void)viewDidAppear:(BOOL)animated {
    [self reloadTable];
    
    [self login]; // Makes sure a user is logged in.
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
    return self.classes.count;
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
    
    cell.textLabel.text = [self.classes objectAtIndex:indexPath.row]; // Inject the classId which corrospends to the indexpath.row into the cell.
    return cell;
}

// Called when a user selects a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Set the selected classId in the appDelegate. We will use this in the next views.
    self.appDelegate.classId = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    // Segue! to the next view.
    [self performSegueWithIdentifier: @"showFeed" sender:self];
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (IBAction)logoutButtonPushed:(id)sender {
    
    [PFUser logOut];
    
    [self login];
}

-(void)login {
    
    if (![PFUser currentUser]) { // No user logged in
        NSLog(@"aaa");
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
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

@end
