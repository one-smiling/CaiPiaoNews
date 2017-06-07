//
//  SQLUtil.m
//  Ciaoyo
//
//  Created by Simay on 9/28/15.
//  Copyright (c) 2015 Simay. All rights reserved.
//

#import "SQLUtil.h"
#import "FMDB.h"

@implementation SQLUtil

#pragma mark - praise 本地存储

+ (FMDatabase *)databae{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"ciaoyo_info.db"];
    
    /*
     if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
     NSError *error;
     [[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
     if (error) {
     DLog(@"删除失败%@",[error localizedDescription]);
     }
     
     }
     */
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    NSError *error;
    static BOOL isCreatedTable = NO;
    if (!isCreatedTable) {
        if ([db open]) {
            
            //用户赞列表
            NSString *creatTable = @"CREATE TABLE IF NOT EXISTS USER_LIKED (ID INTEGER PRIMARY KEY AUTOINCREMENT,ACCOUNT_TYPE TEXT, ACCOUNT TEXT, CONTENT_ID TEXT)";
            isCreatedTable = [db executeUpdate:creatTable withErrorAndBindings:&error];
            if (!isCreatedTable) {
                NSLog(@"数据 库创建失败,%@",[error localizedDescription]);
            }
    
            [db close];
        }
        else{
            NSLog(@"数据库打开失败");
        }
    }
    return  db;
}

+ (void)svaeTheLikedWithContentId:(NSString *)contentId {
    
    FMDatabase *db = self.databae ;
    if ([db open]) {
        NSString *account    = nil;
        NSString *accountKey = nil;
        if ([accountKey isEqualToString:@"openid"]) {
            accountKey = @"wechat";
        }
        
        BOOL isSuccess = [db executeUpdate:@"INSERT OR REPLACE INTO USER_LIKED (ACCOUNT_TYPE ,ACCOUNT , CONTENT_ID) VALUES (?,? , ?)",accountKey,account,contentId];
        if (!isSuccess) {
            NSLog(@"数据插入失败");
        }
        else{
            NSLog(@"插入数据成功");
        }
        
        [db close];
    }
    else{
        NSLog(@"数据库打开失败");
    }
}

+ (BOOL)isLikedWithContentId:(NSString *)contentId {
    
    if (!contentId) return NO;
    BOOL isLiked = NO;
    FMDatabase *db = self.databae ;
    if ([db open]) {
        FMResultSet *set = [db executeQuery:@"SELECT ACCOUNT FROM USER_LIKED WHERE CONTENT_ID = ?",contentId];
        NSString *account    = nil;
        while ([set next]) {
            NSString *likedAccount = [set stringForColumn:@"ACCOUNT"];
            if ([account isEqualToString:likedAccount]) {
                isLiked = YES;
                break;
            }
        }
        [set close];
    }
    return isLiked;
}

#pragma mark - 视频存储

+ (NSDictionary *)vidoeInfoFromImageId:(NSString *)imageId {
    if (imageId.length == 0) return nil;
    FMDatabase *db = self.databae ;

    if ([db open]) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM CACHED_VIDEO_INFO WHERE IMAGE_ID = ?",imageId];

        while ([set next]) {
            int i = 0;
            NSString *value = [set stringForColumnIndex:i];
            NSLog(@"%s: %@",__FUNCTION__,value);
        }
        [set close];
    }
    return nil;
}

+ (void)saveVideoInfo:(NSDictionary *)videoInfo {
    FMDatabase *db = self.databae ;
    if ([db open]) {

//        NSString *creatVideoTable = @"CREATE TABLE IF NOT EXISTS CACHED_VIDEO_INFO (ID INTEGER PRIMARY KEY AUTOINCREMENT,UPDATE_DATE TEXT, VIDEO_URL TEXT, TRANSPARENCY BOOL ,IMAGE_ID TEXT)";

        BOOL isSuccess = [db executeUpdate:@"INSERT OR REPLACE INTO CACHED_VIDEO_INFO (UPDATE_DATE ,VIDEO_URL,TRANSPARENCY,IMAGE_ID) VALUES (?,?,?,?)",videoInfo[@"UPDATE_DATE"],videoInfo[@"VIDEO_URL"],videoInfo[@"TRANSPARENCY"],videoInfo[@"IMAGE_ID"]];
        
        if (!isSuccess) {
            NSLog(@"数据插入失败");
        }
        else{
            NSLog(@"插入数据成功");
        }
        
        [db close];
    }
    else{
        NSLog(@"数据库打开失败");
    }

}




@end
