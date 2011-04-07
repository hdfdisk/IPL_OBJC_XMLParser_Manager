A SAMPLE XML PARSER / CONNECTION WRAPPER
BASED ON TBXMLParser

ConnectionManager Class References

This Class provides a Low-Memory solution for parser online XML
It will parse the targeted XML ONE AT A TIME based on FIFO policy
XML will be downloaded to a temporary folder and then parse.

-(id)init;
This will initialize a Connection Manager Instance with Default Settings:
Timeout For a Connection: 10 seconds
URLRequestCachePolicy:  NSURLRequestUseProtocolCachePolicy;
No Autoretry when Connection Failed
No Shared Delegate

-(id)initWithTimeInterval:(NSUInteger)timeInMS 
	URLRequestCachePolicy:(NSURLRequestCachePolicy)policy
				AutoRetry:(BOOL)ifRetry
		   SharedDelegate:(id)delegate;
This will Initialize a connection manager instance with specific setting;
If Auto-retry is on, the manager will put the retrying connection on the last of its execution queue.

-(NSUInteger) newXMLConnection:(NSURL *)targetURL
			  specificDelegate:(id)delegate;
Create a new connection under the management of target instance.
You have to specific a delegate if there is no shared delegate specified before.
Return a Hash-id for this connection.

-(id)getTheConnectionFromUUID:(NSUInteger)uuid;
Return a SUCCESSFULLY COMPLETED Connection Instance based on its Hash-id
An ongoing / failed connection will not be returned at here.


ConnectionDelegate Protocol References
-(void) connection:(Connection *)Conn 
   failedWithError:(NSError *) error;
This delegate method will be call if the connection is failed with any reason


-(void) connectionDownloadCompleted:(Connection *)Conn;
This delegate method will be call if the connection has successfully downloaded the XML File into temporary folder

-(void) xmlParseredCompleted:(Connection *)Conn;
This delegate method will be call if the connection has successfully parsed a XML File downloaded from target URL.
You may get the parsed TBXML Instance by using [Conn xmlParseredData], which is a readonly property.
