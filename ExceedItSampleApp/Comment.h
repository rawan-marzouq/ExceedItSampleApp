//
//  Comment.h
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/10/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject
@property(strong,nonatomic) NSString *commentId;
@property(strong,nonatomic) NSString *commentsTitle;
@property(strong,nonatomic) NSString *commentsBody;
@property(strong,nonatomic) NSString *commenterEmail;
@end
