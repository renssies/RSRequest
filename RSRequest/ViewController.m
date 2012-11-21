//
//  ViewController.m
//  RSRequest
//
//  Created by Rens Verhoeven on 04-11-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import "ViewController.h"
#import "ExampleRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startRequest:(id)sender {
    
}

-(IBAction)startFaultyJSONRequest:(id)sender {
    [[ExampleRequest faultyRequestForSearchWithQuery:@"orange"] startWithJSONCompletionHandler:^(id result, NSError *error, NSHTTPURLResponse *response) {
        //Blocks are performed on main thread
        NSLog(@"Main thread %@",([NSThread isMainThread] ? @"YES" : @"NO"));
        //If there is no error, the error object is nil
        if(error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:[result description] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }];
}

-(IBAction)startJSONRequest:(id)sender {
    [[ExampleRequest requestForSearchWithQuery:@"orange"] startWithJSONCompletionHandler:^(id result, NSError *error, NSHTTPURLResponse *response) {
        //Blocks are performed on main thread
        NSLog(@"Main thread %@",([NSThread isMainThread] ? @"YES" : @"NO"));
        //If there is no error, the error object is nil
        if(error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:[result description] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }];
}

@end
