//
//  MainViewController.m
//  collectionView
//
//  Created by Lansum Stuff on 16/3/29.
//  Copyright © 2016年 Lansum Stuff. All rights reserved.
//

#import "MainViewController.h"
#import "CollectionViewCell.h"
#import "BleDeviceManagerViewController.h"
#import <JQBlePrinter/JQBlePrint.h>
#import "MBProgressHUD+MJ.h"
#import "JQBox.h"
#import "JQLine.h"
#import "JQLabel.h"
#import "JQLabelField.h"

static NSString *const CellReuseIdentify = @"CellReuseIdentify";
#define ScrenWidth self.view.bounds.size.width

@interface MainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JQBleDeviceManagerDelegate>

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong)UIBarButtonItem *addBleItem;
@property (nonatomic, strong)UIBarButtonItem *connectedItem;

@property (nonatomic, strong)JQBleDeviceManager *bleManager;
@property (nonatomic, strong)JQCPCLTool *cpclManager;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"打印样张";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.itemSize = CGSizeMake(90, 90);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 10, 0, 10);
    self.flowLayout = flowLayout;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentify];
    
    self.bleManager = [JQBleDeviceManager bleManager];
    self.bleManager.delegate = self;
    
    self.cpclManager = [JQCPCLTool CPCLManager];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.bleManager isConnectBle]) {
        self.navigationItem.rightBarButtonItem = self.connectedItem;
    }else{
        self.navigationItem.rightBarButtonItem = self.addBleItem;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.bleManager.delegate = self;
}

#pragma mark - 私有方法
// 进入蓝牙设备管理界面
- (void)connectBle{
    BleDeviceManagerViewController *bleMgr = [[BleDeviceManagerViewController alloc] init];
    [self.navigationController pushViewController:bleMgr animated:YES];
}

- (void)showMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray arrayWithObjects:@"电影票", @"电子运单", @"二维码", nil];
    }
    
    return _dataArray;
}

- (UIBarButtonItem *)connectedItem{
    if (_addBleItem == nil) {
        UIButton *rightBtn = [[UIButton alloc] init];
        rightBtn.bounds = CGRectMake(0, 0, 35, 35);
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"print.png"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(connectBle) forControlEvents:UIControlEventTouchUpInside];
        _addBleItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    
    return _addBleItem;
}

- (UIBarButtonItem *)addBleItem{
    if (_connectedItem == nil) {
        _connectedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(connectBle)];
    }
    
    return _connectedItem;
}

#pragma mark - JQBleDeviceManagerDelegate代理方法
/**
 *  连接到外围设备
 */
- (void)didConnectPeripheral{
    self.navigationItem.rightBarButtonItem = self.connectedItem;
}

/**
 *  连接外围设备失败
 */
- (void)didFailToConnectPeripheral{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"连接失败"];
    self.navigationItem.rightBarButtonItem = self.addBleItem;
}

/**
 *  和外围设备断开连接
 */
- (void)didDisconnectPeripheral{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"和设备断开连接"];
    self.navigationItem.rightBarButtonItem = self.addBleItem;
}

/**
 *  蓝牙作为中心设备状态发生变化
 */
- (void)didUpdatecentralManagerState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStateUnsupported:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"设备不支持蓝牙功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case CBCentralManagerStateUnauthorized:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"蓝牙功能未授权，请到设置中开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case CBCentralManagerStatePoweredOff:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"蓝牙未开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            break;
        }
        default:
            break;
    }
}

/**
 *  打印机状态发生变化
 */
- (void)didUpdateBlePrintStatus:(JQBlePrintStatus)blePrintStatus{
    switch (blePrintStatus) {
        case JQBlePrintStatusOk:
            [self showMessage:@"打印完成"];
            break;
        case JQBlePrintStatusNoPaper:
            [self showMessage:@"缺纸！"];
            break;
        case JQBlePrintStatusOverHeat:
            [self showMessage:@"打印头过热！"];
            break;
        case JQBlePrintStatusBatteryLow:
            [self showMessage:@"电量低！"];
            break;
        case JQBlePrintStatusPrinting:
            [self showMessage:@"正在打印中！"];
            break;
        case JQBlePrintStatusCoverOpen:
            [self showMessage:@"纸仓盖未关闭！"];
            break;
        default:
            break;
    }
    
}

