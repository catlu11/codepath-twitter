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
#import "DetailsViewController.h"

@interface TimelineViewController () <UITableViewDataSource, ComposeViewControllerDelegate, UITableViewDelegate>
    @property (strong, nonatomic) NSMutableArray *arrayOfTweets;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set table elements
    self.timelineTableView.dataSource = self;
    self.timelineTableView.delegate = self;
    
    // Set up refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.timelineTableView insertSubview:self.refreshControl atIndex:0];
    
    // Get initial timeline
    [self fetchTimeline];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fetchTimeline];
}

- (void)fetchTimeline {
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
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
    [self.timelineTableView reloadData]; // reload to show new tweet
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    [[APIManager shared] logout];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchTimeline];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = [segue destinationViewController];
    ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
    composeController.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *navigationController = self.navigationController;
    DetailsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    TweetCell *cell = [self tableView:self.timelineTableView cellForRowAtIndexPath:indexPath]; // obtain from table cell to transfer local UI updates
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

    // Set user image
    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    cell.profileImageView.image = [UIImage imageWithData:urlData];
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 3;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20; // home timeline should show up to 20 tweets
}

@end
