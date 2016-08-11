//
//  User.h
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/11/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Company, Post;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
