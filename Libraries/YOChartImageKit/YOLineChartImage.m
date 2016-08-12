#import "YOLineChartImage.h"

@implementation YOLineChartImage

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineStrokeWidth = 1.0;
        _lineStrokeColor = [UIColor whiteColor];
        _smooth = YES;
        
        _levelStrokeWidth = 1.0;
        _levelStrokeColor = [UIColor whiteColor];
    }
    return self;
}

- (NSNumber *) maxValue {
    return _maxValue ? _maxValue : [NSNumber numberWithFloat:[[_values valueForKeyPath:@"@max.floatValue"] floatValue]];
}
- (NSNumber *) minValue {
    return _minValue ? _minValue : [NSNumber numberWithFloat:[[_values valueForKeyPath:@"@min.floatValue"] floatValue]];
}

- (UIImage *)drawImage:(CGRect)frame scale:(CGFloat)scale {
    NSAssert(_values.count > 0, @"YOLineChartImage // must assign values property which is an array of NSNumber");
    
    NSUInteger valuesCount = _values.count;
    CGFloat pointX = frame.size.width / (valuesCount - 1);
    NSMutableArray<NSValue *> *points = [NSMutableArray array];
    CGFloat maxValue = self.maxValue.floatValue;

    [_values enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *_) {
        CGFloat ratioY = number.floatValue / maxValue;
        CGFloat offsetY = ratioY == 0.0 ? -_lineStrokeWidth / 2 : _lineStrokeWidth / 2;
        NSValue *pointValue = [NSValue valueWithCGPoint:(CGPoint){
            (float)idx * pointX,
            frame.size.height * (1 - ratioY) + offsetY
        }];
        [points addObject:pointValue];
    }];

    UIGraphicsBeginImageContextWithOptions(frame.size, false, scale);

    UIBezierPath *path = [self quadCurvedPathWithPoints:points frame:frame];
    path.lineWidth = _lineStrokeWidth;

    if (_lineStrokeColor) {
        [_lineStrokeColor setStroke];
        [path stroke];
    }
    
    if (_levels.count > 0) {
        [_levels enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *_) {
            
            CGFloat ratioY = value.floatValue / maxValue;
            CGFloat offsetY = ratioY == 0.0 ? -_levelStrokeWidth / 2 : _levelStrokeWidth / 2;
            NSNumber *level = [NSNumber numberWithFloat:frame.size.height * (1 - ratioY) + offsetY];
            
            UIBezierPath *horiz = [self linearHorizontalPathWithLevel:level frame:frame];
            horiz.lineWidth = _levelStrokeWidth;
            [_levelStrokeColor setStroke];
            [horiz stroke];
        }];
    
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Path generator

-(UIBezierPath *)linearHorizontalPathWithLevel:(NSNumber *)level frame:(CGRect)frame {
    UIBezierPath *line = [[UIBezierPath alloc] init];
    CGPoint startPoint = CGPointMake(0, level.floatValue);
    CGPoint endPoint = CGPointMake(frame.size.width, level.floatValue);
    [line moveToPoint:startPoint];
    [line addLineToPoint:endPoint];
    
    
    return line;
}

- (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points frame:(CGRect)frame {
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    UIBezierPath *fillBottom = [[UIBezierPath alloc] init];

    CGPoint startPoint = (CGPoint){0, frame.size.height};
    CGPoint endPoint = (CGPoint){frame.size.width, frame.size.height};
    [fillBottom moveToPoint:endPoint];
    [fillBottom addLineToPoint:startPoint];

    __block CGPoint p1 = [points[0] CGPointValue];
    [linePath moveToPoint:p1];

    [fillBottom addLineToPoint:p1];

    if (points.count == 2) {
        CGPoint p2 = [points[1] CGPointValue];
        [linePath addLineToPoint:p2];
        [fillBottom addLineToPoint:p2];
        if (_lineFillColor) {
            [_lineFillColor setFill];
            [fillBottom fill];
        }
        return linePath;
    }

    [points enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *_) {
        CGPoint p2 = value.CGPointValue;

        if (_smooth) {
            CGFloat deltaX = p2.x - p1.x;
            CGFloat controlPointX = p1.x + (deltaX / 2);
            CGPoint controlPoint1 = (CGPoint){controlPointX, p1.y};
            CGPoint controlPoint2 = (CGPoint){controlPointX, p2.y};

            [linePath addCurveToPoint:p2 controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            [fillBottom addCurveToPoint:p2 controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        } else {
            [linePath addLineToPoint:p2];
            [fillBottom addLineToPoint:p2];
        }

        p1 = p2;
    }];

    if (_lineFillColor) {
        [_lineFillColor setFill];
        [fillBottom fill];
    }

    return linePath;
}

@end