#pragma mark - UICollectionViewDataSource 数据源方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentify forIndexPath:indexPath];
    cell.title = self.dataArray[indexPath.row];
    cell.image = nil;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate 代理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // 判断当前是否连接蓝牙打印机
    if (self.bleManager.discoveredPeripheral.state != CBPeripheralStateConnected) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:done];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 0) {
        // 打印之前读取打印机状态，根据打印机状态决定下一步操作
        [self.bleManager readBlePrintStatus:3.0 success:^(JQBlePrintStatus blePrintStatus) {
            if (blePrintStatus == JQBlePrintStatusNoError) {
                [self printTestMovie];
            }
        } fail:^{
            [self showMessage:@"未读取到打印机状态！"];
        }];
    }else if (indexPath.row == 1){
        // 打印之前读取打印机状态，根据打印机状态决定下一步操作
        [self.bleManager readBlePrintStatus:3.0 success:^(JQBlePrintStatus blePrintStatus) {
            if (blePrintStatus == JQBlePrintStatusNoError) {
                [self printTestWayBill];
            }
        } fail:^{
            [self showMessage:@"未读取到打印机状态！"];
        }];
    }else if (indexPath.row == 2){
        [self.bleManager readBlePrintStatus:3.0 success:^(JQBlePrintStatus blePrintStatus) {
            if (blePrintStatus == JQBlePrintStatusNoError) {
                [self printTestQRCode];
            }
        } fail:^{
            [self showMessage:@"未读取到打印机状态！"];
        }];
    }
}

#pragma mark - 打印测试
// 打印电影票
- (void)printTestMovie{
    [self.cpclManager pageSetup:(575) pageHeight:(150)];
    // 中文标题
    JQLabel *titleLabel = [[JQLabel alloc] initWithStartPoint:CGPointMake(160, 2) text:@"华  天  国  际  影  城" fontSize:JQLabelFontSize32 rotate:JQLabelRotateNone bold:YES reverse:NO underline:NO];
    [titleLabel sendCmd];
    // 标题下加粗线
    CGFloat line1StartX = titleLabel.frame.origin.x - 2;
    CGFloat line1StartY = CGRectGetMaxY(titleLabel.frame) + 2;
    CGFloat line1EndX = CGRectGetMaxX(titleLabel.frame);
    CGFloat line1EndY = line1StartY;
    JQLine *line1 = [[JQLine alloc] initWithStartPoint:CGPointMake(line1StartX, line1StartY) endPoint:CGPointMake(line1EndX, line1EndY) lineWidth:3 lineType:YES];
    [line1 sendCmd];
    // 加粗线下英文标题
    CGFloat titleLabel1StartX = line1.frame.origin.x;
    CGFloat titleLabel1StartY = CGRectGetMaxY(line1.frame) + 2;
    JQLabel *titleLabel1 = [[JQLabel alloc] initWithStartPoint:CGPointMake(titleLabel1StartX, titleLabel1StartY) text:@"HUATIAN INTERNATIONAL CINEMAS" fontSize:JQLabelFontSize24 rotate:JQLabelRotateNone bold:YES reverse:NO underline:NO];
    [titleLabel1 sendCmd];
    
    [self.cpclManager print:0 skip:0];
}

