//
//  candidateSelector.m
//  HookEveryWhere
//
//  Created by Nickboy on 3/4/14.
//
//

#import "CandidateSelector.h"
#import "ComputedResult.h"
#import "TesterRecord.h"
#include <test.h>
#include <vector>


@implementation CandidateSelector


-(id)init{
    self = [super init];
    return self;
}

-(NSMutableArray *) getCandidateList:(float)angleOfTester length:(float)lengthOfTester  direction:(NSMutableString *) directionOfTester context:(NSString *)contextOfTester andList:(NSMutableArray *)listOfTester{
    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    NSString *rootPath = @"/User/Documents/DataCollection/";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *userList = [fileManager contentsOfDirectoryAtPath:rootPath error:NULL];

    NSMutableArray *candidateList =[[NSMutableArray alloc]init];
    NSMutableDictionary *computedResultsList = [[NSMutableDictionary alloc]init];
    float base=0.0;
    
    //calculate the DTW score fore each trained user.
    for (NSString *username in userList){
        if (![username isEqualToString:@"tester"]){
            NSString *workingPath = [rootPath stringByAppendingFormat:@"%@/%@/%@/",username,contextOfTester,directionOfTester];
            NSArray *fileList = [fileManager contentsOfDirectoryAtPath:workingPath error:NULL];
            [computedResultsList setObject:username forKey:@"username"];
            
            int numberOfFiles = [fileList count];
            bool firsttime = 1;
            if (numberOfFiles >0){
                float min = 10000.0;
                TesterRecord *testerRecord =[[TesterRecord alloc]initWithUsername:username andScore:0.0];
                for (NSString *filename in fileList){
                    
                    float angle = [self getAngleFromFilename:filename];
                    float length = [self getLengthFromFilename:filename];

                    if ((0.65*length < lengthOfTester) && (1.35*length > lengthOfTester)&&(angle-30.0<angleOfTester)&&(angle+30.0>angleOfTester)){
                        [result addObject:filename];
    //                    NSLog(@"file matched : %@",filename);
                        NSMutableArray *dataArray = [self getDataArrayFromFile:[workingPath stringByAppendingString:filename]];
                        
    //                    NSLog(@"data array in main function :  a%@",dataArray);
                        float distance = [self calculateDTWDistance:listOfTester andTrainData:dataArray];
//                        NSLog(@"DTW distance is %f",distance);
                        if(distance > 1000.00){
//                            NSLog(@"large distance, username:%@",username);
                        }else{
                            if(firsttime){
                                min = distance;
                                firsttime=0;
                            }else{
                                if(distance <min){
                                    min = distance;
                                }
                            }
                        }
                        
                        
                    }
                    numberOfFiles -=1;
                }
                if(min != 10000.0){
                    base += min;
                }
                if(min<10000){
                    [candidateList addObject:[testerRecord updateScore:min andUsername:username]];
                }
            }
        }
    }
    //normalization
    if ([candidateList count]>0){
        [(TesterRecord *)candidateList[0] normalization:base];
    }
    
    
//    NSLog(@"directionary LIST is DTW : %@",candidateList);
    [self electCandidate:candidateList];
//    [self writeDictionaryToJSONFile:computedResultsList];
    return result;
}

