//
//  TweetCell.h
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface TweetCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
    @property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *userTagLabel;
    @property (weak, nonatomic) IBOutlet UILabel *dateLabel;
    @property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
    @property (weak, nonatomic) IBOutlet UILabel *replyLabel;
    @property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
    @property (weak, nonatomic) IBOutlet UILabel *likesLabel;
    @property (weak, nonatomic) IBOutlet UIButton *replyButton;
    @property (weak, nonatomic) IBOutlet UIButton *retweetButton;
    @property (weak, nonatomic) IBOutlet UIButton *likeButton;

    @property (strong, nonatomic) Tweet *tweet;

    - (void)refreshData;
@end

NS_ASSUME_NONNULL_END
