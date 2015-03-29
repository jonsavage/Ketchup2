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
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.classes = [[NSMutableArray alloc] init];
    
    [self reloadTable];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)reloadTable {
    NSLog(@"update table");
    PFQuery *query = [PFQuery queryWithClassName:@"Feed"];
    
    
    //[query whereKey:@"classId" equalTo:[self.appDelegate classId]];
    
    [query selectKeys:@[@"classId"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(error == nil) { // Get our shit yo!
            NSLog(@"got data successfully");
            
            for(PFObject *i in objects) {
                
                if(![self.classes containsObject: i[@"classId"]]) {
                    [self.classes addObject:i[@"classId"]];
                }
            }
            
        } else { NSLog(@"error getting questions"); }
        
        [self.tableView reloadData];
    }];
}


-(void)viewDidAppear:(BOOL)animated {
    [self reloadTable];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [self.classes objectAtIndex:indexPath.row];
    NSLog(cell.textLabel.text);
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    self.appDelegate.classId = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    
    [self performSegueWithIdentifier: @"classChosen" sender:self];
    
    // Display Alert Message
//    [messageAlert show];
    
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
