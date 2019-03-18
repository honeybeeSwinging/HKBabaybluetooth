# HKBabaybluetooth
>基于BabyBluetooth开源库的二次封装，几行代码搞定iOS蓝牙开发。

### 📃功能：
>包括但不仅限于：
>> 1、检测权限。<br>
>> 2、扫描设备。<br>
>> 3、发现设备。<br>
>> 4、连接设备。<br>
>> 5、断开设备。<br>
>> 6、收发消息。<br>
>>> 适用于一般情况下的蓝牙开发。

### 🔨使用：
##### 1 - 首先将工程中的“HKBLE”文件夹拷贝至项目中。
##### 2 - 在需要使用的类中引入头文件：
```Objective-C
#import "HKBabyBluetoothManager.h"
```
##### 3 - 创建一个全局对象：
```Objective-C
{
    HKBabyBluetoothManager *_babyMgr;
}
```
##### 4 - 初始化并设置代理：
```Objective-C
    _babyMgr = [HKBabyBluetoothManager sharedManager];
    _babyMgr.delegate = self;
```
##### 5 - 遵守HKBabyBluetoothManageDelegate代理：
```Objective-C
<HKBabyBluetoothManageDelegate>
```

##### 6 - 以下为HKBabyBluetoothManageDelegate代理的方法回调：
###### 6.1 - 如果系统蓝牙未打开：
```Objective-C
- (void)systemBluetoothClose {
    // 系统蓝牙被关闭、提示用户去开启蓝牙
}
```
###### 6.2 - 系统蓝牙权限已开启调用扫描设备：
```Objective-C
- (void)sysytemBluetoothOpen {
    // 系统蓝牙已开启、开始扫描周边的蓝牙设备
    [_babyMgr startScanPeripheral];
}
```
###### 6.3 - 获取周边被扫描到的设备、加到设备数据源中:
```Objective-C
- (void)getScanResultPeripherals:(NSArray *)peripheralInfoArr {
    // 这里获取到扫描到的蓝牙外设数组、添加至数据源中
    if (self.dataSource.count>0) {
        [self.dataSource removeAllObjects];
    }
    
    [self.dataSource addObjectsFromArray:peripheralInfoArr];
    [self.tableView reloadData];
}
```
###### 6.4 - 点击连接所需要连接的设备：
```Objective-C
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HKPeripheralInfo *info = self.dataSource[indexPath.row];
    // 去连接当前选择的Peripheral
    [_babyMgr connectPeripheral:info.peripheral];
}
```
###### 6.5 - 连接成功或连接失败:
```Objective-C
- (void)connectSuccess {
    // 连接成功 写入UUID值【替换成自己的蓝牙设备UUID值】
    _babyMgr.serverUUIDString = @"XXXX-XXXX-XXXX-XXXX";
    _babyMgr.writeUUIDString = @"YYYY-YYYY-YYYY-YYYY";
    _babyMgr.readUUIDString = @"ZZZZ-ZZZZ-ZZZZ-ZZZZ";
    
}

- (void)connectFailed {
    // 连接失败、做连接失败的处理
}
```
###### 6.6 - 消息数据的读写:
```Objective-C
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
```
###### 6.7 - 断开蓝牙设备:
```Objective-C
- (IBAction)disconnectAction:(UIButton *)sender {
    // 断开连接
    // 1、可以选择断开所有设备
    // 2、也选择断开当前peripheral
    [_babyMgr disconnectAllPeripherals];
    //[_babyMgr disconnectLastPeripheral:(CBPeripheral *)];
}
```
###### 6.8 - 设备断开后回调:
```Objective-C
- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    // 获取到当前断开的设备 这里可做断开UI提示处理
    
}
```
###### 6.9 - 自动连接：
>如果需求有要求上一次连接使用过的蓝牙设备在下一次使用时能够自动连接上，我们可以这样处理：
>>1、在连接蓝牙设备成功后将蓝牙设备的id值存储在沙盒下。<br>
>>2、在获取到扫描的设备数组的地方，对蓝牙设备数组的id进行遍历，如果存在与沙盒下缓存的蓝牙设备id一致，则对当前设备进行连接。
>>>这样就能做到自动连接设备的效果了。

### ⛓️接口：
```Objective-C
// 设置蓝牙的前缀【开发者必须改为自己的蓝牙设备前缀】
#define kMyDevicePrefix (@"myDevice")
// 设置蓝牙的channel值【开发者可不做修改】
#define channelOnPeropheralView @"peripheralView"

@protocol HKBabyBluetoothManageDelegate <NSObject>

@optional

/**
 蓝牙被关闭
 */
- (void)systemBluetoothClose;

/**
 蓝牙已开启
 */
- (void)sysytemBluetoothOpen;

/**
 扫描到的设备回调
 
 @param peripheralInfoArr 扫描到的蓝牙设备数组
 */
- (void)getScanResultPeripherals:(NSArray *)peripheralInfoArr;

/**
 连接成功
 */
- (void)connectSuccess;

/**
 连接失败
 */
- (void)connectFailed;

/**
 当前断开的设备
 
 @param peripheral 断开的peripheral信息
 */
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;

/**
 读取蓝牙数据
 
 @param valueData 蓝牙设备发送过来的data数据
 */
- (void)readData:(NSData *)valueData;

@end


@interface HKBabyBluetoothManager : NSObject

//外设的服务UUID值
@property (nonatomic, copy) NSString *serverUUIDString;
//外设的写入UUID值
@property (nonatomic, copy) NSString *writeUUIDString;
//外设的读取UUID值
@property (nonatomic, copy) NSString *readUUIDString;

/**
 单例
 
 @return 单例对象
 */
+ (HKBabyBluetoothManager *)sharedManager;

@property (nonatomic, weak) id<HKBabyBluetoothManageDelegate> delegate;


/**
 开始扫描周边蓝牙设备
 */
- (void)startScanPeripheral;

/**
 停止扫描
 */
- (void)stopScanPeripheral;

/**
 连接所选取的蓝牙外设
 
 @param peripheral 所选择蓝牙外设的perioheral
 */
-(void)connectPeripheral:(CBPeripheral *)peripheral;

/**
 获取当前连接成功的蓝牙设备数组
 
 @return 返回当前所连接成功蓝牙设备数组
 */
- (NSArray *)getCurrentPeripherals;

/**
 获取设备的服务跟特征值
 当已连接成功时调用有效
 */
- (void)searchServerAndCharacteristicUUID;

/**
 断开当前连接的所有蓝牙设备
 */
- (void)disconnectAllPeripherals;

/**
 断开所选择的蓝牙设备
 
 @param peripheral 所选择蓝牙外设的perioheral
 */
- (void)disconnectLastPeripheral:(CBPeripheral *)peripheral;

/**
 向蓝牙设备发送数据
 
 @param msgData 数据data值
 */
- (void)write:(NSData *)msgData;
```

### ⚠️注意：
>Demo已将BabyBluetooth开源库移除，如需运行Demo请使用CocoaPods将BabyBluetooth库导入工程中。(Demo中使用的BabyBluetooth开源库的版本是：0.7.0)

### ☎️联系：
>🐧:1625277373<br>
>📧:lhk0220@hotmail.com

### 🌟感谢
>感谢阅读，如果对您有帮助，劳烦Star一下！谢谢...











