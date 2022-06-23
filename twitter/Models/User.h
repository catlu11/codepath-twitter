//
//  User.h
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject
    @property (nonatomic, strong) NSString *name;
    @property (nonatomic, strong) NSString *screenName;
    @property (nonatomic, strong) NSString *profilePicture;
@property (nonatomic, strong) NSString *headerPicture;
@property (nonatomic, strong) NSString *bioText;
@property (nonatomic, strong) NSNumber *followingCount;
@property (nonatomic, strong) NSNumber *followersCount;
@property (nonatomic, strong) NSNumber *tweetCount;
    - (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
