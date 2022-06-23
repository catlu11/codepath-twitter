//
//  ReplyViewController.m
//  twitter
//
//  Created by Catherine Lu on 6/23/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ReplyViewController.h"
#import "WebKit/WebKit.h"
#import "APIManager.h"
#import "User.h"

@interface ReplyViewController ()
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *tweetProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *tweetTagName;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *replyingToLabel;
@property (weak, nonatomic) IBOutlet WKWebView *mediaWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@end

@implementation ReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self.replyTextView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.replyTextView layer] setBorderWidth:0.5];
    [[self.replyTextView layer] setCornerRadius: self.replyTextView.frame.size.width*0.05];
    
    [self refreshData];
}

- (void)refreshData {
    // Set username and screen name labels
    self.tweetTagName.text = self.tweet.user.screenName;
    self.userName.text = self.tweet.user.name;
    
    // Set tweet content label
    self.tweetTextView.text = self.tweet.text;
    
    // Set replying to label
    self.replyingToLabel.text = [@"Replying to " stringByAppendingString:self.tweet.user.screenName];

    // Set media web view
    self.mediaWebView.scrollView.scrollEnabled = NO;
    if(self.tweet.imageUrlArray.count > 0) {
        self.webViewHeightConstraint.constant = 200;
        NSString *urlString = [self.tweet.imageUrlArray objectAtIndex:0];
        NSURLRequest *mediaRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:10.0];
        [self.mediaWebView loadRequest:mediaRequest];
    }
    else if(self.tweet.videoUrlArray.count > 0) {
        self.webViewHeightConstraint.constant = 200;
        NSString *urlString = [self.tweet.videoUrlArray objectAtIndex:0];
        NSURLRequest *mediaRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:10.0];
        [self.mediaWebView loadRequest:mediaRequest];
    }
    else {
        self.webViewHeightConstraint.constant = 0;
    }
    
    // Set tweet user image
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    self.tweetProfileImage.image = [UIImage imageWithData:urlData];
    self.tweetProfileImage.layer.cornerRadius = self.tweetProfileImage.frame.size.width / 3;
    
    // Set own user image
    [[APIManager shared] getCurrentUser:^(User *user, NSError *error) {
         if(error) {
              NSLog(@"Error fetching user information: %@", error.localizedDescription);
         }
         else{
             NSLog(@"Successfully fetched user info: %@", user.name);
             NSString *URLString = user.profilePicture;
             NSURL *url = [NSURL URLWithString:URLString];
             NSData *urlData = [NSData dataWithContentsOfURL:url];
             self.userProfileImage.image = [UIImage imageWithData:urlData];
             self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 3;
         }
     }];
}
- (IBAction)closeBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)replyButton:(id)sender {
    NSString *mention = [@"@" stringByAppendingString:self.tweet.user.screenName];
    NSString *replyText = [[mention stringByAppendingString:@" "] stringByAppendingString:self.replyTextView.text];
    NSLog(replyText);
    [[APIManager shared] postReplyToTweet:replyText statusId:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error replying to Tweet: %@", error.localizedDescription);
        }
        else{
            NSLog(@"Reply Tweet Success!");
            [self.delegate didReply:self.tweet.idStr];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
