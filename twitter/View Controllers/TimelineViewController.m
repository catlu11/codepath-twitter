//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetCell.h"
#import "ComposeViewController.h"

@interface TimelineViewController () <UITableViewDataSource, ComposeViewControllerDelegate, UITableViewDataSource>
    @property (strong, nonatomic) NSMutableArray *arrayOfTweets;
    @property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timelineTableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.timelineTableView insertSubview:self.refreshControl atIndex:0];
    [self fetchTimeline];
}

- (void)fetchTimeline {
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
//            for (Tweet *twt in tweets) {
//                NSString *text = twt.text;
//                NSLog(@"%@", text);
//            }
            self.arrayOfTweets = tweets;
            [self.timelineTableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

- (void)didTweet:(Tweet *)tweet {
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    [self.timelineTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    [[APIManager shared] logout];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = [segue destinationViewController];
    ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
    composeController.delegate = self;
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchTimeline];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    User *user = tweet.user;
    
    cell.userTagLabel.text = user.name;
    cell.screenNameLabel.text = user.screenName;
    cell.dateLabel.text = tweet.createdAtString;
    cell.tweetTextLabel.text = tweet.text;
    cell.retweetLabel.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    cell.likesLabel.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    cell.replyLabel.text = [NSString stringWithFormat:@"%d", tweet.replyCount];
    
    if (tweet.retweeted) {
        [cell.retweetButton setImage:[UIImage imageNamed: @"retweet-icon-green"] forState:UIControlStateNormal];
    }
    if (tweet.favorited) {
//        cell.likeButton.imageView.image = [UIImage imageNamed: @"favor-icon-red"];
        [cell.likeButton setImage:[UIImage imageNamed: @"favor-icon-red"] forState:UIControlStateNormal];
    }
    
    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    cell.profileImageView.image = [UIImage imageWithData:urlData];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.arrayOfTweets.count;
    return 20;
}

@end
