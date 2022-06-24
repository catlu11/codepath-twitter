//
//  User.m
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary; {
    self = [super init];

    if (self) {
        self.idStr = dictionary[@"id_str"];
        self.name = dictionary[@"name"];
        self.screenName = [@"@" stringByAppendingString:dictionary[@"screen_name"]];
        self.profilePicture = [dictionary[@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        self.headerPicture = dictionary[@"profile_banner_url"];
        self.bioText = dictionary[@"description"];
        self.followersCount = dictionary[@"followers_count"];
        self.followingCount = dictionary[@"friends_count"];
        self.tweetCount = dictionary[@"statuses_count"];
    }
    return self;
}

@end
