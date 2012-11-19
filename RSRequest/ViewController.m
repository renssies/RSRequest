//
//  ViewController.m
//  RSRequest
//
//  Created by Rens Verhoeven on 04-11-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import "ViewController.h"
#import "JSONRequest.h"

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

-(IBAction)startJSONRequest:(id)sender {
    [[JSONRequest requestForSearchWithQuery:@"orange"] startWithJSONCompletionHandler:^(id result, NSError *error, NSHTTPURLResponse *response) {
        NSLog(@"Main thread %@",([NSThread isMainThread] ? @"YES" : @"NO"));
        NSLog(@"HTTPResponse Status Code %i",response.statusCode);
        if(error) {
            NSLog(@"An error occured: %@ %@",[error localizedDescription],[error localizedFailureReason]);
        } else {
            NSLog(@"JSON %@",result);
        }
    }];
}

@end
