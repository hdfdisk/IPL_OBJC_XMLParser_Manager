//
//  ConnectionDelegate.h
//  IPL_ObjC_XMLParserManager
//
//  Created by Phoenix Bjartskular on 3/19/11.
//  Copyright 2011 Shanghai JiaoTong University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connection.h"


@protocol ConnectionDelegate <NSObject>

-(void) connection:(Connection *)Conn 
   failedWithError:(NSError *) error;
-(void) connectionDownloadCompleted:(Connection *)Conn;
-(void) xmlParseredCompleted:(Connection *)Conn;

@end
