//
//  ViewController.m
//  TouchSettings
//
//  Created by Nickboy on 3/6/14.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController 


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *workPath = @"/User/Documents/touchSettings.plist";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:workPath]){
        NSString *username = @"Nick";
        NSString *mode = @"Training";
        [_mode addTarget:self action:@selector(pickOne:) forControlEvents:UIControlEventValueChanged];
        _settings = [[NSMutableDictionary alloc]init];
        [_settings setValue:username forKey:@"username"];
        [_settings setValue:mode forKey:@"Training"];
        [_settings setValue:@"400" forKey:@"numberOfData"];
        [_settings writeToFile:workPath atomically:NO];
        
    }else {
        _settings = [NSMutableDictionary dictionaryWithContentsOfFile:workPath];
        [_username setText:[_settings valueForKey:@"username"]];
        [_numOfData setText:[_settings valueForKey:@"numberOfData"]];
        NSString *mode =[_settings valueForKey:@"mode"];
        if ([mode isEqualToString:@"Training"]) {
            [_mode setSelectedSegmentIndex:0];
        }else{
            [_mode setSelectedSegmentIndex:1];
        }
        
//        [_mode s]
    }
    _username.delegate = self;
    [_username resignFirstResponder];
    [_mode addTarget:self action:@selector(pickOne:) forControlEvents:UIControlEventValueChanged];
	// Do any additional setup after loading the view, typically from a nib.
    [_enableSwitch addTarget:self action:@selector(enableChange:) forControlEvents:UIControlEventValueChanged];
}

-(void) pickOne:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    _modeLabel.text = [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    [self.view endEditing:YES];
    
}

-(void)enableChange:(id)sender{
    UISwitch *enableSwitch = (UISwitch *)sender;
    [_mode setEnabled:[enableSwitch isOn]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {
    NSString *workPath = @"/User/Documents/touchSettings.plist";
    NSString *username = _username.text;
    NSString *numberOfData = _numOfData.text;
    NSString *mode;
    if ([_enableSwitch isOn]){
        mode = [_mode titleForSegmentAtIndex:[_mode selectedSegmentIndex]];
    }else {
        mode = @"Disable";
    }
    
    [_settings setValue:username forKey:@"username"];
    [_settings setValue:mode forKey:@"mode"];
    [_settings setValue:numberOfData forKey:@"numberOfData"];
    [_settings writeToFile:workPath atomically:YES];
    NSString *msg = [NSString stringWithFormat:@"Username is %@\n Mode is %@",username,mode];
    UIAlertView *message = [[UIAlertView alloc]initWithTitle:msg message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
