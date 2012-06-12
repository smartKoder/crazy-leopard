//
//  SMAudioListViewCellController.m

//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMAudioListViewCellController.h"

@implementation SMAudioListViewCellController


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [super setSelected:selected animated:animated];
   

    if (selected) {
        CGRect viewBounds= [[self contentView ]bounds];
        int x = viewBounds.size.width -40;
        int y = viewBounds.size.height - 40;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setImage:[UIImage imageNamed:@"playcell.png"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(x, y, 30, 30);
        btn.tag = 1234;
        [self.contentView addSubview:btn];
        
        NSLog(@"Showing the button");
        [btn addTarget:self action:@selector(playActionOnButton) forControlEvents:UIControlEventTouchUpInside];

    } else {
        NSLog(@"Hiding the button");
        NSArray *subviews = self.contentView.subviews;
        for (UIButton *button in subviews) {
            [button removeFromSuperview];
        }
    }
    // Configure the view for the selected state
}

- (void)playActionOnButton {
    UIView *dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    dimView.backgroundColor = [UIColor blackColor];
    dimView.alpha = 0.7f;
    dimView.userInteractionEnabled = NO;
    [[[self superview] superview] addSubview:dimView]; 
    SMRecordingListController *view123 = (SMRecordingListController*)[[self superview] superview];
    view123.viewRecording.hidden = NO;
    
    //[self audioView];
    
    
}
    

@end
