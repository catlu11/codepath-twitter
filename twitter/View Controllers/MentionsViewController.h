//
//  MentionsViewController.h
//  twitter
//
//  Created by Catherine Lu on 6/24/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MentionsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mentionsTableView;
- (void)fetchTimeline;
@end

NS_ASSUME_NONNULL_END
