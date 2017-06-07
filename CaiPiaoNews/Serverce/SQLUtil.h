//
//  SQLUtil.h
//  Ciaoyo
//
//  Created by Simay on 9/28/15.
//  Copyright (c) 2015 Simay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLUtil : NSObject

//点赞
// 是否被赞过
+ (BOOL)isLikedWithContentId:(NSString *)contentId;
//保存已赞状态
+ (void)svaeTheLikedWithContentId:(NSString *)contentId;

//保存视频信息
+ (void)saveVideoInfo:(NSDictionary *)videoInfo;

//根据image id查询视频信息
+ (NSDictionary *)vidoeInfoFromImageId:(NSString *)imageId;

@end
