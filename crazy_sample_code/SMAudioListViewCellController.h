//
//  SMAudioListViewCellController.h

//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMRecordingListController.h"

@interface SMAudioListViewCellController : UITableViewCell
{
    BOOL isPlaying;
    
}

- (void)playActionOnButton;

@end
