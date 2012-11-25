//
//  RSRequest.m
//  RSRequest
//  Version 1.0
//
//  Created by Rens Verhoeven on 04-11-12.
//  Copyright (c) 2012 Renssies. All rights reserved.
//

#import "RSRequest.h"

//UIApplication+NetworkActivity
static NSInteger activityCount = 0;
@implementation UIApplication (NetworkActivity)

- (void)showNetworkActivityIndicator {
    @synchronized ([UIApplication sharedApplication]) {
        if (activityCount == 0) {
            [self setNetworkActivityIndicatorVisible:YES];
        }
        activityCount++;
    }
}
- (void)hideNetworkActivityIndicator {
    @synchronized ([UIApplication sharedApplication]) {
        activityCount--;
        if (activityCount <= 0) {
            [self setNetworkActivityIndicatorVisible:NO];
            activityCount=0;
        }
    }
}

@end

@interface RSRequest ()

@property (nonatomic,assign) int numberOfRetrysLeft;

@end

@implementation RSRequest

-(id)init {
    if((self = [super init])) {
        [self setDefaults];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])) {
        [self setDefaults];
    }
    return self;
}

-(id)initWithURL:(NSURL *)URL {
    if((self = [super initWithURL:URL])) {
        [self setDefaults];
    }
    return self;
}

-(id)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    if((self = [super initWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval])) {
        [self setDefaults];
    }
    return self;
}

-(void)setDefaults {
#ifdef RSRequestDefaultNumberOfRetrys
    [self setNumberOfRetrys:RSRequestDefaultNumberOfRetrys];
#endif
}

-(void)startWithCompletionHandler:(RSRequestBlock)block {
    [self setRequestBlock:block];
    [self prepareForStart];
    _numberOfRetrysLeft = _numberOfRetrys;
    [self showNetworkActivity];
    [_URLConnection start];
    
}

-(void)startWithJSONCompletionHandler:(RSRequestJSONBlock)block {
    [self setRequestJSONBlock:block];
    [self prepareForStart];
    _numberOfRetrysLeft = _numberOfRetrys;
    [self showNetworkActivity];
    [_URLConnection start];
}

-(void)prepareForStart {
    if(!_URLConnection) {
        _URLConnection = [[NSURLConnection alloc] initWithRequest:self delegate:self];
    }
}

-(void)retry {
    _URLConnection = nil;
    [self prepareForStart];
    [_URLConnection start];
}

-(void)showNetworkActivity {
    if([[UIApplication sharedApplication] respondsToSelector:@selector(showNetworkActivityIndicator)]) {
        [[UIApplication sharedApplication] showNetworkActivityIndicator];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

-(void)hideNetworkActivity {
    if([[UIApplication sharedApplication] respondsToSelector:@selector(hideNetworkActivityIndicator)]) {
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark Setters and Getters

-(void)setUserAgentString:(NSString *)userAgent {
    if(userAgent != nil) {
        [self setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    } else {
        NSMutableDictionary *allHeaderFields = [NSMutableDictionary dictionaryWithDictionary:[self allHTTPHeaderFields]];
        [allHeaderFields removeObjectForKey:@"User-Agent"];
        [self setAllHTTPHeaderFields:allHeaderFields];
    }
}

-(NSString *)userAgentString {
    if([self valueForHTTPHeaderField:@"User-Agent"]) {
        return [self valueForHTTPHeaderField:@"User-Agent"];
    } else {
        return nil;
    }
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
    if(_numberOfRetrysLeft <= 0) {
        [self hideNetworkActivity];
        if(_requestBlock) {
            _requestBlock(nil,error,nil);
        } else if(_requestJSONBlock) {
            _requestJSONBlock(nil,error,nil);
        }
    } else {
        _numberOfRetrysLeft -= 1;
        [self retry];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self hideNetworkActivity];
    if(_requestBlock) {
        _requestBlock(_mutableData,nil,_HTTPResponse);
    } else if(_requestJSONBlock) {
        if (_mutableData) {
            NSError *jsonError = nil;
            id result = [NSJSONSerialization JSONObjectWithData:_mutableData options:kNilOptions error:&jsonError];
            if(jsonError) {
                _requestJSONBlock(nil,jsonError,_HTTPResponse);
            } else {
                _requestJSONBlock(result,nil,_HTTPResponse);
            }
        } else {
            NSError *error = [NSError errorWithDomain:RSRequestErrorDomain code:-1412 userInfo:@{NSLocalizedDescriptionKey : @"Returned data is nil, JSON can't be parsed"}];
            _requestJSONBlock(nil,error,_HTTPResponse);
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
	[_URLConnection release];
	_HTTPResponse = nil;
    _requestBlock = nil;
    _requestJSONBlock = nil;
    [super dealloc];
}

@end
