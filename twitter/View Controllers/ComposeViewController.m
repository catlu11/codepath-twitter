//
//  ComposeViewController.m
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextView *composeTextView;
@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self.composeTextView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.composeTextView layer] setBorderWidth:0.5];
    [[self.composeTextView layer] setCornerRadius: self.composeTextView.frame.size.width*0.05];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
