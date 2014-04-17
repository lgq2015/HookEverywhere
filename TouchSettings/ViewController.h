//
//  ViewController.h
//  TouchSettings
//
//  Created by Nickboy on 3/6/14.
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>{
    NSMutableDictionary *_settings;
}
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property NSMutableDictionary *settings;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mode;
@property (weak, nonatomic) IBOutlet UITextField *numOfData;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
- (IBAction)submit:(id)sender;

@end
