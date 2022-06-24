//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "MentionsViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetCell.h"
#import "ComposeViewController.h"
#import "DetailsViewController.h"
#import "ReplyViewController.h"
#import "ProfileViewController.h"

@interface MentionsViewController () <UITableViewDataSource, ComposeViewControllerDelegate, ReplyViewControllerDelegate, UITableViewDelegate>
    @property (strong, nonatomic) NSMutableArray *arrayOfTweets;
    @property (strong, nonatomic) UIRefreshControl *refreshControl;
    @property (strong, nonatomic) NSString *userId;
@end

@implementation MentionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get own user info
    [[APIManager shared] getCurrentUser:^(User *user, NSError *error) {
         if(error) {
              NSLog(@"Error fetching user information: %@", error.localizedDescription);
         }
         else{
             NSLog(@"Successfully fetched user info: %@", user.name);
             self.userId = user.idStr;
             
             // Set table elements
             self.mentionsTableView.dataSource = self;
             self.mentionsTableView.delegate = self;
             
             // Set up refresh control
             self.refreshControl = [[UIRefreshControl alloc] init];
             [self.refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
             [self.mentionsTableView insertSubview:self.refreshControl atIndex:0];
             
             // Get initial timeline
             [self fetchTimeline];
         }
     }];
}

- (void)viewWillAppear:(BOOL)animated {
    for (int section = 0; section < [self.mentionsTableView numberOfSections]; section++) {
        for (int row = 0; row < [self.mentionsTableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
            TweetCell *cell = [self.mentionsTableView cellForRowAtIndexPath:path];
            [cell refreshData];
        }
    }
}

- (void)fetchTimeline {
    [[APIManager shared] getMentionsWithCompletion:self.userId completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded mentions timeline");
            self.arrayOfTweets = tweets;
            [self.mentionsTableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"😫😫😫 Error getting mentions timeline: %@", error.localizedDescription);
        }
    }];
}

- (void)fetchNewTimeline {
    Tweet *lastTweet = self.arrayOfTweets[self.arrayOfTweets.count - 1];
    [[APIManager shared] getMentionsTimelineAfterIdWithCompletion:lastTweet.idStr completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded more tweets");
            for(Tweet *tweet in tweets) {
                [self.arrayOfTweets addObject:tweet];
            }
            [self.mentionsTableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"😫😫😫 Error getting more tweets: %@", error.localizedDescription);
        }
    }];
}

- (void)didTweet:(Tweet *)tweet {
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    [self.mentionsTableView reloadData]; // reload to show new tweet
}

- (void)didReply:(Tweet *)tweet {
    for (int section = 0; section < [self.mentionsTableView numberOfSections]; section++) {
        for (int row = 0; row < [self.mentionsTableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
            TweetCell *cell = [self.mentionsTableView cellForRowAtIndexPath:path];
            if([cell.tweet.idStr isEqualToString:tweet.idStr]) {
                cell.tweet.replyCount += 1;
                cell.tweet.replied = YES;
                [cell refreshData];
                break;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchTimeline];
}

- (IBAction) beginReply:(id)sender {
    ReplyButton *buttonClicked = (ReplyButton *)sender;
    ReplyViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
    viewController.tweet = buttonClicked.originalTweet;
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction) viewProfile:(id)sender {
    ProfileButton *buttonClicked = (ProfileButton *)sender;
    ProfileViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    viewController.user = buttonClicked.user;
    [viewController makeBackVisible];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *navigationController = self.navigationController;
    DetailsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    TweetCell *cell = [self tableView:self.mentionsTableView cellForRowAtIndexPath:indexPath]; // obtain from table cell to transfer local UI updates
    viewController.tweet = cell.tweet;
    [viewController refreshData];
    [navigationController pushViewController: viewController animated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    // Get tweet and update cell UI
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    cell.tweet = tweet;
    [cell refreshData];
    
    // Enable reply button
    cell.replyButton.originalTweet = tweet;
    [cell.replyButton addTarget:self action:@selector(beginReply:) forControlEvents:UIControlEventTouchUpInside];
    
    // Enable profile clicking
    cell.profileButton.user = tweet.user;
    [cell.profileButton addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    // Remove selection style
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // If bottom, start infinite scrolling
    if(indexPath.row == self.arrayOfTweets.count - 1 && self.arrayOfTweets.count >= 20) {
        [self fetchNewTimeline];
        NSLog(@"%@", self.arrayOfTweets);
    }

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count; // home timeline should show up to 20 tweets
}

@end
