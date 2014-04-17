//
//  ComputedResult.m
//  HookEveryWhere
//
//  Created by Nickboy on 2/28/14.
//
//

#import "ComputedResult.h"

@implementation ComputedResult

-(id)initWithAngle:(float)angle length:(float)length majorWidth:(float)majorWidth{
    self = [super init];
    
    if (self) {
        _angle = angle;
        _length = length;
        _majorWidth = majorWidth;
    }
    return self;
}
- (void) print {
    NSLog(@"Computed result : %f,%f,%f\n",
          _angle,_length,_majorWidth);
}
-(NSString *)returnResultString{
    NSString *resultString = [[NSString alloc] initWithFormat:@"%f,%f,%f\n",_length,_angle,_majorWidth];
    return resultString;
}
@end
