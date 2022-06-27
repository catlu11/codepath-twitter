//
//  TweetCell.h
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetDisplay.h""
#import "Tweet.h"
#import <WebKit/WebKit.h>
#import "ReplyButton.h"
#import "ProfileButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet ReplyButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UITextView *tweetViewText;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) Tweet *tweet;
@property (weak, nonatomic) IBOutlet WKWebView *mediaWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet ProfileButton *profileButton;
- (void)refreshData;
@end

NS_ASSUME_NONNULL_END
