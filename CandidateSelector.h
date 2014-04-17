//
//  candidateSelector.h
//  HookEveryWhere
//
//  Created by Nickboy on 3/4/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface CandidateSelector : NSObject

-(id)init;
-(NSMutableArray *) getCandidateList:(float)angle length:(float)length  direction:(NSMutableString *) direction context:(NSString *) cotext andList:(NSMutableArray *)list;
-(float) getAngleFromFilename:(NSString *)filename;
-(float) getLengthFromFilename:(NSString *)filename;
-(double) calculateDTWDistance:(NSMutableArray *)testData andTrainData:(NSArray *)trainData;
-(NSMutableArray *) getDataArrayFromFile:(NSString *)filename;
//-(void) writeDictionaryToJSONFile:(NSDictionary *)content;
//-(NSMutableDictionary *) readJsonFileToDictionary:(NSString *)path;
@end
