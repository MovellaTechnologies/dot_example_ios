//
//  OtaViewController.h
//  MovellaDotExampleiOS
//
//  Created by Jayson on 2021/7/7.
//  Copyright © 2021 Movella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MovellaDotSdk/DotDevice.h>
NS_ASSUME_NONNULL_BEGIN

@interface OtaViewController : UIViewController

@property (strong, nonatomic) DotDevice *device;

@end

NS_ASSUME_NONNULL_END
