//
//  MainViewController.m
//  MovellaDotDebug
//
//  Created by Jayson on 2020/6/5.
//  Copyright © 2020 Movella. All rights reserved.
//

#import "MainViewController.h"
#import "DeviceConnectCell.h"
#import "MeasureViewController.h"
#import "OtaViewController.h"
#import "MfmViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <MovellaDotSdk/DotDevice.h>
#import <MovellaDotSdk/DotLog.h>
#import <MovellaDotSdk/DotDevicePool.h>
#import <MovellaDotSdk/DotConnectionManager.h>
#import <MovellaDotSdk/DotReconnectManager.h>
#import <MBProgressHUD.h>

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource, DotConnectionDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<DotDevice *> *deviceList;
@property (strong, nonatomic) NSMutableArray *connectList;
@property (strong, nonatomic) UIButton *measureButton;

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /// Set Dot connection delete
    [DotConnectionManager setConnectionDelegate:self];
    /// Set log enable
    [DotLog setLogEnable:YES];
    /// Set reconnection enable
    [DotReconnectManager setEnable:YES];
    /// Add notifications
    [self addObservers];
    
    /// Refresh tableview back from MeasureViewController
    if (self.connectList.count != 0)
    {
        [self.tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableView.mj_header endRefreshing];
    /// Stop ble scan
    [DotConnectionManager stopScan];
    /// Remove notifications
    [self removeObservers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deviceList = [NSMutableArray arrayWithCapacity:20];
    self.connectList = [NSMutableArray arrayWithCapacity:20];
    [self navigationItemsSetup];
    [self setupViews];
}

- (void)navigationItemsSetup
{
    self.title = @"MovellaDOT Example";
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"Menu" menu:[self createMenu]];
    [item setTintColor:UIColor.whiteColor];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationItem.rightBarButtonItem = item;
}

- (UIMenu *)createMenu{
    UIAction *measure = [UIAction actionWithTitle:@"Measure" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self handleMeasure:nil];
    }];
    
    UIAction *ota = [UIAction actionWithTitle:@"OTA" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self handleOta];
    }];
    
    UIAction *mfm = [UIAction actionWithTitle:@"MFM" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self handleMfm];
    }];
    
    NSArray *menus = [[NSArray alloc]initWithObjects:measure, ota, mfm, nil];
    
    UIMenu *menu = [UIMenu menuWithTitle:@"" children:menus];
    
    return menu;
}


- (void)setupViews
{
    UIView *baseView = self.view;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self scanDevices];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    CGRect frame = baseView.bounds;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.mj_header = header;
    self.tableView = tableView;
    
    [baseView addSubview:tableView];
}

- (UIButton *)measureButton
{
    if (_measureButton == nil)
    {
        _measureButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_measureButton setTitle:@"Measure" forState:UIControlStateNormal];
        [_measureButton setTintColor:[UIColor whiteColor]];
        _measureButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        [_measureButton addTarget:self action:@selector(handleMeasure:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _measureButton;
}

/// Update UITableViewCell status
- (void)updateDeviceCellStatus
{
    NSArray *cells = self.tableView.visibleCells;
    if(cells.count > 0)
    {
        for(DeviceConnectCell *cell in cells)
        {
            [cell refreshDeviceStatus];
        }
    }
}

/// Start ble scan
- (void)scanDevices
{
    if(![DotConnectionManager managerStateIsPoweredOn])
    {
        [self.tableView.mj_header endRefreshing];
        NSLog(@"Please enable bluetoooth first");
        return;
    }
    [self.deviceList removeAllObjects];
    if (self.connectList.count != 0)
    {
        [self.deviceList addObjectsFromArray:self.connectList];
    }
    [self.tableView reloadData];
    /// Start scan
    [DotConnectionManager scan];
}

#pragma mark -- Logic

/// Disconnect all sensors.
- (void)disconnectAll
{
    for (DotDevice *device in self.connectList)
    {
        [DotConnectionManager disconnect:device];
    }
}

/// Show no sensor connected
- (void)showUnconnectHud
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, 200);
    hud.label.text = @"Please connect at least a sensor";
    [hud hideAnimated:YES afterDelay:1.0f];
}

/// Show sensor not initialized
- (void)showNotInitialized
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, 200);
    hud.label.text = @"Please wait for sensor initialization";
    [hud hideAnimated:YES afterDelay:1.0f];
}


#pragma mark -- TouchEvent

