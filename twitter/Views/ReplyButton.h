//
//  ReplyButton.h
//  twitter
//
//  Created by Catherine Lu on 6/23/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReplyButton : UIButton
@property (strong, nonatomic) Tweet *originalTweet;
@end

NS_ASSUME_NONNULL_END
