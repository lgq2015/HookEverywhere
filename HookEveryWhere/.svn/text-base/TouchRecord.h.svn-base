//
//  TouchRecord.h
//  HookEveryWhere
//
//  Created by Zhimin Gao on 11/5/13.
//
//

#import <Foundation/Foundation.h>

enum GuestureType {
    Click   = 0,
    Swipe   = 1,
    ZoomIn  = 2,
    ZoomOut = 3,
    Other = 4
    };

@interface TouchRecord : NSObject {
    long _traceId;
    int _trackingId;
    float _x;
    float _y;
    float _majorWidth;
    NSTimeInterval _timestamp;
    enum GuestureType _guestureType;
    NSString * _context;
    int _multitouch;
}

@property long traceId;
@property int trackingId;
@property float x;
@property float y;
@property float majorWidth;
@property NSTimeInterval timestamp;
@property enum GuestureType guestureType;
@property (nonatomic, retain) NSString * context;
@property int multitouch;

- (id)initWithTraceID: (long) tid trackingID: (int) tkid posX: (float)x posY: (float)y
           majorWidth: (float) width timestamp: (NSTimeInterval) t guestureType: (enum GuestureType)type
              context: (NSString *) c multitouch: (int) mt;

- (void) print;
- (NSString *) returnRecordString;
@end
