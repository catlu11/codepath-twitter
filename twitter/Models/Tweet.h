//
//  Tweet.h
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tweet : NSObject
    @property (nonatomic, strong) NSString *idStr; // For favoriting, retweeting & replying
    @property (nonatomic, strong) NSString *text; // Text content of tweet
    @property (nonatomic) int favoriteCount; // Update favorite count label
    @property (nonatomic) BOOL favorited; // Configure favorite button
    @property (nonatomic) int retweetCount; // Update favorite count label
    @property (nonatomic) BOOL retweeted; // Configure retweet button
    @property (nonatomic) int replyCount; // Update favorite count label
    @property (nonatomic) BOOL replied; // Configure retweet button
    @property (nonatomic, strong) User *user; // Contains Tweet author's name, screenname, etc.
    @property (nonatomic, strong) NSString *createdAtString; // Display date string
    @property (nonatomic, strong) NSDate *date; // Display date
    @property (nonatomic, strong) User *retweetedByUser;
    @property (strong, nonatomic) NSMutableArray *entityUrlArray;

    - (instancetype)initWithDictionary:(NSDictionary *)dictionary;
    + (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries;
@end

NS_ASSUME_NONNULL_END
