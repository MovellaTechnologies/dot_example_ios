//
//  DeviceMfmCell.h
//  Movella DOT
//
//  Created by admin on 2020/9/15.
//  Copyright © 2020 Movella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MovellaDotSdk/DotDevice.h>
NS_ASSUME_NONNULL_BEGIN

@interface DeviceMfmCell : UITableViewCell

@property (strong, nonatomic) DotDevice *device;

- (void)cellInProgress:(int)progress;
- (void)cellFinished;
- (void)cellStopped;
- (void)cellDisconnected;
- (void)cellFailed;

+ (NSString *)cellIdentifier;
+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
