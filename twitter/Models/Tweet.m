//
//  Tweet.m
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "Tweet.h"
#import "User.h"

@implementation Tweet

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        NSDictionary *originalTweet = dictionary[@"retweeted_status"];
        if (originalTweet != nil) {
            NSDictionary *userDictionary = dictionary[@"user"];
            self.retweetedByUser = [[User alloc] initWithDictionary:userDictionary];

            dictionary = originalTweet;
        }
        self.idStr = dictionary[@"id_str"];
        if([dictionary valueForKey:@"full_text"] != nil) {
            self.text = dictionary[@"full_text"]; // uses full text if Twitter API provided it
        } else {
            self.text = dictionary[@"text"]; // fallback to regular text that Twitter API provided
        }
        self.favoriteCount = [dictionary[@"favorite_count"] intValue];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweetCount = [dictionary[@"retweet_count"] intValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        self.replyCount = [dictionary[@"reply_count"] intValue];
        self.replied = [dictionary[@"replied"] boolValue];

        // initialize user
        NSDictionary *user = dictionary[@"user"];
        self.user = [[User alloc] initWithDictionary:user];

        // format createdAt date string
        NSString *createdAtOriginalString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        
        // convert String to Date
        NSDate *date = [formatter dateFromString:createdAtOriginalString];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        
        // convert Date to String
        self.date = date;
        self.createdAtString = [formatter stringFromDate:date];
        
        // obtain media URLs
        self.videoUrlArray = [[NSMutableArray alloc] init];
        self.imageUrlArray = [[NSMutableArray alloc] init];
        NSArray *mediaUrls = dictionary[@"entities"][@"media"];
        NSArray *videoUrls = dictionary[@"entities"][@"urls"];
        for (NSDictionary *url in videoUrls) {
            [self.videoUrlArray addObject:url[@"expanded_url"]];
        }
        for (NSDictionary *url in mediaUrls) {
            [self.imageUrlArray addObject:url[@"media_url_https"]];
        }
    }
    return self;
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries {
    NSMutableArray *tweets = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:dictionary];
        [tweets addObject:tweet];
    }
    return tweets;
}

@end
