//
//  LYRadarView.m
//  LYRadarView
//
//  Created by dj.yue on 2017/10/27.
//  Copyright © 2017年 dj.yue. All rights reserved.
//

#import "LYRadarView.h"

static const CGFloat    kOuterCircleWidth    = .5f;
static const CGFloat    kInnerCircleWidth    = .5f;
static const CGFloat    kInnerCircleDashLenghts[2]    =  {4.f, 2.f};
static const CGFloat    kCrossLineWidth      = .5f;
static const CGFloat    kTriAngleWidth       = 5.f;
static const CGFloat    kRadarEdge           = 5.f;

@interface LYRadarView() {
    double scanStartAngle;
}

@property (nonatomic, weak) CADisplayLink *dl;
@property (nonatomic, assign) NSTimeInterval northAngleAnimStartAt;
@property (nonatomic, assign) double northAngleAddPerSeconds; ///< anim finish in 0.3s
@property (nonatomic, assign) double northAngleDest;

@end

@implementation LYRadarView

#pragma mark - inherit

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)dealloc {
    [self.dl invalidate];
    self.dl = nil;
}

#pragma mark - private

- (void)setUp {
    self.innerCircleCount = 2;
    self.aircraftToCenterPercent = 0.2;
    self.aircraftAngle = M_PI_4;
    self.aircraftRotateAngle = M_PI_2;
    self.northAngle = M_PI_4 * 5;
    
    self.backgroundColor = [UIColor clearColor];
    CADisplayLink *dl = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [dl addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.dl = dl;
}

#pragma mark - setter

- (void)setNorthAngle:(double)northAngle {
    if (northAngle != _northAngle) {
        self.northAngleAnimStartAt = self.dl.timestamp;
        
        ///0 ~ 360
        while (northAngle > M_PI * 2) northAngle -= M_PI * 2;
        while (northAngle < 0) northAngle += M_PI * 2;
        
        while (_northAngle > M_PI * 2) _northAngle -= M_PI * 2;
        while (_northAngle < 0) _northAngle += M_PI * 2;
        
        
        double diff;
        ///choose a smaller arc
        if (northAngle - _northAngle > M_PI) {
            _northAngle += M_PI * 2;
        } else if (northAngle - _northAngle < -M_PI) {
            _northAngle -= M_PI * 2;
        }
        
        diff = northAngle - _northAngle;
        
        self.northAngleAddPerSeconds = diff / 0.3f;
        self.northAngleDest = northAngle;
    }
}

#pragma mark - refresh

- (void)update:(CADisplayLink *)link {
    //animate scan
    scanStartAngle += (M_PI * link.duration / 3.f); //half circle per 3 seconds
    if (scanStartAngle > M_PI * 2) scanStartAngle -= M_PI * 2;
    
    //animate north
    if (self.northAngleDest == self.northAngle) {
    } else if (fabs(self.northAngleDest - self.northAngle) < fabs(self.northAngleAddPerSeconds *  (link.timestamp - self.northAngleAnimStartAt))) {
        _northAngle = self.northAngleDest;
    } else {
        _northAngle += self.northAngleAddPerSeconds *  (link.timestamp - self.northAngleAnimStartAt);
    }
    
    [self setNeedsDisplay];
}


- (void)testAnim:(CADisplayLink *)link {
}

#pragma mark - draw

- (void)drawRect:(CGRect)rect {
    CGFloat radarRadius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2.f - kRadarEdge;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    [self drawOuterCircleWithRadius:radarRadius center:center];
    [self drawInnerCircleWithRadius:radarRadius center:center];
    [self drawHalfCircleWithRadius:radarRadius center:center];
    [self drawAircraftWithRadius:radarRadius center:center];
    [self drawHalfCircle2WithRadius:radarRadius center:center];
    [self drawCrossLineWithRadius:radarRadius center:center];
    [self drawHomeAtCenter:center];
    [self drawNorthWithRadius:radarRadius center:center];
}

- (void)drawOuterCircleWithRadius:(CGFloat)radius center:(CGPoint)center {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kOuterCircleWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.4].CGColor);
    CGContextAddArc(context, center.x, center.y, radius, 0, M_PI * 2, 1);
    CGContextStrokePath(context);
}

