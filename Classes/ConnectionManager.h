//
//  ConnectionManager.h
//  IPL_ObjC_XMLParserManager
//
//  Created by Phoenix Bjartskular on 3/20/11.
//  Copyright 2011 Shanghai JiaoTong University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface ConnectionManager : NSObject {
	NSMutableDictionary * allConnection;
	NSMutableArray * allPendingConnection;
	NSMutableURLRequest * sharedRequest;
	
	BOOL ifAutoRetry;
	id sharedDelegate;
	NSThread * queryingThread;
	NSTimeInterval timeOutInterval;
	NSURLRequestCachePolicy cachePolicy;
	
	CFUUIDRef selfUUID;
    
    Reachability * reachabilityTest;
	
}

-(id)init;

+(id)sharedConnectionManager;

-(void)setTimeInterval:(NSUInteger)timeInMS 
	URLRequestCachePolicy:(NSURLRequestCachePolicy)policy
            queuedRequest:(BOOL)ifQueued
				AutoRetry:(BOOL)ifRetry
		   SharedDelegate:(id)delegate; /* This delegate for Class Connections will be shared between all connections */

-(CFUUIDRef) newXMLConnection:(NSURL *)targetURL
			  specificDelegate:(id)delegate; /* If Nil, use shared delegate */

-(void) newXMLConnection:(NSURL *)targetURL 
			  specificID:(CFUUIDRef)uuid
		specificDelegate:(id)delegate; /* Never Directly Call This Method */

-(void)connectionQueryingThreadProcess; /* Never Directly Call this Method */
-(id)getTheConnectionFromUUID:(CFUUIDRef)uuid;

@property (nonatomic,readonly) CFUUIDRef selfUUID;
@end
