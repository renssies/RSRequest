//
//  RSRequest.h
//  RSRequest
//
//  Created by Rens Verhoeven on 04-11-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *RSRequestErrorDomain = @"RSRequestErrorDomain";

typedef void (^RSRequestBlock) (NSData *data,NSError *error,NSHTTPURLResponse *response);
typedef void (^RSRequestJSONBlock) (id result,NSError *error,NSHTTPURLResponse *response);

@interface RSRequest : NSMutableURLRequest <NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSURLConnection *URLConnection;
@property (nonatomic,strong) NSMutableData *mutableData;
@property (nonatomic,strong) NSHTTPURLResponse *HTTPResponse;

@property (nonatomic,strong) NSString *basicAuthenticationUsername;
@property (nonatomic,strong) NSString *basicAuthenticationPassword;

@property (nonatomic,copy) RSRequestBlock requestBlock;
@property (nonatomic,copy) RSRequestJSONBlock requestJSONBlock;
-(void)startWithCompletionHandler:(RSRequestBlock)block;
-(void)startWithJSONCompletionHandler:(RSRequestJSONBlock)block;
-(void)setUserAgentString:(NSString *)userAgent;
-(NSString *)userAgentString;
@end
