#line 1 "/Volumes/Macintosh HD/i2c/ios_src/TouchCollectionForX32/HookEveryWhere/HookEveryWhere.xm"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <TouchRecord.h>
#import <ComputedResult.h>
#import <candidateSelector.h>

#include <Math.h>
#include <stdio.h>
#include <test.h>

@interface TouchDataCollector : NSObject {
    NSMutableArray * _segments;
    NSMutableArray * _records;
    NSMutableArray * _results;
    NSString * _username;
}

@property (nonatomic, retain) NSMutableArray* segments;
@property (nonatomic, retain) NSMutableArray* records;
@property (nonatomic, retain) NSMutableArray* results;
@property (nonatomic, retain) NSString* username;

+ (id) sharedCollector;
- (void) clearSegments;
- (void) processSegment:(BOOL)mode;
- (bool) checkClick;
- (bool) computeDistance;
- (float) computeAngle:(TouchRecord *)firstRecord andSecondRecord:(TouchRecord *)secondRecord;
- (float) computeLength:(TouchRecord *)firstRecord andSecondRecord:(TouchRecord *)secondRecord;
- (NSString *) prepareFilename:(NSMutableArray *)segments andMode:(BOOL)mode;
- (NSMutableString *) computeDirection:(TouchRecord *)firstRecord andLastRecord:(TouchRecord *)lastRecord;
@end

@implementation TouchDataCollector


- (id)init {
    if (self = [super init]) {
        _segments = [[NSMutableArray alloc] init];
        _records = [[NSMutableArray alloc] init];
        _results = [[NSMutableArray alloc]init];
        _username = @"Nick";
    }
    return self;
}

+ (id)sharedCollector {
    static TouchDataCollector * sharedTouchCollector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTouchCollector = [[self alloc] init];
    });
    
    return sharedTouchCollector;
}

- (void) clearSegments {
    [_segments removeAllObjects];
}

