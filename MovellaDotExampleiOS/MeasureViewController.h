//
//  MeasureViewController.h
//  MovellaDotExampleiOS
//
//  Created by Jayson on 2020/8/26.
//  Copyright © 2020 Movella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MovellaDotSdk/DotDevice.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeasureViewController : UIViewController

/// The measureing devices
@property (strong, nonatomic) NSArray<DotDevice *> *measureDevices;

@end

NS_ASSUME_NONNULL_END
