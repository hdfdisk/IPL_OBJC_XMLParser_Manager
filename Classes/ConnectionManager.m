//
//  ConnectionManager.m
//  IPL_ObjC_XMLParserManager
//
//  Created by Phoenix Bjartskular on 3/20/11.
//  Copyright 2011 Shanghai JiaoTong University. All rights reserved.
//

#import "ConnectionManager.h"
#import "Connection.h"
#import "ConnectionDelegate.h"



@implementation ConnectionManager
@synthesize selfUUID;
-(id)init {
	[super init];
	timeOutInterval = 10;
	cachePolicy = NSURLRequestUseProtocolCachePolicy;
	ifAutoRetry = NO;
	allConnection = [[NSMutableDictionary alloc] init];
	allPendingConnection = nil;
	sharedRequest = [[NSMutableURLRequest alloc] init];
	[sharedRequest setCachePolicy:cachePolicy];
	[sharedRequest setTimeoutInterval:timeOutInterval];
	selfUUID = CFUUIDCreate(NULL);
    sharedDelegate = nil;
/*	[[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%qu",NSTemporaryDirectory(),selfHashID]
							  withIntermediateDirectories:YES
											   attributes:[[NSFileManager defaultManager] attributesOfItemAtPath:NSTemporaryDirectory() error:nil]
													error:nil]; */
    queryingThread = nil;    
    return self;
}

+(id)sharedConnectionManager {
    static ConnectionManager * sharedManager = nil;
    static BOOL sharedConnectionManagerMethodInvolved = NO;
    
    while (sharedConnectionManagerMethodInvolved) {
    }
    sharedConnectionManagerMethodInvolved = YES;
    if (!sharedManager) {
        sharedManager = [[ConnectionManager alloc] init];
    }
    sharedConnectionManagerMethodInvolved = NO;
    return sharedManager;
}

-(void)setWithTimeInterval:(NSUInteger)timeInMS 
     URLRequestCachePolicy:(NSURLRequestCachePolicy)policy 
             queuedRequest:(BOOL)ifQueued
                 AutoRetry:(BOOL)ifRetry 
            SharedDelegate:(id <ConnectionDelegate>)delegate {
	timeOutInterval = timeInMS / 1000.0;
	cachePolicy = policy;
	ifAutoRetry = ifRetry;
	sharedDelegate = delegate;
    [allPendingConnection release];
    if (ifQueued) {
        allPendingConnection = [[NSMutableArray alloc] init];
    }else {
        allPendingConnection = nil;
    }
	[sharedRequest setCachePolicy:cachePolicy];
	[sharedRequest setTimeoutInterval:timeOutInterval];
    if (ifQueued) {
        [queryingThread release];
        queryingThread = [[NSThread alloc] initWithTarget:self selector:@selector(connectionQueryingThreadProcess) object:nil];
    }else {
        [queryingThread release];
        queryingThread = nil;
    }
}

-(void)connectionQueryingThreadProcess {
	while ([allPendingConnection count]) {
		Connection * currentRunningConnection;
		currentRunningConnection = [allPendingConnection objectAtIndex:0];
		[allPendingConnection removeObjectAtIndex:0];
		[currentRunningConnection requestForURL];
		[currentRunningConnection release];
	}
}


-(CFUUIDRef) newXMLConnection:(NSURL *)targetURL
			  specificDelegate:(id)delegate {
    Connection * newConnection;
    if (allPendingConnection) {
        newConnection = [[Connection alloc] initWithURLRequest:[sharedRequest retain] parentManager:self targetURL:targetURL
                                      ];
        [allPendingConnection addObject:newConnection];
    }else{
        newConnection = [[Connection alloc] initWithURLRequest:[sharedRequest copy] parentManager:nil targetURL:targetURL];
    }
    
	if (delegate) {
		[newConnection setDelegate:delegate];
	} else {
		[newConnection setDelegate:sharedDelegate];
	}
	[newConnection setIfAutoRetry:ifAutoRetry];
    
	CFUUIDRef connectionUUID = CFUUIDCreate(NULL);
	[newConnection setSelfID:connectionUUID];
	[allConnection setValue:newConnection forKey:(NSString *)CFUUIDCreateString(NULL, connectionUUID)];
    if (allPendingConnection) {
        if ([queryingThread isFinished]) {
            [queryingThread start];
        }
    }else {
        [newConnection requestForURL];
    }
    [newConnection release];
	return connectionUUID;
}

-(void) newXMLConnection:(NSURL *)targetURL 
			  specificID:(CFUUIDRef)uuid 
		specificDelegate:(id)delegate {
	Connection * newConnection = [[Connection alloc] initWithURLRequest:sharedRequest parentManager:self targetURL:targetURL];
	if (delegate) {
		[newConnection setDelegate:delegate];
	} else {
		[newConnection setDelegate:sharedDelegate];
	}
	[newConnection setIfAutoRetry:ifAutoRetry];
	[allPendingConnection addObject:newConnection];
	[newConnection setSelfID:uuid];
	[allConnection setValue:newConnection forKey:(NSString *)CFUUIDCreateString(NULL, uuid)];
	[newConnection release];
	if ([queryingThread isFinished]) {
		[queryingThread start];
	}
}

-(id)getTheConnectionFromUUID:(CFUUIDRef)uuid {
	NSString * stringID = (NSString*)CFUUIDCreateString(NULL, uuid);
	Connection * targetConnection = [allConnection valueForKey:stringID];
	/* Only get successfully completed connections */
	if ([targetConnection ifCompleted] && (![targetConnection ifError])) {
		return targetConnection;
	}
	/* Or It will return nil */
	else {
		[targetConnection release];
		return nil;
	}
}

-(void)dealloc {
	/* Destory All XML File and the Directory of this Connection Manager Instance */
/*	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@\%@",NSTemporaryDirectory(),(NSString*)CFUUIDCreateString(NULL,selfUUID)] 
											   error:nil]; */
    CFRelease(selfUUID);
	[allPendingConnection release];
	[allConnection release];
	[sharedRequest release];
	[queryingThread release];
	[super dealloc];
}


@end
