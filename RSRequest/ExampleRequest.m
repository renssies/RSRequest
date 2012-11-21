//
//  ExampleRequest.m
//  RSRequest
//
//  Created by Rens Verhoeven on 04-11-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import "ExampleRequest.h"

@implementation ExampleRequest

+(RSRequest *)faultyRequestForSearchWithQuery:(NSString *)query {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://ggraph.facebook.com/search?q=%@",query]];
    NSString *method = @"GET";
    RSRequest *request = [[[RSRequest alloc] initWithURL:url] autorelease];
    [request setHTTPMethod:method];
    return request;
}

+(RSRequest *)requestForSearchWithQuery:(NSString *)query {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/search?q=%@",query]];
    NSString *method = @"GET";
    RSRequest *request = [[[RSRequest alloc] initWithURL:url] autorelease];
    [request setHTTPMethod:method];
    return request;
}

@end
