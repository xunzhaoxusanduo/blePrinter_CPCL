//
//  QPBleInfoTool.h
//  bleDemo
//
//  Created by wuyaju on 16/4/1.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QPBleInfoTool : NSObject

/**
 *  返回已经配对过的蓝牙设备
 *
 *  @return 已配对的蓝牙设备数组，里面存放的是BleInfo类
 */
+ (NSArray *)pairBleInfo;

/**
 *  将已配对的蓝牙设备保存到plist文件中
 *
 *  @param bleInfoArray 已配对的蓝牙设别数组
 */
+ (BOOL)addPairBleInfo:(NSArray *)bleInfoArray;

@end
