//
//  AddQuestionViewController.m
//  Ketchup
//
//  Created by Jon Savage on 4/2/15.
//  Copyright (c) 2015 Jon Savage. All rights reserved.
//

#import "AddQuestionViewController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"



@interface AddQuestionViewController ()
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSString *classId;

@end

@implementation AddQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.classId = [(AppDelegate *)[[UIApplication sharedApplication] delegate] classId]; // Get the class id from AppDelegate
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


// Event Handler for submit button pushed
- (IBAction)submitButton:(id)sender {
    
    //Create an object for us to push to Parse
    PFObject *question = [PFObject objectWithClassName:@"Feed"]; // Classname is 'Feed'
    PFUser *currentUser = [PFUser currentUser]; // Add the current user as the poster of ths question.
    
    
    question[@"question"] = self.textField.text; // Add the test that the user entered in the text field as the content of the question column
    question[@"classId"] = self.classId; // Set the class which this question should be posted in.
    
    // Asyncronously post this to Parse, adding it to the 'Feed'
    [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // The contents of this block will execute when the PFObject has finished posting to Parse.
        // Using an Async block is great since it assigns this long running process to a seperate thread, allowing us to carry on with this one.
        // This helps prevent against laggy apps.
        
        if (succeeded) {
            NSLog(@"question uploaded"); // Success!
        } else {
            NSLog(@"%@", error); // =(
        }
    }];
}



@end
