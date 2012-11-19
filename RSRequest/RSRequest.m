//
//  RSRequest.m
//  RSRequest
//
//  Created by Rens Verhoeven on 04-11-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import "RSRequest.h"

@implementation RSRequest

-(id)initWithURL:(NSURL *)url method:(NSString *)method {
    if((self = [super init])) {
        NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:url];
        [URLRequest setHTTPMethod:method];
        _URLConnection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
    }
    return self;
}

-(id)initWithRequest:(NSMutableURLRequest *)request {
    if((self = [super init])) {
        _URLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return self;
}

-(void)startWithCompletionHandler:(RSRequestBlock)block {
    [self setRequestBlock:block];
    [_URLConnection start];
}

-(void)startWithJSONCompletionHandler:(RSRequestJSONBlock)block {
    [self setRequestJSONBlock:block];
    [_URLConnection start];
}

#pragma mark NSURLConnection Delegate 

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(_mutableData == nil) {
        _mutableData = [[NSMutableData alloc] init];
    }
    [_mutableData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _HTTPResponse = (NSHTTPURLResponse *)[response retain];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(_requestBlock) {
        _requestBlock(nil,error,nil);
    } else if(_requestJSONBlock) {
        _requestJSONBlock(nil,error,nil);
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(_requestBlock) {
        _requestBlock(_mutableData,nil,_HTTPResponse);
    } else if(_requestJSONBlock) {
        NSError *jsonError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:_mutableData options:kNilOptions error:&jsonError];
        if(jsonError) {
            _requestJSONBlock(nil,jsonError,_HTTPResponse);
        } else {
            _requestJSONBlock(result,nil,_HTTPResponse);
        }
    }
}

//Authentication

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] && _basicAuthenticationUsername != nil && _basicAuthenticationPassword != nil) {
        if([challenge previousFailureCount] == 0) {
        NSURLCredential *credentials = [[NSURLCredential alloc] initWithUser:_basicAuthenticationUsername password:_basicAuthenticationPassword persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credentials forAuthenticationChallenge:challenge];
        [credentials release];
        } else {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            NSError *error = [NSError errorWithDomain:RSRequestErrorDomain code:-42 userInfo:@{NSLocalizedDescriptionKey : @"Authetication Username or Password are incorrect"}];
            if(_requestBlock) {
                _requestBlock(nil,error,nil);
            } else if(_requestJSONBlock) {
                _requestJSONBlock(nil,error,nil);
            }
        }
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        if(_basicAuthenticationUsername != nil && _basicAuthenticationPassword != nil) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

-(void)dealloc {
    
    [_URL release];
	[_HTTPMethod release];
	[_URLConnection release];
	_HTTPResponse = nil;
    _requestBlock = nil;
    _requestJSONBlock = nil;
    [super dealloc];
}
@end