- (void) processSegment:(BOOL)mode {
    
    if (!([[[_segments objectAtIndex:0] context] isEqual: @"com.apple.springboard"])){
        return;
    }
    int numberOfRecords = [_segments count];
    
    if ([_segments count] == 0) {
        
        return;
    }
    
    enum GuestureType type;
    int n = [[_segments objectAtIndex:0] multitouch];
    
    if (n == 1) {    
        
        if ([_segments count] <= 5 || [self checkClick]) {
            type = Click;
            return;
        }
        else
        {
            type = Swipe;
        }
    }
    else if(n == 2) {
        bool isLarger = [self computeDistance];
        

        if(isLarger)
            type = ZoomOut;
        else
            type = ZoomIn;

    }
    else {    
        type = Other;
        return;
    }
    
    
    NSMutableString *content = [[NSMutableString alloc]init];
    NSMutableString *resultContent = [[NSMutableString alloc]init];
    
    NSString *filenameWithPath = [self prepareFilename:_segments andMode:mode];
    
    if(n==1 && type==Swipe) {
        for (int i=0; i<numberOfRecords; i++) {
            [(TouchRecord *)[_segments objectAtIndex:i] setGuestureType:type];
            [_records addObject:[_segments objectAtIndex:i]];

            [content appendString:[(TouchRecord *)[_segments objectAtIndex:i] returnRecordString]];
            
            ComputedResult *computedResult = [[ComputedResult alloc]init];
            if (i==0){
                [computedResult setAngle:0.0];
                [computedResult setLength:0.0];
                [computedResult setMajorWidth:[(TouchRecord *)[_segments objectAtIndex:i] majorWidth]/5.0];

            }else{
                float angleResult = [self computeAngle:[_segments objectAtIndex:0] andSecondRecord:[_segments objectAtIndex:i-1]];
                float lengthResult = [self computeLength:[_segments objectAtIndex:0] andSecondRecord:[_segments objectAtIndex:i]];

                [computedResult setAngle:angleResult*0.8/30.0];
                [computedResult setLength:lengthResult/400.0];
                [computedResult setMajorWidth:[(TouchRecord *)[_segments objectAtIndex:i] majorWidth]/5.0];

                
                
            }
            
            [_results addObject:computedResult];
            [resultContent appendString:[computedResult returnResultString]];
        }
        
        
        
        if (mode==TRUE){
            
            TouchRecord *firstRecord = (TouchRecord *)[_segments objectAtIndex:0];
            TouchRecord *lastRecord = (TouchRecord *)[_segments objectAtIndex:numberOfRecords-1];
            
            
            float angle = [self computeAngle:firstRecord andSecondRecord:lastRecord];
            float length = [self computeLength:firstRecord andSecondRecord:lastRecord];
            NSString *context = [firstRecord context];
            NSMutableString *direction = [self computeDirection:firstRecord andLastRecord:lastRecord];
            
            CandidateSelector *selector = [[CandidateSelector alloc]init];
            

            [selector getCandidateList:angle length:length direction:direction context:context andList:_results];
        }
        
        [_results removeAllObjects];
        
        if (mode==FALSE) {
            if([filenameWithPath rangeOfString:@"tester"].location == NSNotFound){
                NSError *error = NULL;
                BOOL written = [resultContent writeToFile:filenameWithPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                if (!written)
                    NSLog(@"write failed, error=%@", error);
            }
            
        }
        
    }













    else {    
        return;
    }
}



- (bool) computeDistance {
    int firststart = 0;
    int secondstart = 0;
    int first = 0;
    int second = 0;
    bool foundfirststart = false;
    bool foundsecondstart = false;
    
    for (int i=0; i<[_segments count]; i++) {
        if((!foundfirststart) && [(TouchRecord *)[_segments objectAtIndex:i] trackingId] == 0) {
            firststart = i;
            foundfirststart = true;
        }
        if((!foundsecondstart) && [(TouchRecord *)[_segments objectAtIndex:i] trackingId] == 1) {
            secondstart = i;
            foundsecondstart = true;
        }
        if ([(TouchRecord *)[_segments objectAtIndex:i] trackingId] == 0) {
            first = i;
        }
        if ([(TouchRecord *)[_segments objectAtIndex:i] trackingId] == 1) {
            second = i;
        }
    }

    float x1 = [(TouchRecord *)[_segments objectAtIndex:firststart] x];
    float x2 = [(TouchRecord *)[_segments objectAtIndex:secondstart] x];
    float y1 = [(TouchRecord *)[_segments objectAtIndex:firststart] y];
    float y2 = [(TouchRecord *)[_segments objectAtIndex:secondstart] y];
    
    float x11 = [(TouchRecord *)[_segments objectAtIndex:first] x];
    float x22 = [(TouchRecord *)[_segments objectAtIndex:second] x];
    float y11 = [(TouchRecord *)[_segments objectAtIndex:first] y];
    float y22 = [(TouchRecord *)[_segments objectAtIndex:second] y];

    
    float beginDistance = sqrt(pow(x1-x2,2)+pow(y1-y2,2));
    float endDistance = sqrt(pow(x11-x22,2)+pow(y11-y22,2));
    
    NSLog(@"BD=%f, ED=%f", beginDistance, endDistance);
    
    if(beginDistance <= endDistance)
        return true;
    else
        return false;
}

-(float) computeAngle:(TouchRecord *)firstRecord andSecondRecord:(TouchRecord *)secondRecord{

    float result = 180 * atan((abs([secondRecord y]-[firstRecord y]))/(abs([secondRecord x]-[firstRecord x])))/3.141592653589793;
    if (isnan(result))
        return 0.0;
    return result;
}

-(float) computeLength:(TouchRecord *)firstRecord andSecondRecord:(TouchRecord *)secondRecord{
    
    float length = sqrt( pow([firstRecord x]+[secondRecord x],2)+ pow([firstRecord y]+[secondRecord y],2));

    return length;
}

-(NSMutableString *) computeDirection:(TouchRecord *)firstRecord andLastRecord:(TouchRecord *)lastRecord{
    NSMutableString *direction = [[NSMutableString alloc]initWithString:@""];
    if (([firstRecord x] >= [lastRecord x]) &&(-[firstRecord y] >= -[lastRecord y])){
        [direction appendString:@"downleft"];
    }
    if (([firstRecord x] < [lastRecord x]) &&(-[firstRecord y] >= -[lastRecord y])){
        [direction appendString:@"downright"];
    }
    if (([firstRecord x] >= [lastRecord x]) &&(-[firstRecord y] < -[lastRecord y])){
        [direction appendString:@"upleft"];
    }
    if (([firstRecord x] < [lastRecord x]) &&(-[firstRecord y] < -[lastRecord y])){
        [direction appendString:@"upright"];
    }
    
    return direction;
}



-(NSString *) prepareFilename:(NSMutableArray *)segments andMode:(BOOL) mode{
    

    BOOL isDir;
    
    int numberOfRecords = [segments count];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    
    TouchRecord *firstRecord = (TouchRecord *)[segments objectAtIndex:0];
    TouchRecord *lastRecord = (TouchRecord *)[segments objectAtIndex:numberOfRecords-1];
    float angle = [self computeAngle:firstRecord andSecondRecord:lastRecord];
    float length = [self computeLength:firstRecord andSecondRecord:lastRecord];

    NSMutableString *direction = [self computeDirection:firstRecord andLastRecord:lastRecord];
    
    NSString *applicationName = [firstRecord context];
    NSString *dirRoot;
    dirRoot = [NSString stringWithFormat:@"/User/Documents/DataCollection/%@/%@/%@",_username,applicationName,direction];

    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dirRoot isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:dirRoot withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", dirRoot);
    
    
    NSString *filename = [NSString stringWithFormat:@"%f_%f_%f.csv",length,angle,timeStamp];
    NSString *filenameWithPath = [dirRoot stringByAppendingPathComponent:filename];

    return filenameWithPath;

}


- (bool) checkClick {
    float x1 = [(TouchRecord *)[_segments objectAtIndex:0] x];
    float xn = [(TouchRecord *)[_segments objectAtIndex:([_segments count] - 1)] x];
    float y1 = [(TouchRecord *)[_segments objectAtIndex:0] y];
    float yn = [(TouchRecord *)[_segments objectAtIndex:([_segments count] - 1)] y];

    if (abs(x1-xn) >= 20 || abs(y1-yn) >= 20) { 
        return false;
    }
    
    for(int i=0;i<[_segments count]-1;i++)
    {
        x1 = [(TouchRecord *)[_segments objectAtIndex:i] x];
        xn = [(TouchRecord *)[_segments objectAtIndex:i+1] x];
        y1 = [(TouchRecord *)[_segments objectAtIndex:i] y];
        yn = [(TouchRecord *)[_segments objectAtIndex:i+1] y];
        if (abs(x1-xn) >= 10 || abs(y1-yn) >= 10) { 
            return false;
        }

    }
                
    return true;
}

- (void)dealloc {
    [super dealloc];
}


@end

#include <logos/logos.h>
#include <substrate.h>
@class UIApplication; 
static void (*_logos_orig$_ungrouped$UIApplication$sendEvent$)(UIApplication*, SEL, UIEvent*); static void _logos_method$_ungrouped$UIApplication$sendEvent$(UIApplication*, SEL, UIEvent*); 

#line 338 "/Volumes/Macintosh HD/i2c/ios_src/TouchCollectionForX32/HookEveryWhere/HookEveryWhere.xm"


static void _logos_method$_ungrouped$UIApplication$sendEvent$(UIApplication* self, SEL _cmd, UIEvent* event) {
    

    if(([event type] != UIEventTypeTouches)||!([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"])){
        _logos_orig$_ungrouped$UIApplication$sendEvent$(self, _cmd, event);
    }
    NSString *settingsPath = @"/User/Documents/touchSettings.plist";
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    
    
    
    
    
    NSString *mode = [settings valueForKey:@"mode"];
    NSString *username = [settings valueForKey:@"username"];
    int numOfData = [[settings valueForKey:@"username"]intValue];
    
    
    
    
    if ([mode isEqual:@"Testing"]){
        NSArray *touches = [[event allTouches] allObjects];
        long t = [[NSDate date] timeIntervalSince1970];
        int mt = [touches count];
        
        for(int i=0;i<[touches count];++i)
        {
            UITouch *touch = [touches objectAtIndex:i];
            CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
            CGFloat touchSize = [[touch valueForKey:@"pathMajorRadius"] floatValue];
            NSTimeInterval ts = [[touch valueForKey:@"timestamp"] doubleValue];
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            
            
            TouchRecord *record = [[TouchRecord alloc] initWithTraceID:t
                                                           trackingID:i
                                                           posX:pos.x
                                                           posY:pos.y
                                                           majorWidth:touchSize
                                                           timestamp:ts
                                                           guestureType:Click
                                                           context:bundleIdentifier
                                                            multitouch: mt];
            
    
    
            TouchDataCollector * collector = [TouchDataCollector sharedCollector];
            if([touch phase] == UITouchPhaseBegan) {

                [collector clearSegments];
            }
            
            [[collector segments] addObject:record];
            
            if([touch phase] == UITouchPhaseEnded) {
                [collector processSegment:TRUE];

            }
        }
    }
    
    
    if ([mode isEqual:@"Training"]){




        
        

        NSArray *touches = [[event allTouches] allObjects];
        long t = [[NSDate date] timeIntervalSince1970];
        int mt = [touches count];
        
        for(int i=0;i<[touches count];++i)
        {
            UITouch *touch = [touches objectAtIndex:i];
            CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
            CGFloat touchSize = [[touch valueForKey:@"pathMajorRadius"] floatValue];
            NSTimeInterval ts = [[touch valueForKey:@"timestamp"] doubleValue];
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            
            
            TouchRecord *record = [[TouchRecord alloc] initWithTraceID:t
                                                            trackingID:i
                                                                  posX:pos.x
                                                                  posY:pos.y
                                                            majorWidth:touchSize
                                                             timestamp:ts
                                                          guestureType:Click
                                                               context:bundleIdentifier
                                                            multitouch: mt];
            
            TouchDataCollector * collector = [TouchDataCollector sharedCollector];
            [collector setUsername:username];
            if([touch phase] == UITouchPhaseBegan) {
                NSLog(@"Touch begins!");
                [collector clearSegments];
            }
            
            [[collector segments] addObject:record];
            
            if([touch phase] == UITouchPhaseEnded) {
                [collector processSegment:FALSE];
                NSLog(@"Touch ended!");
            }
        }
        
        
    }
    
    _logos_orig$_ungrouped$UIApplication$sendEvent$(self, _cmd, event);
}



static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$UIApplication = objc_getClass("UIApplication"); MSHookMessageEx(_logos_class$_ungrouped$UIApplication, @selector(sendEvent:), (IMP)&_logos_method$_ungrouped$UIApplication$sendEvent$, (IMP*)&_logos_orig$_ungrouped$UIApplication$sendEvent$);} }
#line 456 "/Volumes/Macintosh HD/i2c/ios_src/TouchCollectionForX32/HookEveryWhere/HookEveryWhere.xm"
