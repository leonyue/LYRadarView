//
//  ViewController.m
//  LYRadarView
//
//  Created by dj.yue on 2017/10/27.
//  Copyright © 2017年 dj.yue. All rights reserved.
//

#import "ViewController.h"
#import "LYRadarView.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager            *locationManager;
@property (strong, nonatomic) IBOutlet LYRadarView *radarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.locationManager startUpdatingHeading];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)slideA:(UISlider *)sender {
    self.radarView.aircraftToCenterPercent = sender.value;
}
- (IBAction)slideB:(UISlider *)sender {
    self.radarView.aircraftAngle = sender.value;
}
- (IBAction)slideC:(UISlider *)sender {
    self.radarView.aircraftRotateAngle = sender.value;
}
- (IBAction)slideD:(UISlider *)sender {
    self.radarView.innerCircleCount = (int)sender.value;
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    CGFloat angle = newHeading.magneticHeading / 180 * M_PI;
     UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            _radarView.northAngle = -angle;
            break;
        case UIInterfaceOrientationLandscapeRight:
            _radarView.northAngle = -angle + M_PI;
            break;
        case UIInterfaceOrientationPortrait:
            _radarView.northAngle = -angle - M_PI_2;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            _radarView.northAngle = -angle + M_PI_2;
            break;
        default:
            break;
    }
}

#pragma mark - get & set

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

@end