/// Handle the switch button of UITableViewCell tapped
- (void)onCellConnectButtonTapped:(DeviceConnectCell *)cell
{
    DotDevice *device = cell.device;
    if(device.state != CBPeripheralStateConnected)
    {
        [self.connectList addObject:device];
        /// connect a sensor
        [DotConnectionManager connect:device];
        /// add to DevicePool.
        /// Reconnection has Two conditions,please also unbind it after disconnected .
        /// 1. [DotReconnectManager setEnable:YES];
        /// 2. [DotDevicePool bindDevice:device]
        [DotDevicePool bindDevice:device];
    }
    else
    {
        [self.connectList removeObject:device];
        /// Disconnect the sensor
        [DotConnectionManager disconnect:device];
        /// Remove from the DevicePool
        [DotDevicePool unbindDevice:device];
    }
    
    [cell refreshDeviceStatus];
}

/// Handle measure button tapped
- (void)handleMeasure:(UIButton *)sender
{
    if (self.connectList.count == 0)
    {
        [self showUnconnectHud];
    }
    else
    {
        MeasureViewController *measureViewController = [MeasureViewController new];
        measureViewController.measureDevices = self.connectList;
        [self.navigationController pushViewController:measureViewController animated:YES];
    }
}

/**
 * This is the demo for one sensor to do the OTA function
 * If you want to do OTA for multiple sensors,
 * please make sure to upgrade in sequence, when the first upgrade succeeds, upgrade the next one, and so on.
 */
- (void)handleOta
{
    if (self.connectList.count == 0)
    {
        [self showUnconnectHud];
    }
    else
    {
        if ([self.connectList.firstObject isInitialized])
        {
            OtaViewController *otaViewController = [OtaViewController new];
            otaViewController.device = self.connectList.firstObject;
            [self.navigationController pushViewController:otaViewController animated:YES];
        }
        else
        {
            [self showNotInitialized];
        }
        
    }
}

/**
 * This is the demo for  MFM function
 */
- (void)handleMfm
{
    if (self.connectList.count == 0)
    {
        [self showUnconnectHud];
    }
    else
    {
        if ([self.connectList.firstObject isInitialized])
        {
            MfmViewController *mfmViewController = [MfmViewController new];
            mfmViewController.mfmDevices = self.connectList;
            [self.navigationController pushViewController:mfmViewController animated:YES];
        }
        else
        {
            [self showNotInitialized];
        }
        
    }
}

#pragma mark -- XSConnectionDelegate


/// Ble scan done
- (void)onScanCompleted
{
    [self.tableView.mj_header endRefreshing];
}

/// Dot device connect failed
/// @param device DotDevice
- (void)onDeviceConnectFailed:(DotDevice *)device
{
    [self updateDeviceCellStatus];
}

/// Dot device disconnected
/// @param device DotDevice
- (void)onDeviceDisconnected:(DotDevice *)device
{
    [self updateDeviceCellStatus];
}

/// Dot device connect success
/// @param device DotDevice
- (void)onDeviceConnectSucceeded:(DotDevice *)device
{
    [self updateDeviceCellStatus];
}

/// Discovered Dot device
/// @param device DotDevice
- (void)onDiscoverDevice:(DotDevice *)device
{
    NSInteger index = [self.deviceList indexOfObject:device];
    if(index == NSNotFound)
    {
        if(![self.deviceList containsObject:device])
        {
            [self.deviceList addObject:device];
            [self.tableView reloadData];
        }
    }
}

/// Listen changes in Bluetooth status
/// @param managerState  XSDotManagerState
- (void)onManagerStateUpdate:(XSDotManagerState)managerState
{
    [self updateDeviceCellStatus];
    if(managerState != XSDotManagerStatePoweredOn)
    {
        [self.tableView.mj_header endRefreshing];
    }
    else
    {
        if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
        {
            [self.tableView.mj_header beginRefreshing];
        }
    }
}

#pragma mark -- Notification

/// Receive the notification of kDotNotificationDeviceBatteryDidUpdate
- (void)onDeviceBatteryUpdated:(NSNotification *)sender
{
    [self updateDeviceCellStatus];
}

/// Receive the notification of kDotNotificationDeviceNameDidRead
- (void)onDeviceTagRead:(NSNotification *)sender
{
    [self updateDeviceCellStatus];
}

/// Add notifications
- (void)addObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onDeviceBatteryUpdated:) name:kDotNotificationDeviceBatteryDidUpdate object:nil];
    [center addObserver:self selector:@selector(onDeviceTagRead:) name:kDotNotificationDeviceNameDidRead object:nil];
}

/// Remove notifications
- (void)removeObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kDotNotificationDeviceBatteryDidUpdate object:nil];
    [center removeObserver:self name:kDotNotificationDeviceNameDidRead object:nil];
}


#pragma mark -- UITableViewDataSource &  UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [DeviceConnectCell cellIdentifier];;
    DeviceConnectCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil)
    {
        cell = [[DeviceConnectCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
        cell.connectAction = ^(DeviceConnectCell * _Nonnull cell) {
            [self onCellConnectButtonTapped:cell];
        };
    }
    
    cell.device = self.deviceList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DeviceConnectCell.cellHeight;
}

@end
