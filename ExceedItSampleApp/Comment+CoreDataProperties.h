//
//  Comment+CoreDataProperties.h
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/11/16.
//  Copyright © 2016 Rawan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *body;
@property (nullable, nonatomic, retain) Post *post;

@end

NS_ASSUME_NONNULL_END
