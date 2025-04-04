//
//  NetRecorder.m
//  NetRecorder
//
//  Created by Pankaj Nathani on 08/05/18.
//

#import "NetRecorder.h"
#import "NLConstants.h"

@interface NetRecorder()

@end

@implementation NetRecorder

+ (id)sharedManager {
    static NetRecorder *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        self.requestDict = [[NSMutableDictionary alloc] init];
        self.responseDict = [[NSMutableDictionary alloc] init];
        self.serialQueue = dispatch_queue_create("com.netlogger.recorder.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)recordRequest:(NSURLRequest*)request forReqId:(NSString*)reqId{
    dispatch_async(self.serialQueue, ^{
        [[[NetRecorder sharedManager] requestDict] setObject:request forKey:reqId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTI_REQ_UPDATED
             object:self userInfo:@{@"reqId":reqId}];
        });
    });
}

- (void)recordResponse:(NSURLResponse*) response withData:(NSData*)data withError:(NSError*)error forReqId:(NSString*)reqId forResId:(NSString *)resId{
    dispatch_async(self.serialQueue, ^{
        NSDictionary* responseDict;
        
        if (!error)
        {
            // if there is no error
            responseDict = [NSDictionary dictionaryWithObjectsAndKeys:response, NSStringFromClass ([NSURLResponse class]),data,NSStringFromClass ([NSData class]), NSStringFromClass ([NSError class]),[NSNull null], resId ,@"resId",nil];
        }
        else if (!data){
            // if there is no error
            responseDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], NSStringFromClass ([NSURLResponse class]),[NSNull null],NSStringFromClass ([NSData class]), NSStringFromClass ([NSError class]),[NSNull null],resId ,@"resId",nil];
        }
        
        [[[NetRecorder sharedManager] responseDict] setObject:responseDict forKey:reqId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTI_RESPONSE_UPDATED
             object:self userInfo:@{@"resId":resId}];
        });
    });
}

@end
