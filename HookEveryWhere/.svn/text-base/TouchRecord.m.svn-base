//
//  TouchRecord.m
//  HookEveryWhere
//
//  Created by Zhimin Gao on 11/5/13.
//
//

#import "TouchRecord.h"

@implementation TouchRecord

- (id)initWithTraceID: (long) tid trackingID: (int) tkid posX: (float)x posY: (float)y
           majorWidth: (float) width timestamp: (NSTimeInterval) t guestureType: (enum GuestureType)type
              context: (NSString *) c multitouch:(int)mt{
    self = [super init];
    
    if (self) {
        _traceId = tid;
        _trackingId = tkid;
        _x = x;
        _y = y;
        _majorWidth = width;
        _timestamp = t;
        _guestureType = type;
        _context = c;
        _multitouch = mt;
    }
    
    return self;
}

- (void) print {
    NSLog(@"%ld, %d, %.2f, %.2f, %.3f, %f, %d, %@, %d",
          _traceId, _trackingId, _x, _y, _majorWidth, _timestamp, _guestureType, _context, _multitouch);
}

- (NSString *)returnRecordString {
    NSString *recordString = [[NSString alloc]initWithFormat: @"%ld, %d, %.2f, %.2f, %.3f, %f, %d, %@, %d\n",
_traceId, _trackingId, _x, _y, _majorWidth, _timestamp, _guestureType, _context, _multitouch];
    return recordString;
}



@end
