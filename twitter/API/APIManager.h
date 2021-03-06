//
//  APIManager.h
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"
#import "Tweet.h"
#import "User.h"

@interface APIManager : BDBOAuth1SessionManager

+ (instancetype)shared;
- (void)getHomeTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)getHomeTimelineAfterIdWithCompletion:(NSString *)maxIdStr completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)getRepliesToTweetWithCompletion:(Tweet *)tweet completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)getTweetById:(NSString *)idStr completion:(void(^)(Tweet *tweet, NSError *error))completion;
- (void)getMentionsWithCompletion:(NSString *)userId completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)getMentionsTimelineAfterIdWithCompletion:(NSString *)maxIdStr completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion;
- (void)postReplyToTweet:(NSString *)text statusId:(NSString *)statusId completion:(void (^)(Tweet *, NSError *))completion;
- (void)favorite:(BOOL *)favorited tweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)retweet:(BOOL *)retweeted tweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)getCurrentUser: (void (^)(User *, NSError *))completion;
- (void)getUserInfo:(NSString *)screenName completion:(void(^)(User *user, NSError *error))completion;

@end
