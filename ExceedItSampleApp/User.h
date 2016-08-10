//
//  User.h
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/10/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property(strong,nonatomic) NSString *userId;
@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSString *phone;
@property(strong,nonatomic) NSString *email;
@property(strong,nonatomic) NSString *company;
@property(strong,nonatomic) NSString *street;
@property(strong,nonatomic) NSString *suite;
@property(strong,nonatomic) NSString *city;
@end
