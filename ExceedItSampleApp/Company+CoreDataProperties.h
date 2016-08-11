//
//  Company+CoreDataProperties.h
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/11/16.
//  Copyright © 2016 Rawan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Company.h"

NS_ASSUME_NONNULL_BEGIN

@interface Company (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *phrase;
@property (nullable, nonatomic, retain) NSString *bs;
@property (nullable, nonatomic, retain) NSSet<User *> *users;

@end

@interface Company (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet<User *> *)values;
- (void)removeUsers:(NSSet<User *> *)values;

@end

NS_ASSUME_NONNULL_END
