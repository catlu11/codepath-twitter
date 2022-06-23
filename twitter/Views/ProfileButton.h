//
//  ProfileButton.h
//  twitter
//
//  Created by Catherine Lu on 6/23/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileButton : UIButton
@property(nonatomic, strong) User *user;
@end

NS_ASSUME_NONNULL_END
