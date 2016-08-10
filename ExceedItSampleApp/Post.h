//
//  Post.h
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/10/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject
@property(strong,nonatomic) NSString *postId;
@property(strong,nonatomic) NSString *title;
@property(strong,nonatomic) NSString *body;
@end
