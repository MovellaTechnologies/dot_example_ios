# dot_example_iOS

## Get start
1. git clone https://github.com/MovellaTechnologies/dot_example_ios
2. pod install
3. open MovellaDotExampleiOS.xcworkspace
4. Please use a real iPhone to run with the sample code , the simulator will appear errors.

## Main methods
* Scan sensors

1. Set the delegate
```
[DotConnectionManager setConnectionDelegate:self]; 
```
2. Start scan
```
@property (strong, nonatomic) NSMutableArray<DotDevice *> *deviceList;
```
```
[DotConnectionManager scan];
```
```
- (void)onDiscoverDevice:(DotDevice *)device
{
    NSInteger index = [self.deviceList indexOfObject:device];
    if(index == NSNotFound)
    {
        [self.deviceList addObject:device];
    }
}
```
* Connect a sensor

```
DotDevice *device = self.deviceList.firstObject;
[DotConnectionManager connect:device];
```

* Synchronization

```
DotSyncResultBolck block = ^(NSArray *array)
    {

    };
[DotSyncManager startSync:self.deviceList result:block];
```

* Measurement

```
DotDevice *device = self.deviceList.firstObject;
device.plotMeasureMode = XSBleDevicePayloadCompleteEuler;
device.plotMeasureEnable = YES;
```

## For more details, please visit : [https://www.movella.com/developer](https://www.movella.com/products/wearables/movella-dot)



