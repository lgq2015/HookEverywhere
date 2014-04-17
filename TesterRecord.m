//
//  TesterRecord.m
//  HookEveryWhere
//
//  Created by Nickboy on 3/5/14.
//
//

#import "TesterRecord.h"

@implementation TesterRecord

-(id)initWithUsername:(NSString *)username andScore:(float)score{
    self = [super init];
    
    if(self ) {
        _username = username;
        _score = score;
        _count = 0;
    }
    return self;
}
-(TesterRecord *)updateScore:(float)latestScore andUsername:(NSString *)username{
    [self setUsername:username];
    NSString *latestScoreString = [[NSString alloc]initWithFormat:@"%f",latestScore];
    NSError *error;
    NSMutableArray *result = [[NSMutableArray alloc]init];
    NSString *workingPath = [NSString stringWithFormat:@"/User/Documents/DataCollection/tester/%@",username];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:workingPath]) {
//        NSLog(@"enter updateScore function Username:%@, latestScore is %f",username,latestScore);
        [result addObject:latestScoreString];
        NSString *csv = [result componentsJoinedByString:@","];
        
        if([[NSFileManager defaultManager]
            fileExistsAtPath:workingPath isDirectory:&isDir] && isDir){
            return self;
        }
        
        BOOL written = [csv writeToFile:workingPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!written)
            NSLog(@"write failed, error=%@", error);
        [self setScore:1000000.0];
        [self setCount:1];
        return self;
    }else{
        NSString *csv = [NSString stringWithContentsOfFile:workingPath encoding:NSUTF8StringEncoding error:&error];
        result = [NSMutableArray arrayWithArray:[csv componentsSeparatedByString:@","]];
//        NSLog(@"class of entity of result : %@",[result[0] class]);
        int count =[result count];
//        NSLog(@"count is %d",count);
        if(count<7){
            NSString *latestScoreString = [[NSString alloc]initWithFormat:@"%f",latestScore];
            [result addObject:latestScoreString];
            NSString *csv = [result componentsJoinedByString:@","];
            
            if([[NSFileManager defaultManager]
                fileExistsAtPath:workingPath isDirectory:&isDir] && isDir){
                return self;
            }
            BOOL written = [csv writeToFile:workingPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (!written)
                NSLog(@"write failed, error=%@", error);
            
            [self setScore:1000000.0];
            [self setCount:count];
            return self;
        }else {
            [result removeObjectAtIndex:0];
            [result addObject:[NSNumber numberWithFloat:latestScore]];
            NSString *csv = [result componentsJoinedByString:@","];
            
            if([[NSFileManager defaultManager]
                fileExistsAtPath:workingPath isDirectory:&isDir] && isDir){
                return self;
            }
            
            BOOL written = [csv writeToFile:workingPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (!written)
                NSLog(@"write failed, error=%@", error);
            float finalScore = [self getTotalScore:result];
            [self setScore:finalScore];
            [self setCount:[result count]];
            return self;
        }
    }
    
}

-(void)normalization:(float)base{
    
    if (base == 0.0) {
        return;
    }
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *workingPath = [NSString stringWithFormat:@"/User/Documents/DataCollection/tester/"];
    NSString *csv;
    NSArray *userList = [fileManager contentsOfDirectoryAtPath:workingPath error:NULL];
    
    if (userList) {
        NSString *userDir;
        NSMutableArray *result;
        
        float lastRecord;
        for(NSString *user in userList){
//            NSLog(@"username : %@, base: %f",user,base);
            userDir = [NSString stringWithFormat:@"%@%@",workingPath,user];
            csv = [NSString stringWithContentsOfFile:userDir encoding:NSUTF8StringEncoding error:&error];
            result = [NSMutableArray arrayWithArray:[csv componentsSeparatedByString:@","]];
            if(result){
                lastRecord = [[result lastObject]floatValue];
//                NSLog(@"Before: %f",lastRecord);
                lastRecord = lastRecord/base;
                NSString *lastRecordString =[NSString stringWithFormat:@"%f",lastRecord];
//                NSLog(@"After : %f",lastRecord);
                [result removeLastObject];
                [result addObject:lastRecordString];
                csv = [result componentsJoinedByString:@","];
                BOOL written = [csv writeToFile:userDir atomically:YES encoding:NSUTF8StringEncoding error:&error];
                if (!written)
                    NSLog(@"write failed, error=%@", error);

            }
            
        }
    }
    
}

-(float)getTotalScore:(NSMutableArray *)scoreList{
    float result =0.0;
    for (NSString *value in scoreList){
        result = result + [value floatValue];
    }
//    NSLog(@"final score is %f",result);
    return result;
    
    
}

@end
