//
//  ComposeViewController.m
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UITextView *composeTextView;
@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.composeTextView.delegate = self;
    [[self.composeTextView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.composeTextView layer] setBorderWidth:0.5];
    [[self.composeTextView layer] setCornerRadius: self.composeTextView.frame.size.width*0.05];
    NSString *text = self.composeTextView.text;
    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu", [text length]];
    
    [[APIManager shared] getCurrentUser:^(User *user, NSError *error) {
         if(error) {
              NSLog(@"Error fetching user information: %@", error.localizedDescription);
             
         }
         else{
             NSLog(@"Successfully fetched user info: %@", user.name);
             NSString *URLString = user.profilePicture;
             NSURL *url = [NSURL URLWithString:URLString];
             NSData *urlData = [NSData dataWithContentsOfURL:url];
             self.profileImage.image = [UIImage imageWithData:urlData];
             self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 3;
         }
     }];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = self.composeTextView.text;
    NSInteger *count = [text length];
    NSString *countString = [NSString stringWithFormat:@"%lu", count];
    self.characterCountLabel.text = countString;
    if(count > 280) {
        [self.warningLabel setHidden:NO];
        self.characterCountLabel.textColor = [UIColor redColor];
        self.tweetButton.enabled = NO;
    }
    else {
        [self.warningLabel setHidden:YES];
        self.characterCountLabel.textColor = [UIColor blackColor];
        self.tweetButton.enabled = YES;
    }
}

- (IBAction)closeBtnAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)tweetBtnAction:(id)sender {
    [[APIManager shared] postStatusWithText:self.composeTextView.text completion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error composing Tweet: %@", error.localizedDescription);
        }
        else{
            [self.delegate didTweet:tweet];
            NSLog(@"Compose Tweet Success!");
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

@end
