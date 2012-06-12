//
//  SMRecordingListController.h
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface SMRecordingListController : UIViewController 
    <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>
{
    NSMutableArray *recordingListArray;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *editButton;
    BOOL isEditing;
    IBOutlet UILabel *labelEdit;
    IBOutlet UIView *viewRecording;
    IBOutlet UISlider *playSlider;
    AVAudioPlayer *audioPlayer;
    NSTimer *sliderTimer;
    IBOutlet UILabel *currentPlayTime;
    IBOutlet UILabel *remainingPlayTime;

    
}
@property (nonatomic, retain)  IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *editButton;
@property (nonatomic, retain) IBOutlet UILabel *labelEdit;
@property (nonatomic, retain) IBOutlet UIView *viewRecording;
@property (nonatomic, retain) IBOutlet UISlider *playSlider;
@property (nonatomic, retain) IBOutlet UILabel *currentPlayTime;
@property (nonatomic, retain) IBOutlet UILabel *remainingPlayTime;



- (IBAction)editRecordings:(id)sender;
- (void)deleteRecordingFromPath:(NSString*) fileName;

@end
