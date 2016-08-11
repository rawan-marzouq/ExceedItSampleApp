//
//  Address+CoreDataProperties.h
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/11/16.
//  Copyright © 2016 Rawan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Address.h"

NS_ASSUME_NONNULL_BEGIN

@interface Address (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *street;
@property (nullable, nonatomic, retain) NSString *suite;
@property (nullable, nonatomic, retain) NSString *zipcode;
@property (nullable, nonatomic, retain) NSSet<User *> *users;

@end

@interface Address (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet<User *> *)values;
- (void)removeUsers:(NSSet<User *> *)values;

@end

NS_ASSUME_NONNULL_END
