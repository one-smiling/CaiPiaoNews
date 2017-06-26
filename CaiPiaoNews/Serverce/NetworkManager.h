//
//  NetworkManager.h
//  ThoroughInvestigation
//
//  Created by lushuai on 2017/4/11.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPSessionManager;

extern NSString * const kURLAPILogin;
extern NSString * const kURLAPIMdpcList;
extern NSString * const kURLAPIimportantPeopleList;
extern NSString * const kURLAPIClueList;
extern NSString * const kURLAPIPhoneList;
extern NSString * const kURLAPIQQList;
extern NSString * const kURLAPIPlateNumberList;
extern NSString * const kURLAPICardNumberList;
extern NSString * const kURLAPIMdpcDetail;
extern NSString * const kURLAPIImportantPeopleDetail;


typedef enum : NSUInteger {
    ResponseCodeUnknown = -1,   //未知错误
    ResponseCodeSuccess = 0,
} ResponseCode;

extern NSInteger cdoeForResponseObject(NSDictionary  * responseObject);

@interface NetworkManager : NSObject
+ (AFHTTPSessionManager *)sharedClient;

+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(id)parameters
                               success:( void (^)(NSURLSessionDataTask *task, id  responseObject))success
                               failure:( void (^)(NSURLSessionDataTask *  task, NSError *error))failure;

+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:( id)parameters
                                success:( void (^)(NSURLSessionDataTask *task, id  responseObject))success
                                failure:( void (^)(NSURLSessionDataTask *  task, NSError *error))failure;


+ (void)getDetailData:(NSString *)type page:(NSInteger )p Success:(void(^)(id data))success failure:(void(^)(NSError *error))failure;


@end
