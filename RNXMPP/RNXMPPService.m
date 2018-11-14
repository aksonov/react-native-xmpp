#import "RNXMPPService.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPUser.h"
#import "XMPPRoom.h"
#import "XMPPRoomMemoryStorage.h"
#import <CocoaLumberjack/DDLog.h>
#import "DDTTYLogger.h"
#import <CFNetwork/CFNetwork.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static DDLogLevel ddLogLevel = DDLogLevelVerbose;
//static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

@interface RNXMPPService(){
}

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation RNXMPPService

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoom;
@synthesize xmppRooms;

+(RNXMPPService *) sharedInstance {
    static RNXMPPService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RNXMPPService alloc] init];
        [sharedInstance setupStream];
        // Do any other initialisation stuff here
    });
    return sharedInstance;

}

- (void)dealloc
{
    [self teardownStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");

    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.

    // We're restarting our negotiation, so we need to reset the parser.
    xmppStream = [[XMPPStream alloc] init];

#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.

        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif

    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.

    xmppReconnect = [[XMPPReconnect alloc] init];

    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.

    xmppRosterStorage = [[XMPPRosterMemoryStorage alloc] init];

    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];

    xmppRoster.autoFetchRoster = NO;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.

//    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
//    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
//
//    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];

    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.

//    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
//    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
//
//    xmppCapabilities.autoFetchHashedCapabilities = YES;
//    xmppCapabilities.autoFetchNonHashedCapabilities = NO;

    // Activate xmpp modules

    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppStreamManagentStorage = [[XMPPStreamManagementMemoryStorage alloc] init];
    xmppStreamManagement = [[XMPPStreamManagement alloc] initWithStorage:xmppStreamManagentStorage];
    [xmppStreamManagement activate:xmppStream];
    xmppStreamManagement.autoResume = YES;
    [xmppStreamManagement addDelegate:self  delegateQueue:dispatch_get_main_queue()];
    
//    [xmppvCardTempModule   activate:xmppStream];
//    [xmppvCardAvatarModule activate:xmppStream];
//    [xmppCapabilities      activate:xmppStream];
//


//    xmppMUC = [[XMPPMUC alloc] init];
//    [xmppMUC activate:xmppStream];
//    [xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];

    // Add ourself as a delegate to anything we may be interested in

    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.

    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];


    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
    
    // init xmppRooms dict
    xmppRooms = [NSMutableDictionary dictionary];
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];

    [xmppMUC deactivate];
    [xmppReconnect         deactivate];
    [xmppStream disconnect];

    xmppStream = nil;
    xmppReconnect = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit

    NSString *domain = [xmppStream.myJID domain];

    //Google set their presence priority to 24, so we do the same to be compatible.

    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }

    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];

    [[self xmppStream] sendElement:presence];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) trustHosts:(NSArray *)hosts
{
    trustedHosts = hosts;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect:(NSString *)myJID withPassword:(NSString *)myPassword auth:(AuthMethod)auth hostname:(NSString *)hostname port:(int)port
{
    if (![xmppStream isDisconnected]) {
        [self disconnect];
    }

    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    NSLog(@"Connect using JID %@", myJID);

    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    username = myJID;
    password = myPassword;
    authMethod = auth;
    
    xmppStream.hostName = (hostname ? hostname : [username componentsSeparatedByString:@"@"][1]);
    if(port){
        xmppStream.hostPort = port;
    }

    NSError *error = nil;
    if (port == 5223) {
        self.xmppReconnect.usesOldSchoolSecureConnect = YES;
        if (![xmppStream oldSchoolSecureConnectWithTimeout:30 error:&error])
        {
            DDLogError(@"Error connecting: %@", error);
            if (self.delegate){
                [self.delegate onLoginError:error];
            }
            
            return NO;
        }
    } else {
        if (![xmppStream connectWithTimeout:30 error:&error])
        {
            DDLogError(@"Error connecting: %@", error);
            if (self.delegate){
                [self.delegate onLoginError:error];
            }
            
            return NO;
        }
    }

    return YES;
}

- (void)disconnect
{
    [xmppStream disconnect];
}

- (void)disconnectAfterSending
{
    [self goOffline];
    [xmppStream disconnectAfterSending];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    NSString *expectedCertName = [xmppStream hostName];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }

    if (customCertEvaluation)
    {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    if ([trustedHosts containsObject:xmppStream.hostName]) {
        completionHandler(YES);
    }

    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{

        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);

        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    isXmppConnected = YES;

    NSError *error = nil;
    [self.delegate onConnnect:username password:password];

    id <XMPPSASLAuthentication> someAuth = nil;

    if (authMethod == SCRAM && [[self xmppStream] supportsSCRAMSHA1Authentication])
    {
        someAuth = [[XMPPSCRAMSHA1Authentication alloc] initWithStream:[self xmppStream] password:password];
    }
    else if (authMethod == MD5 && [[self xmppStream] supportsDigestMD5Authentication])
    {
        someAuth = [[XMPPDigestMD5Authentication alloc] initWithStream:[self xmppStream] password:password];
    }
    else if ([[self xmppStream] supportsPlainAuthentication])
    {
        someAuth = [[XMPPPlainAuthentication alloc] initWithStream:[self xmppStream] password:password];
    }
    else
    {
        NSString *errMsg = @"No suitable authentication method found";
        NSDictionary *info = @{NSLocalizedDescriptionKey : errMsg};

        error = [NSError errorWithDomain:XMPPStreamErrorDomain code:XMPPStreamUnsupportedAction userInfo:info];
        DDLogError(@"Error authenticating: %@", error);
        [self.delegate onLoginError:error];
        return;
    }
    if (![[self xmppStream] authenticate:someAuth error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
        [self.delegate onLoginError:error];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if ([xmppStream supportsStreamManagement]){
        [xmppStreamManagement enableStreamManagementWithResumption:YES maxTimeout:600];
        [xmppStreamManagement automaticallyRequestAcksAfterStanzaCount:1 orTimeout:0];
    }

    [self goOnline];
    [self.delegate onLogin:username password:password];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self.delegate onLoginError:[NSError errorWithDomain:@"xmpp" code:0 userInfo:@{NSLocalizedDescriptionKey: [error description]}]];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self.delegate onIQ:iq];

    return NO;
}

- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSArray *users = [sender unsortedUsers];
    NSMutableArray *list = [NSMutableArray array];
    for (XMPPUserMemoryStorageObject *user in users){
        [list addObject:@{
                        @"username": [[user jid] user],
                        @"subscription": [user subscription],
                        @"displayName": [user displayName],
                        @"groups": [user groups],
                        }];
    }
    [self.delegate onRosterReceived:list];

}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender
    didAddResource:(XMPPResourceMemoryStorageObject *)resource
          withUser:(XMPPUserMemoryStorageObject *)user {

    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender
    didRemoveResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {

    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender
    didUpdateResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {

    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}




- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if (message.isErrorMessage){
        [self.delegate onError:[message errorMessage]];
    } else {
        [self.delegate onMessage:message];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    [self.delegate onPresence:presence];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self.delegate onError:[NSError errorWithDomain:@"xmpp" code:1 userInfo:@{ NSLocalizedDescriptionKey: [error stringValue]}]];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    isXmppConnected = NO;

    [self.delegate onDisconnect:error];

}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

-(void)sendMessage:(NSString *)text to:(NSString *)to thread:(NSString *)thread {
    if (!isXmppConnected){
        [self.delegate onError:[NSError errorWithDomain:@"xmpp" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Server is not connected, please reconnect"}]];
        return;
    }
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:text];

    NSXMLElement *msg = [NSXMLElement elementWithName:@"message"];
    [msg addAttributeWithName:@"type" stringValue:@"chat"];
    [msg addAttributeWithName:@"to" stringValue: to];
    
    if (thread != nil) {
        [msg addChild:[NSXMLElement elementWithName:@"thread" stringValue:thread]];
    }
    
    [msg addChild:body];
    [xmppStream sendElement:msg];
}

-(void)sendPresence:(NSString *)to type:(NSString *)type {
    if (!isXmppConnected){
        [self.delegate onError:[NSError errorWithDomain:@"xmpp" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Server is not connected, please reconnect"}]];
        return;
    }
    XMPPPresence *presence = [XMPPPresence presenceWithType:type to:[XMPPJID jidWithString:to]];
    [xmppStream sendElement:presence];
}

-(void)sendStanza:(NSString *)stanza {
    NSData *data = [stanza dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
    DDXMLElement *el = [doc rootElement];
    [xmppStream sendElement:el];
}

-(void)removeRoster:(NSString *)to {
    [xmppRoster removeUser:[XMPPJID jidWithString:to]];
}

-(void)fetchRoster {
    [xmppRoster fetchRoster];
}

-(void)joinRoom:(NSString *)roomJID nickName:(NSString *)nickname{
        XMPPJID *ROOM_JID = [XMPPJID jidWithString:roomJID];
        XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
        xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:ROOM_JID dispatchQueue:dispatch_get_main_queue()];
        [xmppRooms setObject:xmppRoom forKey:roomJID];
        NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
        [history addAttributeWithName:@"maxstanzas" stringValue:@"0"];
        [xmppRoom activate:xmppStream];
        [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppRoom joinRoomUsingNickname:nickname history:history password:nil];
    }

- (void)sendRoomMessage:(NSString *)roomJID message:(NSString *)message{
        if (!isXmppConnected){
                [self.delegate onError:[NSError errorWithDomain:@"xmpp" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Server is not connected, please reconnect"}]];
                return;
            }
        [[xmppRooms objectForKey:roomJID] sendMessageWithBody:message];
    }

-(void)leaveRoom:(NSString *)roomJID{
    [[xmppRooms objectForKey:roomJID] leaveRoom];
    [[xmppRooms objectForKey:roomJID] deactivate];
    [[xmppRooms objectForKey:roomJID] removeDelegate:self];
    [xmppRooms removeObjectForKey:roomJID];
}

@end
