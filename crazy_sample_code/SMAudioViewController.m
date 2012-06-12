//
//  SMAudioRecorder.m
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMAudioViewController.h"

@implementation SMAudioViewController

@synthesize recordButton, recordingMessage, timerMessage;

NSString * const StartRecordMessage = @"record";
NSString * const StopRecordMessage = @"stop";
NSString * const DateFormatTimer = @"HH:mm:ss";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    isPlaying = NO;
    [playButton setEnabled:NO];
    [saveButton setEnabled:NO];
    [deleteButton setEnabled:NO];
    recordingStartTime = [[NSDate alloc] init];
    
    /* NSString *soundFilePath = [docsDir stringByAppendingString:@"/sound.caf"];
     NSLog(@"Sound file path = %@", soundFilePath);*/
    
    NSString *tempDirectory = NSTemporaryDirectory();
    
    NSString *soundFilePath = [tempDirectory stringByAppendingString:@"sound.caf"];
    NSLog(@"Sound file path = %@", soundFilePath);
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setDelegate:self];
    [audioSession setActive:YES error:nil];
    [textRecordingName setDelegate:self];
    recording = NO;
    [recordingImage setImage:[UIImage imageNamed:@"0014_1.png"]];
    NSDictionary *recordSettings = [NSDictionary 
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], 
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2], 
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0], 
                                    AVSampleRateKey,
                                    nil];
    NSError *error = nil;
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        [audioRecorder prepareToRecord];
    }
    
}
- (void)recordAudio:(id)sender {
    NSLog(@"Recording audio");
    
    if (!recording) {
        if (!audioRecorder.recording) {
            NSArray * imageArray  = [[NSArray alloc] initWithObjects:
                                     [UIImage imageNamed:@"0014_1.png"],
                                     [UIImage imageNamed:@"0014_2.png"],
                                     [UIImage imageNamed:@"0014_3.png"],
                                     nil];
            [recordingImage setAnimationImages:imageArray];
            recordingImage.animationDuration = 1.1;
            [recordingImage startAnimating];
            
            NSDate *today = [[NSDate alloc] init];
            NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:DateFormatTimer]; 
            
            NSString *currentTime = [dateFormatter stringFromDate: today];
            [timerMessage setText:currentTime];
            [recordButton setImage: [UIImage imageNamed:@"record_stop.png"] forState:UIControlStateNormal];
            recording = YES;
            [recordingMessage setText:StopRecordMessage];
            [recordingMessage setTextColor:UIColor.redColor];
            [audioRecorder record];
            timer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(pollTimer:) userInfo:nil repeats:YES];
            //I need some app to work upon . Thu
        }
        
    } else {
        //Stop recording 
        recording = NO;
        [recordingImage stopAnimating];
        [recordingImage setImage:[UIImage imageNamed:@"0014_1.png"]];
        
        [audioRecorder stop];
        [recordButton setImage: [UIImage imageNamed:@"record_start.png"] forState:UIControlStateNormal];
        [recordingMessage setText:StartRecordMessage];
        [recordingMessage setTextColor: UIColor.greenColor];
        [timer invalidate];
        timer = nil;
        recordingStartTime = nil;
        recordingStartTime = [[NSDate alloc] init];
        [playButton setEnabled:YES];
        [saveButton setEnabled:YES];
        [deleteButton setEnabled:YES];
        
    }
}

//onFinished

- (void)stop:(id)sender{
    NSLog(@"Stop Playing");
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
        [recordButton setImage: [UIImage imageNamed:@"record_start.png"] forState:UIControlStateNormal];
        [recordingMessage setText:StartRecordMessage];
        [recordingMessage setTextColor: UIColor.greenColor];
        
    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
}

-(void)playAudio:(id)sender

{
    
    NSLog(@"Playing audio");
    if (!audioRecorder.recording && !isPlaying)
    {
        recordButton.enabled = NO;
        isPlaying = YES;
        NSError *error;
        [playButton setImage: [UIImage imageNamed:@"1337891292_player_record.png"] forState:UIControlStateNormal];
        
        audioPlayer = [[AVAudioPlayer alloc] 
                       initWithContentsOfURL:audioRecorder.url                                    
                       error:&error];
        
        audioPlayer.delegate = self;
        
        if (error)
            NSLog(@"Error: %@", 
                  [error localizedDescription]);
        else {
            recordingStartTime = [[NSDate alloc] init];
            timer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(pollTimer:) userInfo:nil repeats:YES];
            [audioPlayer play];
        }
    } else {
        [self audioPlayerDidFinishPlaying:audioPlayer successfully:YES];
    }
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    audioPlayer = nil;
    audioRecorder = nil;
    recordButton = nil;
}

- (void)pollTimer:(NSTimer *)theTimer {
    NSTimeInterval interval = [recordingStartTime timeIntervalSinceNow];
    interval = ABS(interval);
    NSLog(@"interval:%f",interval);
    int num_ms = trunc((interval* 1000));
    int ms = num_ms%1000;
    int num_seconds = trunc(interval);
    int remainder = num_seconds % 3600; 
    int forMinutes = remainder / 60; 
    int forSeconds = remainder % 60;   
    
    //  NSString *message = [NSString stringWithFormat:@"%02d:%02d:%03d",forMinutes,forSeconds,ms];
    NSString *message = [NSString stringWithFormat:@"%02d:%02d",forMinutes,forSeconds];
    
    [timerMessage setText:message];    
    
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Player finshed playing");
    recordButton.enabled = YES;
    [playButton setImage: [UIImage imageNamed:@"1337966940_youtube.png"] forState:UIControlStateNormal];
    [timer invalidate];
}

- (void)pollOnPlayingAtInterval:(NSTimer *)timer {
    NSString *timerString = [NSString stringWithFormat:@"%d",[audioPlayer currentTime]];
    [timerMessage setText:timerString];
}

- (void)saveRecording:(id)sender{
    NSString *text = textRecordingName.text;
    NSLog(@"Saving recording");
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *tempDirectory = NSTemporaryDirectory();
    NSString *oldFilePath = [tempDirectory stringByAppendingString:@"sound.caf"];
    
    if (text == nil || [text isEqualToString:@"" ]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a title for the recording" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        //After some time
        [alert dismissWithClickedButtonIndex:0 animated:TRUE];
        [alert show];
    } else {        
        
        //copy the file 
        
        NSArray *dirPaths;
        NSString *docsDir;
        
        dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        
        
        NSString *newFilePath = [docsDir stringByAppendingFormat:@"/%@.caf",text];
        [fileMgr moveItemAtPath:oldFilePath toPath:newFilePath error:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recording saved" message:newFilePath delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        //After some time
        [alert dismissWithClickedButtonIndex:0 animated:TRUE];
        [alert show];
        
    }           
}

- (void)displayRecentRecordingList {
    
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Resignin");
    [textField resignFirstResponder];
    return YES;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AudioViewRecordingListSegue" ]) {
        //to be implemented
    }
}
@end
