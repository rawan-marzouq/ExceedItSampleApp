//
//  ViewController.m
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/10/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "ViewController.h"
#import "UserTableViewCell.h"
#import "User.h"
#import "UserPostsViewController.h"
#import "Company.h"
#import "Address.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *usersArray;
}
@property (weak, nonatomic) IBOutlet UITableView *usersTable;

@end


@implementation ViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [self GetUsersList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Users API
-(void)GetUsersList{
    
    // Initialies users array
    usersArray = [[NSMutableArray alloc]init];
    
    // REST CALL
    NSURL *url = [NSURL URLWithString:@"http://jsonplaceholder.typicode.com/users"];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                           
        // Handle response
        if (data.length > 0 && error == nil)
        {
            NSError *error = nil;
            id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
            
            
            NSLog(@"users: %@",jsonObjects);
            
            if (error) {
                NSLog(@"error is %@", [error localizedDescription]);
                // Handle Error and return
                return;
            }
            NSManagedObjectContext *context = [self managedObjectContext];
            // Users
            NSArray *usersData = jsonObjects;
            for (int i=0; i < [usersData count]; i++) {
                NSDictionary *user = (NSDictionary*) [usersData objectAtIndex:i];
                NSLog(@"user name: %@", [user objectForKey:@"username"]);
                
                
                
                // Create a new user managed object
                NSManagedObject *userMO = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
                [userMO setValue:[user objectForKey:@"name"] forKey:@"name"];
                [userMO setValue:[user objectForKey:@"phone"] forKey:@"phone"];
                [userMO setValue:[user objectForKey:@"email"] forKey:@"email"];
                [userMO setValue:[[user objectForKey:@"id"] stringValue] forKey:@"userId"];
                
                
                // Create a new company managed object
                NSManagedObject *companyMO = [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:context];
                [companyMO setValue:[[user objectForKey:@"company"] objectForKey:@"name"] forKey:@"name"];

                // Add user to company
                [companyMO setValue:[NSSet setWithObject:userMO] forKey:@"users"];
                
                // Create a new address managed object
                NSManagedObject *addressMO = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:context];
                [addressMO setValue:[[user objectForKey:@"address"] objectForKey:@"city"] forKey:@"city"];
                [addressMO setValue:[[user objectForKey:@"address"] objectForKey:@"street"] forKey:@"street"];
                [addressMO setValue:[[user objectForKey:@"address"] objectForKey:@"suite"] forKey:@"suite"];
                [addressMO setValue:[[user objectForKey:@"address"] objectForKey:@"zipcode"] forKey:@"zipcode"];
                
                // Add user to address
                [addressMO setValue:[NSSet setWithObject:userMO] forKey:@"users"];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // Fetch the devices from persistent data store
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
                usersArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                
                // Reload users table content
                [_usersTable reloadData];
            });
        }
        else
        {
            // Handle Error
            UIAlertController *errorVC = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"Please check your connection and try again" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [errorVC addAction:okAction];
            [self presentViewController:errorVC animated:YES completion:nil];
            NSLog(@"Error: %@",error);
        }

                                           
                                           

    }];
    
    [dataTask resume] ;
}


#pragma mark - TableView Delegate & DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [usersArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:MyIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    }
    
    // Check if patients array is not null
    if ([usersArray count]) {
        User *userObj = (User*)[usersArray objectAtIndex:indexPath.row];
        cell.name.text = userObj.name;
        cell.phone.text = userObj.phone;
        cell.email.text = userObj.email;
        Company *compObj = userObj.company;
        NSManagedObjectContext *context = [self managedObjectContext];
        
        // Get Companies
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Company"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY users.company == %@", compObj];
        [request setPredicate:predicate];
        NSArray *companies = [context executeFetchRequest:request error:nil];
        Company *comp = (Company*)[companies objectAtIndex:0];
        cell.company.text = comp.name;
        
        // Get Addresses
        Address *addrObj = userObj.address;
        request = [NSFetchRequest fetchRequestWithEntityName:@"Address"];
        predicate = [NSPredicate predicateWithFormat:@"ANY users.address == %@", addrObj];
        [request setPredicate:predicate];
        NSMutableArray *addresses = [[context executeFetchRequest:request error:nil]mutableCopy];
        NSLog(@"addresses: %@",addresses);
        Address *addr = (Address*)[addresses objectAtIndex:0];
        
        cell.suite.text = addr.suite;
        cell.street.text = addr.street;
        cell.city.text = addr.city;
        
    }

    return cell;
}
- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    
    // Cell view configurations
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:241.0/255.0 blue:255.0/255.0 alpha:1];
    }
    else
        cell.backgroundColor = [UIColor whiteColor];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    User *selUser = (User*)[usersArray objectAtIndex:indexPath.row ];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserPostsViewController *postsVC = [sb instantiateViewControllerWithIdentifier:@"UserPosts"];
    postsVC.user = selUser;
    [self.navigationController pushViewController:postsVC animated:YES];
}
@end
