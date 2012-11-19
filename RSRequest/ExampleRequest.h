//
//  ExampleRequest.h
//  RSRequest
//
//  Created by Rens Verhoeven on 04-11-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import "RSRequest.h"

@interface ExampleRequest : RSRequest

+(RSRequest *)requestForSearchWithQuery:(NSString *)query;

@end
