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
@synthesize selfHashID;
-(id)init {
	[super init];
	timeOutInterval = 10;
	cachePolicy = NSURLRequestUseProtocolCachePolicy;
	ifAutoRetry = NO;
	allConnection = [[NSMutableDictionary alloc] init];
	allPendingConnection = [[NSMutableArray alloc] init];
	sharedRequest = [[NSMutableURLRequest alloc] init];
	[sharedRequest setCachePolicy:cachePolicy];
	[sharedRequest setTimeoutInterval:timeOutInterval];
	selfHashID = [self hash];
	[[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%qu",NSTemporaryDirectory(),selfHashID]
							  withIntermediateDirectories:YES
											   attributes:[[NSFileManager defaultManager] attributesOfItemAtPath:NSTemporaryDirectory() error:nil]
													error:nil];
	/* Create a Directory for all XML File belongs to this Connection Manager Instance */
	queryingThread = [[NSThread alloc] initWithTarget:self selector:@selector(connectionQueryingThreadProcess) object:nil];
	return self;
}

-(id)initWithTimeInterval:(NSUInteger)timeInMS 
	URLRequestCachePolicy:(NSURLRequestCachePolicy)policy 
				AutoRetry:(BOOL)ifRetry 
		   SharedDelegate:(id <ConnectionDelegate>)delegate {
	[super init];
	timeOutInterval = timeInMS / 1000.0;
	cachePolicy = policy;
	ifAutoRetry = ifRetry;
	sharedDelegate = delegate;
	allConnection = [[NSMutableDictionary alloc] init];
	allPendingConnection = [[NSMutableArray alloc] init];
	sharedRequest = [[NSMutableURLRequest alloc] init];
	[sharedRequest setCachePolicy:cachePolicy];
	[sharedRequest setTimeoutInterval:timeOutInterval];
	selfHashID = [self hash];
	queryingThread = [[NSThread alloc] initWithTarget:self selector:@selector(connectionQueryingThreadProcess) object:nil];
	return self;
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


-(NSUInteger) newXMLConnection:(NSURL *)targetURL
			  specificDelegate:(id)delegate {
	Connection * newConnection = [[Connection alloc] initWithURLRequest:sharedRequest parentManager:self targetURL:targetURL];
	if (delegate) {
		[newConnection setDelegate:delegate];
	} else {
		[newConnection setDelegate:sharedDelegate];
	}
	[newConnection setIfAutoRetry:ifAutoRetry];
	NSUInteger hashID = [newConnection hash];
	[allPendingConnection addObject:newConnection];
	NSString * stringHashID = [NSString stringWithFormat:@"%qu",hashID];
	[newConnection setSelfID:stringHashID];
	[allConnection setValue:newConnection forKey:stringHashID];
	[stringHashID release];
	[newConnection release];
	if ([queryingThread isFinished]) {
		[queryingThread start];
	}
	return hashID;
}

-(void) newXMLConnection:(NSURL *)targetURL 
			  specificID:(NSString *)hashID 
		specificDelegate:(id)delegate {
	Connection * newConnection = [[Connection alloc] initWithURLRequest:sharedRequest parentManager:self targetURL:targetURL];
	if (delegate) {
		[newConnection setDelegate:delegate];
	} else {
		[newConnection setDelegate:sharedDelegate];
	}
	[newConnection setIfAutoRetry:ifAutoRetry];
	[allPendingConnection addObject:newConnection];
	[newConnection setSelfID:hashID];
	[allConnection setValue:newConnection forKey:hashID];
	[newConnection release];
	if ([queryingThread isFinished]) {
		[queryingThread start];
	}
}

-(id)getTheConnectionFromUUID:(NSUInteger)uuid {
	NSString * stringHashID = [NSString stringWithFormat:@"%qu",uuid];
	Connection * targetConnection = [allConnection valueForKey:stringHashID];
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
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%qu",NSTemporaryDirectory(),selfHashID] 
											   error:nil];
	[allPendingConnection release];
	[allConnection release];
	[sharedRequest release];
	[queryingThread release];
	[super dealloc];
}


@end