-(void) electCandidate:(NSMutableArray *)candidateList{
    if (candidateList) {
        NSString *username = [candidateList[0] username];
        float score = [candidateList[0] score];
        
        //select the most like user.
        for (TesterRecord * candidate in candidateList) {
//            NSLog(@"DTW candiate name :%@, score:%f, count:%d",[candidate username],[candidate score],[candidate count]);
            if ([candidate count]<7){
                NSLog(@"count is small than 7");
            }else{
                if (score > [candidate score]){
                    username = [candidate username];
                    score = [candidate score];
                }
            }
        }
        
        if ([candidateList[0] count] ==7){
            NSString *message = [NSString stringWithFormat:@"You are more like %@, score is %f",username,score];
            NSError *error;
            NSLog(@"%@",message);
            
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Documents/applock.plist"];
            if ([username isEqualToString:@"Pranav"]){
                [dic setValue:@"0" forKey:@"edu.uh.cs.i2c.ios.locker.LockerSetting"];
                NSLog(@"You are the ownder. Disable applock");
            }else {
                [dic setValue:@"1" forKey:@"edu.uh.cs.i2c.ios.locker.LockerSetting"];
                
                NSLog(@"You are the guest. Enable applock");
                
                NSString *resultDirectory = @"/User/Documents/DataCollection/tester/";
                NSFileManager *fm = [NSFileManager defaultManager];
                NSError *error = nil;
                for (NSString *file in [fm contentsOfDirectoryAtPath:resultDirectory error:&error]) {
                    BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", resultDirectory, file] error:&error];
                    if (!success || error) {
                        NSLog(@"Delete result failed");
                    }
                }
            }
            
            BOOL result =[dic writeToFile:@"/User/Documents/applock.plist" atomically:NO];
            if(result){
                NSLog(@"write to applock.plist successful");
            }else{
                NSLog(@"write to applock.plist failed");

            }

        }
        
    }
}


-(float) getAngleFromFilename:(NSString *)filename{
    NSArray *array = [filename componentsSeparatedByString:@"_"];
//    NSLog(@"angle for %@ is %f",filename,[array[1] floatValue]);
    return [array[1] floatValue];
}

-(float) getLengthFromFilename:(NSString *)filename{
    NSArray *array = [filename componentsSeparatedByString:@"_"];
//    NSLog(@"length for %@ is %f",filename,[array[0] floatValue]);
    return [array[0] floatValue];
}

-(NSMutableArray *) getDataArrayFromFile:(NSString *)filename{
    NSString *dataStr = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *result = [[NSMutableArray alloc]init];
    NSArray* rows = [dataStr componentsSeparatedByString:@"\n"];
//    NSLog(@"rows : %@",rows);
    for(NSString *row in rows){
        if(![row isEqual:@""]){
            NSArray *rowList = [row componentsSeparatedByString:@","];
            ComputedResult *trainDataResult = [[ComputedResult alloc]initWithAngle:[[rowList objectAtIndex:1] floatValue] length:[[rowList objectAtIndex:0]floatValue] majorWidth:[[rowList objectAtIndex:2]floatValue]];
//            [trainDataResult print];
            [result addObject:trainDataResult];
        }
        
    }
//    NSLog(@"DTW result in getDataArray From File%@",result);
    
    return result;
}


-(double) calculateDTWDistance:(NSMutableArray *)testData andTrainData:(NSMutableArray *)trainData{
//    NSLog(@"Vector DTW Test start");
//    NSLog(@"DTW traindata result in computedDTWDistance : %@",trainData);
    vector<Node> mainVec;
    vector<Node> testVec;
    for ( ComputedResult *testDataResult in testData){
//        NSLog(@"DTW testDataResult :%@",[testDataResult returnResultString]);
        Node node([testDataResult length],[testDataResult angle],[testDataResult majorWidth]);
        testVec.push_back(node);
    }
    for (ComputedResult *trainDataResult in trainData){
//        NSLog(@"DTW trainDataResult :%@",[trainDataResult returnResultString]);
        Node node([trainDataResult length],[trainDataResult angle],[trainDataResult majorWidth]);
        mainVec.push_back(node);
    }
//    NSLog(@"testVec size DTW :%i",(int)testVec.size());
//    NSLog(@"trainVec size DTW :%i",size);
//    NSLog(@"vector DTW assignment finished");
    VectorDTW dtw1(mainVec.size(), testVec.size(), testVec.size());
    double distance = dtw1.fastdynamic(mainVec, testVec);
    
    return distance;
    
}


@end