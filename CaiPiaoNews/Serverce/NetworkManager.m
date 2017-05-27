//
//  NetworkManager.m
//  ThoroughInvestigation
//
//  Created by lushuai on 2017/4/11.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetworking.h"
NSString * const kResponseErrorDomain = @"kResponseErrorDomain";



static NSString * const AFAppDotNetAPIBaseURLString = @"http://192.168.0.196:8080/mdpc/";

NSInteger cdoeForResponseObject(NSDictionary  * _Nullable responseObject) {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if (!responseObject[@"result"]) {
            return ResponseCodeSuccess;
        }
        return [responseObject[@"result"] integerValue];
    }
    return ResponseCodeSuccess;
}

@implementation NetworkManager
+ (AFHTTPSessionManager *)sharedClient {
    static AFHTTPSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AFAppDotNetAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
//        _sharedClient.requestSerializer = [AFHTTPResponseSerializer serializer];
        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];

    });
    return _sharedClient;
}


+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:( void (^)(NSURLSessionDataTask *task, id  responseObject))success
                      failure:( void (^)(NSURLSessionDataTask *  task, NSError *error))failure DEPRECATED_ATTRIBUTE {
    
    return [[[self class] sharedClient] GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSInteger code = cdoeForResponseObject(responseObject);
        if (code == ResponseCodeSuccess) {
            if (success) {
                success(task,responseObject);
            }
        } else {
            NSString *errorMsg = nil;
            NSError *eror = [NSError errorWithDomain:kResponseErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:errorMsg ?: @""}];
            [self logError:eror task:task];
            if (failure) {
                failure(task,eror);
            }
        }
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logError:error task:task];
        if (failure) {
            failure(task,error);
        }
    }];
}


+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:( id)parameters
                       success:( void (^)(NSURLSessionDataTask *task, id  responseObject))success
                       failure:( void (^)(NSURLSessionDataTask *  task, NSError *error))failure  {
    return [[[self class] sharedClient] POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger code = cdoeForResponseObject(responseObject);
        if (code == ResponseCodeSuccess) {
            if (success) {
                success(task,responseObject);
            }
            
        } else {
            NSString *errorMsg = nil;
            NSError *eror = [NSError errorWithDomain:kResponseErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:errorMsg ?: @""}];
            [self logError:eror task:task];
            if (failure) {
                failure(task,eror);
            }
        }

    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logError:error task:task];
        if (failure) {
            failure(task,error);
        }
    }];
}
+ (void)logError:(NSError *)error task:(NSURLSessionDataTask *)task {
#if DEBUG
    NSLog(@"-----------------------------------------------");
    if (task) {
        NSHTTPURLResponse *reaposne = (NSHTTPURLResponse *)task.response;
        if ([reaposne isKindOfClass:[NSHTTPURLResponse class]]) {
            NSLog(@"%@",reaposne.allHeaderFields);
            NSLog(@"%ld %@",(long)reaposne.statusCode,[NSHTTPURLResponse localizedStringForStatusCode:reaposne.statusCode]);
        }
        NSLog(@"%@ Request URL:%@",task.currentRequest.HTTPMethod,task.currentRequest.URL.absoluteString);
    }
    if (error) {
        NSLog(@"%ld %@ %@",(long)error.code,error.domain,error.localizedDescription);
    }
    NSLog(@"-----------------------------------------------");
#endif
}



//+ (id)modelWithClass:(Class)aClass andResponseObject:(id)responseObject {
//    id model = nil;
//    if ([responseObject isKindOfClass:[NSDictionary class]] && [aClass respondsToSelector:@selector(mj_objectWithKeyValues:)]) {
//        model = [aClass mj_objectWithKeyValues:responseObject];
//    } else if ([responseObject isKindOfClass:[NSArray class]] && [aClass respondsToSelector:@selector(mj_objectArrayWithKeyValuesArray:)])  {
//        model = [aClass mj_objectArrayWithKeyValuesArray:responseObject];
//    }
//    return model;
//}

@end
