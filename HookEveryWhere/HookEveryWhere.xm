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
        //NSLog("Did not have any record.");
        return;
    }
    
    enum GuestureType type;
    int n = [[_segments objectAtIndex:0] multitouch];
    
    if (n == 1) {    //Single touch
        
        if ([_segments count] <= 5 || [self checkClick]) {
            type = Click;
            return;
        }
        else
        {
            type = Swipe;
        }
    }
    else if(n == 2) {//Double touch
        bool isLarger = [self computeDistance];
        //bool isLarger = true;

        if(isLarger)
            type = ZoomOut;
        else
            type = ZoomIn;

    }
    else {    //multitouch, remove return if willing to process more than 2 point
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
//            [(TouchRecord *)[_segments objectAtIndex:i] print];
            [content appendString:[(TouchRecord *)[_segments objectAtIndex:i] returnRecordString]];
            
            ComputedResult *computedResult = [[ComputedResult alloc]init];
            if (i==0){
                [computedResult setAngle:0.0];
                [computedResult setLength:0.0];
                [computedResult setMajorWidth:[(TouchRecord *)[_segments objectAtIndex:i] majorWidth]/5.0];
//                [computedResult print];
            }else{
                float angleResult = [self computeAngle:[_segments objectAtIndex:0] andSecondRecord:[_segments objectAtIndex:i-1]];
                float lengthResult = [self computeLength:[_segments objectAtIndex:0] andSecondRecord:[_segments objectAtIndex:i]];
//                NSLog(@"angle is %f",angleResult);
                [computedResult setAngle:angleResult*0.8/30.0];
                [computedResult setLength:lengthResult/400.0];
                [computedResult setMajorWidth:[(TouchRecord *)[_segments objectAtIndex:i] majorWidth]/5.0];
//                NSLog(@"Angle result : %f",angleResult);
                
                
            }
            
            [_results addObject:computedResult];
            [resultContent appendString:[computedResult returnResultString]];
        }
        
        
        //when it is testing mode
        if (mode==TRUE){
            //get the candidate list for tester
            TouchRecord *firstRecord = (TouchRecord *)[_segments objectAtIndex:0];
            TouchRecord *lastRecord = (TouchRecord *)[_segments objectAtIndex:numberOfRecords-1];
            
            
            float angle = [self computeAngle:firstRecord andSecondRecord:lastRecord];
            float length = [self computeLength:firstRecord andSecondRecord:lastRecord];
            NSString *context = [firstRecord context];
            NSMutableString *direction = [self computeDirection:firstRecord andLastRecord:lastRecord];
            
            CandidateSelector *selector = [[CandidateSelector alloc]init];
            
//            NSMutableArray *list = [selector getCandidateList:angle length:length  direction:direction context:context andList:_results];
            [selector getCandidateList:angle length:length direction:direction context:context andList:_results];
        }
        
        [_results removeAllObjects];
        //when it is training mode
        if (mode==FALSE) {
            if([filenameWithPath rangeOfString:@"tester"].location == NSNotFound){
                NSError *error = NULL;
                BOOL written = [resultContent writeToFile:filenameWithPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                if (!written)
                    NSLog(@"write failed, error=%@", error);
            }
            
        }
        
    }
