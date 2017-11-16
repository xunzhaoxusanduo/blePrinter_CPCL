//
//  QPBleInfoTool.m
//  bleDemo
//
//  Created by wuyaju on 16/4/1.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "QPBleInfoTool.h"
#import "BleInfo.h"

// 文件路径
#define QPPairBleInfoFilepath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"pairBleInfo.data"]

@implementation QPBleInfoTool

/**
 *  返回已经配对过的蓝牙设备
 *
 *  @return 已配对的蓝牙设备数组，里面存放的是BleInfo类
 */
+ (NSArray *)pairBleInfo{
    NSArray *pairBleInfoArray = [NSKeyedUnarchiver unarchiveObjectWithFile:QPPairBleInfoFilepath];
    
    return pairBleInfoArray;
}

/**
 *  将已配对的蓝牙设备保存到plist文件中
 *
 *  @param bleInfoArray 已配对的蓝牙设别数组
 */
+ (BOOL)addPairBleInfo:(NSArray *)bleInfoArray{
    if (bleInfoArray.count) {
        return [NSKeyedArchiver archiveRootObject:bleInfoArray toFile:QPPairBleInfoFilepath];
    }else{
        NSFileManager* fileManager = [NSFileManager defaultManager];
        BOOL blHave=[fileManager fileExistsAtPath:QPPairBleInfoFilepath];
        if (blHave) {
            [fileManager removeItemAtPath:QPPairBleInfoFilepath error:nil];
        }
        return true;
    }
}

@end
