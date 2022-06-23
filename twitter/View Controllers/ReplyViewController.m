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
#import "ProfileButton.h"
#import "ProfileViewController.h"

@interface ReplyViewController ()
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) User *ownUser;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *tweetTagName;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *replyingToLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;
@property (weak, nonatomic) IBOutlet WKWebView *mediaWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstraint;
@property (weak, nonatomic) IBOutlet ProfileButton *ownUserButton;
@property (weak, nonatomic) IBOutlet ProfileButton *tweetUserButton;
@end

@implementation ReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self.replyTextView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.replyTextView layer] setBorderWidth:0.5];
    [[self.replyTextView layer] setCornerRadius: self.replyTextView.frame.size.width*0.05];
    
    // Get own user info
    [[APIManager shared] getCurrentUser:^(User *user, NSError *error) {
         if(error) {
              NSLog(@"Error fetching user information: %@", error.localizedDescription);
         }
         else{
             NSLog(@"Successfully fetched user info: %@", user.name);
             self.ownUser = user;
             [self refreshData];
         }
     }];
}

- (IBAction)didTapTweetUser:(id)sender {
    ProfileViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    viewController.user = self.tweet.user;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)didTapOwnUser:(id)sender {
    ProfileViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    viewController.user = self.ownUser;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)refreshData {
    // Set tweet user image
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    [self.tweetUserButton setBackgroundImage: [UIImage imageWithData:urlData] forState:UIControlStateNormal];
    self.tweetUserButton.layer.cornerRadius = self.tweetUserButton.frame.size.width / 3;
    self.tweetUserButton.clipsToBounds = YES;
    
    // Set own user image
    NSString *userURLString = self.ownUser.profilePicture;
    NSURL *userUrl = [NSURL URLWithString:userURLString];
    NSData *userUrlData = [NSData dataWithContentsOfURL:userUrl];
    [self.ownUserButton setBackgroundImage: [UIImage imageWithData:userUrlData] forState:UIControlStateNormal];
    self.ownUserButton.layer.cornerRadius = self.ownUserButton.frame.size.width / 3;
    self.ownUserButton.clipsToBounds = YES;
    
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
        NSString *urlString = [self.tweet.imageUrlArray objectAtIndex:0];
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        self.mediaImageView.image = [UIImage imageWithData:urlData];
        
        double width = self.mediaImageView.frame.size.width;
        double ratio = width / self.mediaImageView.image.size.width;
        int frameHeight = (int) round(self.scrollView.frame.size.height * 0.35);
        int modifiedImgHeight = (int) round(self.mediaImageView.image.size.height * ratio);
        int minHeight = MIN(frameHeight, modifiedImgHeight);

        if(minHeight > 0) {
            self.mediaImageHeightConstraint.constant = minHeight;
        }
        else {
            self.mediaImageHeightConstraint.constant = frameHeight;
        }
        self.webViewHeightConstraint.constant = 0;
    }
    else if(self.tweet.videoUrlArray.count > 0) {
        self.webViewHeightConstraint.constant = 200;
        self.mediaImageHeightConstraint.constant = 0;
        NSString *urlString = [self.tweet.videoUrlArray objectAtIndex:0];
        NSURLRequest *mediaRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:10.0];
        [self.mediaWebView loadRequest:mediaRequest];
    }
    else {
        self.webViewHeightConstraint.constant = 0;
        self.mediaImageHeightConstraint.constant = 0;
    }
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
