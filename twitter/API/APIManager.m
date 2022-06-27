//
//  APIManager.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "APIManager.h"
#import "Tweet.h"
#import "User.h"

static NSString * const baseURLString = @"https://api.twitter.com";

@interface APIManager()

@end

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    NSURL *baseURL = [NSURL URLWithString:baseURLString];

    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"consumer_Key"];
    NSString *secret = [dict objectForKey: @"consumer_Secret"];
    
    // Check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"]) {
        secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"];
    }
    
    self = [super initWithBaseURL:baseURL consumerKey:key consumerSecret:secret];
    return self;
}

- (void)getTweetsWithCompletion:(NSString *)urlString parameters:(NSDictionary *)parameters completion:(void (^)(NSArray *tweets, NSError *))completion {
    [self GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
           NSMutableArray *tweets = [Tweet tweetsWithArray:tweetDictionaries];
           completion(tweets, nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           completion(nil, error);
    }];
}

- (void)postTweetRequestWithCompletion:(NSString *)urlString parameters:(NSDictionary *)parameters completion:(void (^)(Tweet *, NSError *))completion {
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)postReplyToTweet:(NSString *)text statusId:(NSString *)statusId completion:(void (^)(Tweet *, NSError *))completion {
    NSString *urlString = @"1.1/statuses/update.json";
    NSDictionary *parameters = @{@"status":text, @"in_reply_to_status_id":statusId};
    [self postTweetRequestWithCompletion:urlString parameters:parameters completion:completion];
}

- (void)getHomeTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSString *urlString = @"1.1/statuses/home_timeline.json";
    NSDictionary *parameters = @{@"tweet_mode":@"extended"};
    [self getTweetsWithCompletion:urlString parameters:parameters completion:completion];
}

- (void)getTweetById:(NSString *)idStr completion:(void(^)(Tweet *tweet, NSError *error))completion {
    [self GET:@"1.1/statuses/show.json" parameters:@{@"id":idStr} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDict) {
        Tweet *newTweet = [[Tweet alloc] initWithDictionary:tweetDict];
        completion(newTweet, nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           completion(nil, error);
    }];
}

- (void)getHomeTimelineAfterIdWithCompletion:(NSString *)maxIdStr completion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSString *urlString = @"1.1/statuses/home_timeline.json";
    NSDictionary *parameters = @{@"tweet_mode":@"extended", @"max_id":maxIdStr};
    [self getTweetsWithCompletion:urlString parameters:parameters completion:completion];
}

- (void)getRepliesToTweetWithCompletion:(Tweet *)tweet completion:(void(^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/search/tweets.json" parameters:@{@"q":tweet.user.screenName, @"since_id":tweet.idStr, @"count":@50} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionaries) {
        NSMutableArray *validTweetDicts = [[NSMutableArray alloc] init];
        
        for(NSDictionary *tweetDict in tweetDictionaries[@"statuses"]) {
            if([tweetDict[@"in_reply_to_status_id_str"] isEqual:[NSNull null]]) {
                continue;
            }
            if([tweetDict[@"in_reply_to_status_id_str"] isEqualToString:tweet.idStr]) {
                [validTweetDicts addObject:tweetDict];
            }
        }
        NSMutableArray *tweets = [Tweet tweetsWithArray:validTweetDicts];
           completion(tweets, nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           completion(nil, error);
    }];
}

- (void)getMentionsWithCompletion:(NSString *)userId completion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSString *urlString = @"1.1/statuses/mentions_timeline.json";
    NSDictionary *parameters = @{@"tweet_mode":@"extended"};
    [self getTweetsWithCompletion:urlString parameters:parameters completion:completion];
}

- (void)getMentionsTimelineAfterIdWithCompletion:(NSString *)maxIdStr completion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSString *urlString = @"1.1/statuses/mentions_timeline.json";
    NSDictionary *parameters = @{@"tweet_mode":@"extended", @"max_id":maxIdStr};
    [self getTweetsWithCompletion:urlString parameters:parameters completion:completion];
}

- (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion {
    NSString *urlString = @"1.1/statuses/update.json";
    NSDictionary *parameters = @{@"status": text};
    [self postTweetRequestWithCompletion:urlString parameters:parameters completion:completion];
}

- (void)favorite:(BOOL *)favorited tweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *urlString = favorited ? @"1.1/favorites/destroy.json" : @"1.1/favorites/create.json";
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self postTweetRequestWithCompletion:urlString parameters:parameters completion:completion];
}

- (void)retweet:(BOOL *)retweeted tweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *urlEnd = [tweet.idStr stringByAppendingString:@".json"];
    NSString *urlStart = retweeted ? @"1.1/statuses/unretweet/" : @"1.1/statuses/retweet/";
    NSString *urlString = [urlStart stringByAppendingString:urlEnd];
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self postTweetRequestWithCompletion:urlString parameters:parameters completion:completion];
}

- (void)getCurrentUser:(void (^)(User *, NSError *))completion {
    NSString *urlString = @"1.1/account/verify_credentials.json";
    [self GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable userDictionary) {
        User *user = [[User alloc]initWithDictionary:userDictionary];
        completion(user, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)getUserInfo:(NSString *)screenName completion:(void(^)(User *user, NSError *error))completion {
    [self GET:@"1.1/users/show.json" parameters:@{@"screen_name":screenName} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable userDictionary) {
        User *user = [[User alloc]initWithDictionary:userDictionary];
        completion(user, nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           completion(nil, error);
    }];
}

@end