- (void)drawInnerCircleWithRadius:(CGFloat)radius center:(CGPoint)center {
    
    CGFloat innerCircleGap = radius / (self.innerCircleCount + 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kInnerCircleWidth);
    CGContextSetLineDash(context, 0, kInnerCircleDashLenghts, 2);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor);
    
    for (int i = 1; i < self.innerCircleCount + 1; i++) {
        CGContextAddArc(context, center.x, center.y, innerCircleGap * i, 0, M_PI * 2, 1);
        CGContextStrokePath(context);
    }
}

- (void)drawCrossLineWithRadius:(CGFloat)radius center:(CGPoint)center {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint top = CGPointMake(center.x, center.y - radius);
    
    CGPoint A,B,C;
    CGFloat a,b,c,d,r,R;
    double angleA,angleB,angleStart,angleEnd;
    angleA = M_PI / 6;
    r = kTriAngleWidth;
    R = radius;
    b = cos(angleA) * r;
    d = sin(angleA) * r;
    angleB = asin(d / R);
    c = cos(angleB) * R - b;
    a = R - b - c;
    A = B = C = top;
    A.x -= d;
    B.x += d;
    A.y += a;
    B.y += a;
    C.y += a;
    C.y += b;
    angleStart = M_PI * 3 / 2 + angleB;
    angleEnd   = M_PI * 3 / 2 - angleB;
    
    
    CGPoint hPoints[2] = {CGPointMake(center.x - radius, center.y), CGPointMake(center.x + radius, center.y)};
    CGPoint vPoints[2] = {CGPointMake(top.x, top.y + a), CGPointMake(center.x, center.y + radius)};
    CGContextSetLineWidth(context, kCrossLineWidth);
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor);
    CGContextAddLines(context, hPoints, 2);
    CGContextAddLines(context, vPoints, 2);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor);
    CGPoint ps[3] = {A,C,B};
    CGContextAddLines(context, ps, 3);
    CGContextAddArc(context, center.x, center.y, radius, angleStart, angleEnd, 1);
    CGContextFillPath(context);
}


- (void)drawHalfCircleWithRadius:(CGFloat)radius center:(CGPoint)center {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //#00ffa8
    int c = 0x00ffa8;
    UIColor *color = [UIColor colorWithRed:(c >> 8 & 0x0000FF) / 255.f green:(c >> 4 & 0x0000ff) / 255.f blue:(c & 0x0000ff) /255.f alpha:0.35];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddArc(context, center.x, center.y, radius, scanStartAngle, scanStartAngle + M_PI, 0);
    CGContextFillPath(context);
}

- (void)drawHalfCircle2WithRadius:(CGFloat)radius center:(CGPoint)center {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //#00ffa8
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor);
    CGContextAddArc(context, center.x, center.y, radius, scanStartAngle + M_PI, scanStartAngle + 2 * M_PI, 0);
    CGContextFillPath(context);
}

- (void)drawHomeAtCenter:(CGPoint)center {
    UIImage *image = [UIImage imageNamed:@"map_radar_home"];
    [self drawImage:image AtCenter:center];
}

- (void)drawNorthWithRadius:(CGFloat)radius center:(CGPoint)center {
    CGPoint p = center;
    CGFloat angle = self.northAngle;
    p.x += cos(angle) * radius;
    p.y += sin(angle) * radius;
    UIImage *image = [UIImage imageNamed:@"map_radar_north"];
    [self drawImage:image AtCenter:p];
}

- (void)drawAircraftWithRadius:(CGFloat)radius center:(CGPoint)center {
    CGPoint p = center;
    CGFloat angle = self.aircraftAngle;
    CGFloat r = radius * self.aircraftToCenterPercent;
    p.x += cos(angle) * r;
    p.y += sin(angle) * r;
    UIImage *image = [UIImage imageNamed:@"map_radar_aircraft"];
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, p.x, p.y);
    t = CGAffineTransformRotate(t, self.aircraftRotateAngle);
    t = CGAffineTransformTranslate(t, - p.x, -p.y);
    CGContextConcatCTM(UIGraphicsGetCurrentContext(), t);
    [self drawImage:image AtCenter:p];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    
}

#pragma mark - private draw image

- (void)drawImage:(UIImage *)image AtCenter:(CGPoint)center {
    if (image == nil) {
        return;
    }
    CGSize size = image.size;
    CGRect rect = CGRectZero;
    CGPoint origin = center;
    origin.x -= size.width / 2.f;
    origin.y -= size.height / 2.f;
    rect.size = size;
    rect.origin = origin;
    [image drawInRect:rect];
}
@end
