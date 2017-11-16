//
//  JQBleDeviceManager.h
//
//  Created by Lansum Stuff on 16/3/29.
//  Copyright © 2016年 Lansum Stuff. All rights reserved.
//  提供蓝牙设备管理

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// 服务的UUID
#define SERVICE_UUID @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
// 提供只写的特征
#define WRITE_CHAR_UUID @"49535343-8841-43F4-A8D4-ECBE34729BB3"
// 提供通知的特征
#define NOTIFI_CHAR_UUID @"49535343-1E4D-4BD9-BA61-23C647249616"

typedef NS_ENUM(NSInteger, JQBlePrintStatus) {
    JQBlePrintStatusNoPaper = 0x01,      // 缺纸
    JQBlePrintStatusOverHeat = 0x02,     // 打印头过热
    JQBlePrintStatusBatteryLow = 0x04,   // 电量低
    JQBlePrintStatusPrinting = 0x08,     // 正在打印中
    JQBlePrintStatusCoverOpen = 0x10,    // 纸仓盖未关闭
    JQBlePrintStatusNoError,             // 其他值，没有错误
    JQBlePrintStatusOk,                  // 打印完毕
};

@protocol JQBleDeviceManagerDelegate <NSObject>

@optional
/**
 *  发现蓝牙打印机
 *
 *  @param peripheral 已发现的蓝牙打印机对象
 */
- (void)peripheralFound:(CBPeripheral *)peripheral;

/**
 *  扫描蓝牙打印机超时时间到
 */
- (void)scanTimerout;

/**
 *  已经连接上蓝牙打印机
 */
- (void)didConnectPeripheral;

/**
 *  已经和蓝牙打印机断开连接
 */
- (void)didDisconnectPeripheral;

/**
 *  连接蓝牙打印机失败
 */
- (void)didFailToConnectPeripheral;

/**
 *  手机蓝牙状态更新
 *
 *  @param central 中心设备对象
 */
- (void)didUpdatecentralManagerState:(CBCentralManager *)central;

/**
 *  蓝牙打印机状态更新
 *
 *  @param blePrintStatus 蓝牙打印机状态
 */
- (void)didUpdateBlePrintStatus:(JQBlePrintStatus)blePrintStatus;

@end

@interface JQBleDeviceManager: NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id <JQBleDeviceManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *peripherals;                  // 已扫描到的蓝牙设备集合
@property (nonatomic, strong) CBCentralManager *centralManager;             // 中心设备对象
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;           // 已经连接的蓝牙打印机对象

@property (nonatomic, strong)CBCharacteristic *characteristic;              // 已经发现的可写特征
@property (nonatomic, strong)CBCharacteristic *notifiCharacteristic;        // 已经发现的可通知的特征

// 获取蓝牙设备管理单例对象
+ (instancetype)bleManager;
/**
 *  开始扫描蓝牙设备
 *
 *  @param timeout 扫描超时时间
 *
 */
- (void)findPeripherals:(int)timeout;

/**
 *  开始扫描提供指定服务的蓝牙设备
 *
 *  @param serviceArray 提供指定服务UUID的集合
 *  @param timeout      扫描超时时间
 */
- (void)findPeripherals:(NSArray *)serviceArray timreOut:(NSTimeInterval)timeout;

/**
 *  停止扫描
 */
- (void)stopScan;

/**
 *  连接指定名字的蓝牙设备
 *
 *  @param bleName 要连接蓝牙设备的名字
 */
- (void)connectBlePrint:(NSString *)bleName;

/**
 *  连接蓝牙设备
 *
 *  @param peripheral 蓝牙设备对象
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral;

/**
 *  断开蓝牙连接
 *
 *  @param peripheral 蓝牙设备对象
 */
- (void)disconnect:(CBPeripheral *)peripheral;

//
/**
 *  向蓝牙设备写入字符串信息，自动进行分段发送
 *
 *  @param peripheral 已经连接的蓝牙设备对象
 *  @param message    要发送的字符串信息
 */
- (void)write:(CBPeripheral *)peripheral message:(NSString *)message;

// 向外围设备写入二进制数据，自动进行分段发送
/**
 *  向蓝牙设备写入二进制数据，自动进行分段发送
 *
 *  @param peripheral 已经连接的蓝牙设备对象
 *  @param data       要发送的二进制数据
 */
- (void)write:(CBPeripheral *)peripheral data:(NSData *)data;

/**
 *  判断是否连接蓝牙打印机
 *
 *  @return true：已经连接   false：未连接
 */
- (BOOL)isConnectBle;

/**
 *  读取蓝牙打印机的状态
 *
 *  @param timeout 读取状态超时时间，以S为单位
 *  @param success 成功读取状态的block
 *  @param fail    超时时间到，未获取蓝牙打印机状态的block
 */
- (void)readBlePrintStatus:(NSTimeInterval)timeout success:(void (^)(JQBlePrintStatus blePrintStatus))success fail:(void (^)(void))fail;

@end