// 打印电子运单
- (void)printTestWayBill{
    [self.cpclManager pageSetup:(568 + 4 + 16) pageHeight:(1436 - 8)];
    
    //第一联
    [self.cpclManager drawBox:(2) top_left_x:(2 + 4 + 4) top_left_y:(1) bottom_right_x:(566 + 6 + 16) bottom_right_y:(256 + 128 + 168 + 128)]; //第一联边框
    
    [self.cpclManager drawLine:(2) start_x:(2+4+4) start_y:(240) end_x:(566+6+16) end_y:(240) fullline:(NO)]; //第一联横线1
    
    [self.cpclManager drawLine:(2) start_x:(2+4+4) start_y:(384) end_x:(566+6+16) end_y:(384) fullline:(NO)]; //第一联横线2
    
    [self.cpclManager drawLine:(2) start_x:(2+4+4) start_y:(552) end_x:(566-32+6+16) end_y:(552) fullline:(NO)]; //第一联横线3
    
    [self.cpclManager drawLine:(2) start_x:(40+4+4) start_y:(384) end_x:(40+4+4) end_y:(680) fullline:(NO)]; //第一联竖线1，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(2+408+4+4) start_y:(552) end_x:(2+408+4+4) end_y:(680) fullline:(NO)]; //第一联竖线2，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(566 - 32 + 6 + 16) start_y:(384) end_x:(566 - 32 + 6 + 16) end_y:(680) fullline:(NO)]; //第一联竖线3，从左到右
    
    //二维码信息
    [self.cpclManager drawQrCode:(2 + 160) start_y:(16) text:@"www.yto.net.cn" rotate:0 ver:2 lel:5];
    
    //代收货款
    [self.cpclManager drawText:(2+320) text_y:(16+8) text:@"代收货款" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
    //金额
    [self.cpclManager drawText:(2+320) text_y:(48+8+8) text:@"金额：" fontSize:3 rotate:0 bold:0 reverse:NO underline:NO];
    //具体金额
    [self.cpclManager drawText:(2+8+400) text_y:(48+8+8) text:@"0.0元" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
    //目的地
    [self.cpclManager drawText:(2 + 166 + 32) text_y:(128 + 16 + 8) text:@"010" fontSize:6 rotate:0 bold:0 reverse:NO underline:NO];
    //条码
    [self.cpclManager drawBarCode:(2+160) start_y:(240+16) text:@"858691130534" type:1 rotate:0 linewidth:3 height:40];
    
    //条码字符
    [self.cpclManager drawText:(2+96+76+32) text_y:(340) text:@"858691130534" fontSize:3 rotate:0 bold:0 reverse:NO underline:NO];
    //收件人
    [self.cpclManager drawText:(2+4+4+4) text_y:(384+28) width:(32) height:(120) str:@"" fontsize:3 rotate:0 bold:1 underline:NO reverse:NO];
    //收件人姓名＋电话，最终实施时请用变量替换
    [self.cpclManager drawText:(2+4+32+8+4+4) text_y:(264+128) width:(480) height:(32) str:@"程远远 18721088532" fontsize:3 rotate:0 bold:1 underline:NO reverse:NO];
    //收件地址 ，最终实施时请用变量替换
    [self.cpclManager drawText:(2+4+32+8+4+4) text_y:(372+40+22) width:(480) height:(120) str:@"北京北京市朝阳区 北京曹威风威风威风 为氛围分为氛围阳曲" fontsize:3 rotate:0 bold:1 underline:NO reverse:NO];
    //寄件人
    [self.cpclManager drawText:(2+8+4+4) text_y:(552+22) width:(32) height:(96) str:@"寄件人" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //寄件人姓名＋电话，
    [self.cpclManager drawText:(2+4+32+8+4+4) text_y:(552+8) width:(480) height:(24) str:@"chenxiang 13512345678" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //寄件人地址
    [self.cpclManager drawText:(2+4+32+8+4+4) text_y:(552+40) width:(344) height:(112) str:@"上海市青浦区   华新镇华徐公路" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //签收人
    [self.cpclManager drawText:(2+424) text_y:(552+8) text:@"签收人：" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    //日期
    [self.cpclManager drawText:(2+424) text_y:(680-26) text:@"日期" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    //派件联
    [self.cpclManager drawText:(566-32+3+6+16) text_y:(384+128) width:(32) height:(96) str:@"派件联" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    
    //第二联
    [self.cpclManager drawBox:(2) top_left_x:(2+4+4) top_left_y:(680+16) bottom_right_x:(566+6+16) bottom_right_y:(680+16+288)];//第二联边框
    
    //[self.cpclManager drawLine:() start_x:() start_y:() end_x:() end_y:() fullline:NO];
    [self.cpclManager drawLine:(2) start_x:(2+4+4) start_y:(696+32) end_x:(566+6+16) end_y:(696+32) fullline:NO]; //第二联横线1，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(2+4+4) start_y:(696+160) end_x:(566-32+6+16) end_y:(696+160) fullline:NO]; //第二联横线2，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(2+40+4+4) start_y:(696+160+96) end_x:(566-32+6+16) end_y:(696+160+96) fullline:NO]; //第二联横线3，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(2+40+4+4) start_y:(696+32) end_x:(2+40+4+4) end_y:(696+288) fullline:NO]; //第二联竖线1，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(248+42+4+4) start_y:(696+160+96) end_x:(248+42+4+4) end_y:(680+16+288) fullline:NO]; //第二联竖线2，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(566-32+6+16) start_y:(696+32) end_x:(566-32+6+16) end_y:(680+16+288) fullline:NO]; //第二联竖线3，从左到右
    
    //运单号+运单号
    [self.cpclManager drawText:(2+8+4+4) text_y:(696+3) text:@"运单号：858691130534 订单号：DD00000014486" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    //收件人
    [self.cpclManager drawText:(2+8+4+4) text_y:(696+32+16) width:(32) height:(96) str:@"收件人" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //收件人姓名＋电话，最终实施时请用变量替换
    [self.cpclManager drawText:(2+8+32+8+4+4) text_y:(608+128) width:(480) height:(24) str:@"程远远 18721088532 " fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //收件地址 ，最终实施时请用变量替换
    [self.cpclManager drawText:(2+8+32+8+4+4) text_y:(696+32+40+2) width:(424) height:(80) str:@"北京北京市朝阳区 北京曹威风威风威风 为氛围分为氛围阳曲" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //寄件人
    [self.cpclManager drawText:(2+8) text_y:(744) width:(32) height:(96) str:@"寄件人" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //寄件人姓名＋电话，
    [self.cpclManager drawText:(2+4+32+8) text_y:(736) width:(480) height:(24) str:@"张三 12345678910" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //寄件人地址
    [self.cpclManager drawText:(2+4+32+8) text_y:(768) width:(456) height:(72) str:@"圆通速递 华新镇华徐公路3029弄28号" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //		//内容品名
    [self.cpclManager drawText:(2+8+4+4) text_y:(696+160+3+4) width:(32) height:(120) str:@"内容品名" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //内容品名具体
    [self.cpclManager drawText:(2+4+32+8+4+4) text_y:(696+160+8) width:(432) height:(136) str:@"0" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //数量
    [self.cpclManager drawText:(2+4+32+8+4+4) text_y:(696+160+96+4) text:@"数量：1" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    //重量
    [self.cpclManager drawText:(2+410) text_y:(696+160+96+4) text:@"重量：0kg" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    //		//收件联
    [self.cpclManager drawText:(566-32+3+6+16) text_y:(696+32+80) width:(32) height:(96) str:@"" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //虚线
    //		iPrinter.drawLine(2, 2, 992, 566, 992,false);//
    
    //第三联
    [self.cpclManager drawBox:(2) top_left_x:(2+4+4) top_left_y:(1096) bottom_right_x:(566+6+16) bottom_right_y:(1000 + 432 - 4 - 16)];//第三联边框
    
    [self.cpclManager drawLine:(2) start_x:(2+4+4) start_y:(1096) end_x:(566-32+6+16) end_y:(1096) fullline:NO]; //第三联横线1，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(2+4+4) start_y:(1096+104-8) end_x:(566-32+6+16) end_y:(1096+104-8) fullline:NO]; //第三联横线2，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(2+4+4) start_y:(1096+104+104-8) end_x:(566-32+6+16) end_y:(1096+104+104-8) fullline:NO]; //第三联横线3，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(2 + 40 + 4 + 4) start_y:(1096 + 104 + 104 + 96 + 4 - 4 - 2 - 8 - 4) end_x:(566 - 32 + 6 + 16) end_y:(1096 + 104 + 104 + 96 + 4 - 4 - 2 - 8 - 4) fullline:NO]; //第三联横线4，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(2 + 40 + 4 + 4 - 4) start_y:(1096) end_x:(2 + 40 + 4 + 4 - 4) end_y:(1432 - 4 - 16) fullline:NO]; //第三联竖线1，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(248 + 42 + 4 + 4) start_y:(1096 + 104 + 104 + 96 - 8) end_x:(248 + 42 + 4 + 4) end_y:(1432 - 4 - 16) fullline:NO]; //第三联竖线2，从左到右
    
    [self.cpclManager drawLine:(2) start_x:(566 - 32 + 6 + 16) start_y:(1096) end_x:(566 - 32 + 6 + 16) end_y:(1432 - 4 - 16) fullline:NO]; //第三联竖线3，从左到右
    
    //条码
    [self.cpclManager drawBarCode:(2 + 250 + 4) start_y:(1000 + 8) text:@"858691130534" type:(1) rotate:0 linewidth:3 height:28];
    //条码数据
    [self.cpclManager drawText:(2+312) text_y:(1008+56+4) text:@"858691130534" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    
    //收件人
    [self.cpclManager drawText:(2+8+4) text_y:(1096+5) width:(32) height:(96) str:@"收件人" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //收件人姓名＋电话，最终实施时请用变量替换
    [self.cpclManager drawText:(2+8+32+8+4+4) text_y:(1096+8) width:(480) height:(24) str:@"程远远 18721088532 " fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //收件地址 ，最终实施时请用变量替换
    [self.cpclManager drawText:(2+8+32+8+4+4) text_y:(1096+8+24+8) width:(456) height:(64) str:@"北京北京市朝阳区 北京曹威风威风威风 为氛围分为氛围阳曲" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //寄件人
    [self.cpclManager drawText:(2+8+4+4) text_y:(1096+104+5) width:(32) height:(96) str:@"寄件人" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //寄件人姓名＋电话，
    [self.cpclManager drawText:(2+4+32+8+4+4) text_y:(1096+104+8) width:(480) height:(24) str:@"chenxiang 13512345678 " fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //寄件人地址
    [self.cpclManager drawText:(2+4+32+8+4+4) text_y:(1096+104+8+24+8) width:(456) height:(72) str:@"上海市青浦区   华新镇华徐公路" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //内容品名
    [self.cpclManager drawText:(2+8+4+4) text_y:(1096+104+104+1) width:(32) height:(120) str:@"内容品名" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //内容品名具体
    [self.cpclManager drawText:(2 + 4 + 32 + 8 + 4 + 4) text_y:(1096 + 104 + 104 + 8) width:(432) height:(156) str:@"0" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    //数量
    [self.cpclManager drawText:(2 + 4 + 32 + 8 + 4 + 4) text_y:(1432 - 32 + 4 - 4 - 8 - 4) text:@"数量：1" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    //重量
    [self.cpclManager drawText:(2 + 400) text_y:(1432 - 32 + 4 - 4 - 8 - 4) text:@"重量：0kg" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    //寄件联
    [self.cpclManager drawText:(566 - 32 + 3 + 6 + 16) text_y:(1096 + 104 + 16) width:(32) height:(96) str:@"寄件联" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
    
    [self.cpclManager print:0 skip:1];
}

// 打印二维码
- (void)printTestQRCode{
    [self.cpclManager pageSetup:(575) pageHeight:(240)];
    [self.cpclManager drawQrCode:(200) start_y:(100) text:self.bleManager.discoveredPeripheral.name rotate:0 ver:2 lel:5];
    [self.cpclManager print:0 skip:1];
}

@end
