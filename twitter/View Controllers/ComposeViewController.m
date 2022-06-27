//
//  ComposeViewController.m
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"
#import "ProfileButton.h"
#import "User.h"
#import "ProfileViewController.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UITextView *composeTextView;
@property (weak, nonatomic) IBOutlet ProfileButton *profileButton;
@property (strong, nonatomic) User *user;
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
             self.user = user;
             NSString *URLString = user.profilePicture;
             NSURL *url = [NSURL URLWithString:URLString];
             NSData *urlData = [NSData dataWithContentsOfURL:url];
             [self.profileButton setBackgroundImage:[UIImage imageWithData:urlData] forState:UIControlStateNormal];
             self.profileButton.layer.cornerRadius = self.profileButton.frame.size.width / 3;
             self.profileButton.clipsToBounds = YES;
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

- (IBAction)didTapProfile:(id)sender {
    ProfileViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    viewController.user = self.user;
    NSLog(@"toggled back");
    [viewController makeBackVisible];
    [self presentViewController:viewController animated:YES completion:nil];
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
