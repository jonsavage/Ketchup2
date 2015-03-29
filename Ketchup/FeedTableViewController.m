//
//  UITableViewController.m
//  Ketchup
//
//  Created by Jon Savage on 3/28/15.
//  Copyright (c) 2015 Jon Savage. All rights reserved.
//

#import "FeedTableViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "AppDelegate.h"

@interface FeedTableViewController ()

@property (strong, nonatomic) NSArray *questions;

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
//    if([self.appDelegate classId] == nil) {
//        NSLog(@"class id is Nill!");
//        return;
//    }
    
    self.questions = [[NSArray alloc] init];
    
    [self updateTable];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)updateTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Anycdotes"];
    
    
    [query whereKey:@"classId" equalTo:@"mobiledev"];
    //[query whereKey:@"classId" equalTo:[self.appDelegate classId]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error == nil) { // Get our shit yo!
            
            self.questions = objects;
            
        } else { NSLog(@"error getting questions"); }
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

// Return number of rows in section. This will be the number of questions in the feed.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.questions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text=[self.questions objectAtIndex:indexPath.row];
    
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

@end