//    else if(n==2) {
//        for (int i=0; i<2; i++) {
//            for(int j=0; j<[_segments count]; j++) {
//                TouchRecord * record = (TouchRecord *)[_segments objectAtIndex:j];
//                if ([record trackingId] == i) {
//                    [record setGuestureType:type];
//                    [_records addObject:record];
//                    [record print];
//                    [content appendString:[record returnRecordString]];
//                }
//            }
//        }
//    }
    else {    // Do nothing when n points
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
//    NSLog(@"Length of current touch is : %f",length);
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
    
//    NSLog (@"gesture type is : %@",gestureType);
    BOOL isDir;
    
    int numberOfRecords = [segments count];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    //get angle and length
    TouchRecord *firstRecord = (TouchRecord *)[segments objectAtIndex:0];
    TouchRecord *lastRecord = (TouchRecord *)[segments objectAtIndex:numberOfRecords-1];
    float angle = [self computeAngle:firstRecord andSecondRecord:lastRecord];
    float length = [self computeLength:firstRecord andSecondRecord:lastRecord];

    NSMutableString *direction = [self computeDirection:firstRecord andLastRecord:lastRecord];
    //get the application name.
    NSString *applicationName = [firstRecord context];
    NSString *dirRoot;
    dirRoot = [NSString stringWithFormat:@"/User/Documents/DataCollection/%@/%@/%@",_username,applicationName,direction];

    //create the folder if is not exist.
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dirRoot isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:dirRoot withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", dirRoot);
    
    //concatenate path and filename then send back to caller.
    NSString *filename = [NSString stringWithFormat:@"%f_%f_%f.csv",length,angle,timeStamp];
    NSString *filenameWithPath = [dirRoot stringByAppendingPathComponent:filename];
//    NSLog (@"Filename is : %@",filename);
    return filenameWithPath;

}


- (bool) checkClick {
    float x1 = [(TouchRecord *)[_segments objectAtIndex:0] x];
    float xn = [(TouchRecord *)[_segments objectAtIndex:([_segments count] - 1)] x];
    float y1 = [(TouchRecord *)[_segments objectAtIndex:0] y];
    float yn = [(TouchRecord *)[_segments objectAtIndex:([_segments count] - 1)] y];

    if (abs(x1-xn) >= 20 || abs(y1-yn) >= 20) { //Distance is large than 20
        return false;
    }
    
    for(int i=0;i<[_segments count]-1;i++)
    {
        x1 = [(TouchRecord *)[_segments objectAtIndex:i] x];
        xn = [(TouchRecord *)[_segments objectAtIndex:i+1] x];
        y1 = [(TouchRecord *)[_segments objectAtIndex:i] y];
        yn = [(TouchRecord *)[_segments objectAtIndex:i+1] y];
        if (abs(x1-xn) >= 10 || abs(y1-yn) >= 10) { //Distance is large than 10
            return false;
        }

    }
                
    return true;
}

- (void)dealloc {
    [super dealloc];
}


@end

%hook UIApplication
-(void) sendEvent:(UIEvent*)event
{
    
//    NSLog(@"UIEventType is %@",[event UIEventType.UIEventTypeTouches]);
    if(([event type] != UIEventTypeTouches)||!([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"])){
        %orig;
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
            //NSLog(@"%ld, %f: %d, %.3f, %.3f, %.2f, %@", t, timestamp, i, pos.x, pos.y, touchSize, bundleIdentifier);
            
            TouchRecord *record = [[TouchRecord alloc] initWithTraceID:t
                                                           trackingID:i
                                                           posX:pos.x
                                                           posY:pos.y
                                                           majorWidth:touchSize
                                                           timestamp:ts
                                                           guestureType:Click
                                                           context:bundleIdentifier
                                                            multitouch: mt];
            
    //        if([[record context]  isEqual: @"com.apple.springboard"])
    //            return;
            TouchDataCollector * collector = [TouchDataCollector sharedCollector];
            if([touch phase] == UITouchPhaseBegan) {
//                NSLog(@"Touch begins!");
                [collector clearSegments];
            }
            
            [[collector segments] addObject:record];
            
            if([touch phase] == UITouchPhaseEnded) {
                [collector processSegment:TRUE];
//                NSLog(@"Touch ended!");
            }
        }
    }
    
    
    if ([mode isEqual:@"Training"]){
//        NSString *folderPath =[NSString stringWithFormat:@"/User/Documents/DataCollection/%@",username];
//        NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
//        int numberOfFiles = [filesArray count];
//        NSLog(@"number of Files : %d",numberOfFiles);
        
        
//            NSLog(@"run into process segments number of Files : %d",numberOfFiles);
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
            //NSLog(@"%ld, %f: %d, %.3f, %.3f, %.2f, %@", t, timestamp, i, pos.x, pos.y, touchSize, bundleIdentifier);
            
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
    
    %orig;
}


%end
