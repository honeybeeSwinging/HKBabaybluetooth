//
//  ViewController.m
//  HKBabyBluetooth
//
//  Created by 刘华坤 on 2019/3/15.
//  Copyright © 2019年 liuhuakun. All rights reserved.
//

#import "ViewController.h"

#import "HKBabyBluetoothManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, HKBabyBluetoothManageDelegate>
{
    HKBabyBluetoothManager *_babyMgr;
}

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

#pragma mark lazy - load
- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHKBabyBluetooth];
}

- (void)initHKBabyBluetooth {
    _babyMgr = [HKBabyBluetoothManager sharedManager];
    _babyMgr.delegate = self;
}


#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellId"];
    }
    
    HKPeripheralInfo *info = self.dataSource[indexPath.row];
    cell.textLabel.text = info.peripheral.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HKPeripheralInfo *info = self.dataSource[indexPath.row];
    
    // 去连接当前选择的Peripheral
    [_babyMgr connectPeripheral:info.peripheral];
}


#pragma mark HKBabyBluetoothManageDelegate 代理回调
- (void)systemBluetoothClose {
    // 系统蓝牙被关闭、提示用户去开启蓝牙
}

- (void)sysytemBluetoothOpen {
    // 系统蓝牙已开启、开始扫描周边的蓝牙设备
    [_babyMgr startScanPeripheral];
}

- (void)getScanResultPeripherals:(NSArray *)peripheralInfoArr {
    // 这里获取到扫描到的蓝牙外设数组、添加至数据源中
    if (self.dataSource.count>0) {
        [self.dataSource removeAllObjects];
    }
    
    [self.dataSource addObjectsFromArray:peripheralInfoArr];
    [self.tableView reloadData];
}

- (void)connectSuccess {
    // 连接成功 写入UUID值【替换成自己的蓝牙设备UUID值】
    _babyMgr.serverUUIDString = @"XXXX-XXXX-XXXX-XXXX";
    _babyMgr.writeUUIDString = @"YYYY-YYYY-YYYY-YYYY";
    _babyMgr.readUUIDString = @"ZZZZ-ZZZZ-ZZZZ-ZZZZ";
    
}

- (void)connectFailed {
    // 连接失败、做连接失败的处理
}

- (IBAction)sendAction:(UIButton *)sender {
    // 向蓝牙发数据 转化为data类型
    Byte byte[] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07};
    NSData *data = [[NSData dataWithBytes:&byte
                                   length:sizeof(&byte)]
                    subdataWithRange:NSMakeRange(0, 8)];
    [_babyMgr write:data];
}

- (void)readData:(NSData *)valueData {
    // 获取到蓝牙设备发来的数据
    NSLog(@"蓝牙发来的数据 = %@",[NSString stringWithFormat:@"%@",valueData]);
}

- (IBAction)disconnectAction:(UIButton *)sender {
    // 断开连接
    // 1、可以选择断开所有设备
    // 2、也选择断开当前peripheral
    [_babyMgr disconnectAllPeripherals];
    //[_babyMgr disconnectLastPeripheral:(CBPeripheral *)];
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    // 获取到当前断开的设备 这里可做断开UI提示处理
    
}



@end
