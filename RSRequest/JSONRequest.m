//
//  JSONRequest.m
//  RSRequest
//
//  Created by Rens Verhoeven on 04-11-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import "JSONRequest.h"

@implementation JSONRequest

+(JSONRequest *)requestForSearchWithQuery:(NSString *)query {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/search?q=%@",query]];
    NSString *method = @"GET";
    return (JSONRequest *)[[[RSRequest alloc] initWithURL:url method:method] autorelease];
}

@end
