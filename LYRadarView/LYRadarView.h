//
//  LYRadarView.h
//  LYRadarView
//
//  Created by dj.yue on 2017/10/27.
//  Copyright © 2017年 dj.yue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYRadarView : UIView

@property (nonatomic, assign) int    innerCircleCount;
@property (nonatomic, assign) float  aircraftToCenterPercent;
@property (nonatomic, assign) double aircraftAngle;
@property (nonatomic, assign) double aircraftRotateAngle;
@property (nonatomic, assign) double northAngle;

@end
