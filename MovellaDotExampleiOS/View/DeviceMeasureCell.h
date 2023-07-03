//
//  DeviceMeasureCell.h
//  MovellaDotExampleiOS
//
//  Created by Jayson on 2020/8/26.
//  Copyright © 2020 Movella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MovellaDotSdk/DotDevice.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceMeasureCell : UITableViewCell

@property (strong, nonatomic) DotDevice *device;

+ (NSString *)cellIdentifier;
+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
