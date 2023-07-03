//
//  MfmViewController.h
//  MovellaDotExampleiOS
//
//  Created by Jayson on 2021/11/30.
//  Copyright © 2021 Movella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MovellaDotSdk/DotDevice.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XSDeviceMFMState)
{
    XSDeviceMFMStateDefault = 0,
    XSDeviceMFMStateStart,
    XSDeviceMFMStateProcessing,
    XSDeviceMFMStateComplete
};

@interface MfmViewController : UIViewController

@property (strong, nonatomic) NSArray<DotDevice *> *mfmDevices;

@end

NS_ASSUME_NONNULL_END
