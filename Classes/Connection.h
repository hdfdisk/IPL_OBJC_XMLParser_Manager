//
//  Connection.h
//  IPL_ObjC_XMLParserManager
//
//  Created by Phoenix Bjartskular on 3/19/11.
//  Copyright 2011 Shanghai JiaoTong University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"
#import "ConnectionManager.h"



@interface Connection : NSObject {
	NSMutableURLRequest * URLRequest;
	NSURLConnection * connectionOfURLRequest;
	NSURL * targetUrl;
	NSString * uuidOfFile;
	NSOutputStream * fileOutputStream;
	id delegate; /*Follow Protocol from ConnectionDelegate.h*/
	TBXML * xmlParseredData;
	BOOL ifCompleted;
	BOOL ifError;
	BOOL ifAutoRetry;
	
	ConnectionManager * parentManager;
	NSString * selfID;
}
/* When Inited, URL Request is pending, not launched */
-(id) initWithURLRequest:(NSMutableURLRequest *)sharedURLRequest
		   parentManager:(ConnectionManager *)manager
			   targetURL:(NSURL *)url;

-(void) requestForURL;
-(void) dealloc;

/* Delegate Methods For NSURLConnection, don't mixup with the delegate of this class */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;



@property(nonatomic,readonly,retain) TBXML * xmlParseredData;
@property(nonatomic,assign) id delegate;
@property(nonatomic,readonly) BOOL ifCompleted;
@property(nonatomic,readonly) BOOL ifError;
@property(nonatomic,readwrite) BOOL ifAutoRetry;
@property(nonatomic,readwrite,retain) NSString * selfID;
@end
