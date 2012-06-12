//
//  SMRecordingListController.m
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMRecordingListController.h"

@implementation SMRecordingListController
@synthesize tableView, editButton, viewRecording, playSlider, currentPlayTime, remainingPlayTime;

NSString * const DateFormatModDate = @"HH:mm, MMM-dd, YYYY";


- (void)viewDidLoad {
    [super viewDidLoad];
    isEditing = NO;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *dirPaths;
    NSString *docsDir;
    viewRecording.hidden = YES;
    recordingListArray = [[NSMutableArray alloc] init];
    dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSArray *recentRecordingsArray = [fileMgr contentsOfDirectoryAtPath:docsDir error:nil];
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DateFormatModDate];
    for (NSString *fileName in recentRecordingsArray) {
        if ([fileName hasSuffix:@".caf"]) {
            NSString *filePath = [docsDir stringByAppendingFormat:@"/%@",fileName];
            NSLog(@"DEBUG: SMRecordingListController - Filename -> %@, FilePath -> %@", fileName, filePath);
            NSMutableDictionary *fileInfoDictionary = [[NSMutableDictionary alloc] init];
            [fileInfoDictionary setValue:fileName forKey:@"fname"];
            NSDate *date = [[fileMgr attributesOfItemAtPath:filePath error:nil] valueForKey:NSFileModificationDate];
            NSString *modDateString = [[NSString alloc] init];
            modDateString = [dateFormatter stringFromDate:date];
            [fileInfoDictionary setValue:modDateString forKey:@"mod-date"];
            [recordingListArray addObject:fileInfoDictionary];
        }
    }
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    NSDictionary *dictionary =  [recordingListArray objectAtIndex:[indexPath row]];
    NSString *fileName = [dictionary valueForKey:@"fname"];
    NSString *fileDetails =[dictionary valueForKey:@"mod-date"];
    /**
     [NSString stringWithFormat:@"modified:%@,size:%@",[dictionary valueForKey:NSFileModificationDate] ,
     [dictionary valueForKey:NSFileSize]];**/
    NSLog(@"DEBUG: SMRecordingListController.tableView - Filename -> %@, FilePath -> %d", [dictionary valueForKey:@"fname"], [indexPath row]);
    [[cell textLabel] setText:fileName];
    [[cell detailTextLabel] setText:fileDetails];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recordingListArray count];
}

- (void)editRecordings:(id)sender {
    if (!isEditing) {
        [editButton setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
        [tableView setEditing:YES animated:YES];
        [labelEdit setText:@"DONE"];
        isEditing = YES;
    } else {
        [editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        [tableView setEditing:NO animated:YES];
        [labelEdit setText:@"EDIT"];
        isEditing = NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Deleting the file");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Deleting the file 256");
        
        NSDictionary *fileDictionary = [recordingListArray objectAtIndex:[indexPath row]];
        [self deleteRecordingFromPath:[fileDictionary valueForKey:@"fname"]];
        [recordingListArray removeObjectIdenticalTo:fileDictionary];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}


- (void)deleteRecordingFromPath:(NSString*) fileName{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *filePath = [docsDir stringByAppendingFormat:@"/%@",fileName];
    NSLog(@"DEBUG: SMRecordingListController.deleteRecordingFromPath , filePath= %@" , filePath);
    if ([fileMgr fileExistsAtPath:filePath ] && [fileMgr isDeletableFileAtPath:filePath]) {
        [fileMgr removeItemAtPath:filePath error:nil];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    CGRect viewBounds= [[cell contentView ]bounds];
    int x = viewBounds.size.width -40;
    int y = viewBounds.size.height - 40;
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setImage:[UIImage imageNamed:@"playcell.png"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(x, y, 30, 30);
    btn.tag = 1234;
    [cell.contentView addSubview:btn];
    
    NSLog(@"Showing the button tableView");
    NSDictionary *fileDictionary = [recordingListArray objectAtIndex:[indexPath row]];
    NSString *fileName = [fileDictionary valueForKey:@"fname"];
    [btn addTarget:self action:@selector(playActionOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Hiding the button");
    if (audioPlayer !=nil && [audioPlayer isPlaying]) {
        [audioPlayer stop];
    }
    NSArray *subviews = cell.contentView.subviews;
    for (UIButton *button in subviews) {
        [button removeFromSuperview];
    }
    
}

- (void)playActionOnButton:(id)sender{
    /*viewRecording.hidden = NO;
     UIView *dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
     dimView.backgroundColor = [UIColor blackColor];
     dimView.alpha = 0.7f;
     dimView.userInteractionEnabled = NO;
     [[tableView superview] addSubview:dimView]; */
    
    //[self audioView];
    UIButton *button = (UIButton*)sender;
    
    if (audioPlayer !=nil && [audioPlayer isPlaying]) {
        [audioPlayer pause];
        [button setImage:[UIImage imageNamed:@"playcell.png"] forState:UIControlStateNormal];
        
    } else if (audioPlayer !=nil && ![audioPlayer isPlaying]) {
        [button setImage:[UIImage imageNamed:@"player-pause.png"] forState:UIControlStateNormal];

        [audioPlayer setCurrentTime:playSlider.value];
        
        [audioPlayer prepareToPlay];
        
        [audioPlayer play];
        
        
    }else {
        [button setImage:[UIImage imageNamed:@"player-pause.png"] forState:UIControlStateNormal];
        NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
        
        NSDictionary *dictionary =  [recordingListArray objectAtIndex:[indexPath row]];
        NSString *fileName = [dictionary valueForKey:@"fname"];
        
        NSArray *dirPaths;
        NSString *docsDir;
        dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        NSString *soundFilePath = [docsDir stringByAppendingFormat:@"/%@",fileName];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        [playSlider setMinimumValue:0.0f];
        [playSlider setValue:0.0f animated:YES]
        ;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [playSlider setMaximumValue:[audioPlayer duration]];
        // Set a timer which keep getting the current music time and update the UISlider in 1 sec interval
        sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
        
        // Set the valueChanged target
        [playSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [audioPlayer play];
    }
    
    
    NSLog(@"audio player playing , %f, %@",  [audioPlayer duration], [audioPlayer url]);
    
    /*
     NSData *data = [NSData dataWithContentsOfFile:soundFilePath];
     audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
     [audioPlayer play];
     */
}

- (void)updateSlider {
    // Update the slider about the music time
    playSlider.value = audioPlayer.currentTime;
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setMaximumFractionDigits:1];
    [nf setRoundingMode: NSNumberFormatterRoundDown];
    NSString *numberString = [nf stringFromNumber:[NSNumber numberWithFloat:audioPlayer.currentTime]];
    [currentPlayTime setText:numberString];
    
    NSString *numberString1 = [nf stringFromNumber:[NSNumber numberWithFloat:audioPlayer.currentTime - audioPlayer.duration]];
    [remainingPlayTime setText:numberString1];

}

-(IBAction)sliderChanged:(UISlider *)sender {
    
    // Fast skip the music when user scroll the UISlider
    if( audioPlayer !=nil) {
        
        [audioPlayer stop];
        
        [audioPlayer setCurrentTime:playSlider.value];
        
        [audioPlayer prepareToPlay];
        
        [audioPlayer play];
        
    }
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    // Music completed
    
    if (flag) {
        [sliderTimer invalidate];
        playSlider.value =0.0f;
        audioPlayer = nil;
        
    }
    
}


@end
