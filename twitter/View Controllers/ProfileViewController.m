//
//  ProfileViewController.m
//  twitter
//
//  Created by Catherine Lu on 6/23/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ProfileViewController.h"
#import "APIManager.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *tagName;
@property (weak, nonatomic) IBOutlet UITextView *bioText;
@property (weak, nonatomic) IBOutlet UILabel *tweetCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (assign, nonatomic) BOOL *isBackVisible;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.user == nil) {
        [[APIManager shared] getCurrentUser:^(User *user, NSError *error) {
             if(error) {
                  NSLog(@"Error fetching user information: %@", error.localizedDescription);
                 
             }
             else{
                 NSLog(@"Successfully fetched user info: %@", user.name);
                 self.user = user;
                 [self setUI];
             }
         }];
    }
    else {
        [self setUI];
    }
}

- (void) setUI {
    if(self.isBackVisible) {
        self.backButton.hidden = NO;
    }
    else {
        self.backButton.hidden = YES;
    }
        
    self.userName.text = self.user.name;
    self.tagName.text = self.user.screenName;
    self.bioText.text = self.user.bioText;
    self.followingCount.text = [NSString stringWithFormat:@"%@", self.user.followingCount];
    self.followersCount.text = [NSString stringWithFormat:@"%@", self.user.followersCount];
    self.tweetCount.text = [NSString stringWithFormat:@"%@", self.user.tweetCount];
    
    NSString *profileUrlString = self.user.profilePicture;
    NSURL *profileUrl = [NSURL URLWithString:profileUrlString];
    NSData *profileUrlData = [NSData dataWithContentsOfURL:profileUrl];
    self.profileImage.image = [UIImage imageWithData:profileUrlData];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width*0.5;
    
    NSString *headerUrlString = self.user.headerPicture;
    NSURL *headerUrl = [NSURL URLWithString:headerUrlString];
    NSData *headerUrlData = [NSData dataWithContentsOfURL:headerUrl];
    self.headerImage.image = [UIImage imageWithData:headerUrlData];
}

- (IBAction)backBtnAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)makeBackVisible {
    self.isBackVisible = YES;
}
@end
