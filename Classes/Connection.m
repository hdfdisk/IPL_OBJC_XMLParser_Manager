//
//  Connection.m
//  IPL_ObjC_XMLParserManager
//
//  Created by Phoenix Bjartskular on 3/19/11.
//  Copyright 2011 Shanghai JiaoTong University. All rights reserved.
//

#import "Connection.h"
#import "ConnectionDelegate.h"


@implementation Connection
@synthesize xmlParseredData;
@synthesize delegate;
@synthesize ifCompleted;
@synthesize ifError;
@synthesize ifAutoRetry;
@synthesize selfID;

-(id) initWithURLRequest:(NSMutableURLRequest *)sharedURLRequest
		   parentManager:(ConnectionManager *)manager
			   targetURL:(NSURL *)url {
	[super init];
	URLRequest = [sharedURLRequest retain];
	targetUrl = [url retain];
	ifCompleted = NO;
	ifError = NO;
	parentManager = manager;
	return self;
}

-(void)requestForURL {
	[URLRequest setURL:targetUrl];
    downloadedData = [NSMutableData dataWithLength:1]; 
	connectionOfURLRequest = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self startImmediately:YES];
/*	uuidOfFile = [NSString stringWithFormat:@"%@%qu/%qu.xml",NSTemporaryDirectory(),[parentManager selfHashID],[connectionOfURLRequest hash]]; */
	/*Uniquely Create file name for each Connection Manager and Connection */
/*	[[NSFileManager defaultManager] removeItemAtPath:uuidOfFile error:nil];
	fileOutputStream = [NSOutputStream outputStreamToFileAtPath:uuidOfFile append:YES]; */
	/* Download the XML First */
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	/* Incrementally writing a local temporary XML File */
    [downloadedData appendData:data];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[(id<ConnectionDelegate>)delegate connection:self failedWithError:error];
	ifCompleted = YES;
	ifError = YES;
	if (ifAutoRetry) {
        if (parentManager) {
            [parentManager newXMLConnection:targetUrl
                                 specificID:selfID
                           specificDelegate:delegate];
            [self autorelease];

        }else{
            [downloadedData release];
            [connectionOfURLRequest release];
            [self requestForURL];
        }
	}
	/* When Auto Retrying, query a new request to the connection manager with same UUID */
	/* This will forbade a connection that always retrying and using too much resources */
	/* old connection will be destoryed */
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[delegate connectionDownloadCompleted:self];
	xmlParseredData = [TBXML tbxmlWithXMLData:downloadedData];
	/* TBXML Open the temporary XML Data */
	ifCompleted = YES;
	[delegate xmlParseredCompleted:self];
}

-(void) dealloc {
//	[[NSFileManager defaultManager] removeItemAtPath:uuidOfFile error:nil];
	[URLRequest release];
	[targetUrl release];
	[connectionOfURLRequest release];
	[uuidOfFile release];
	[downloadedData release];
	[xmlParseredData release];
	[super dealloc];
}

@end
