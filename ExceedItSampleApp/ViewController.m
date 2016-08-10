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

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *usersArray;
}
@property (weak, nonatomic) IBOutlet UITableView *usersTable;

@end

@implementation ViewController

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
            
            // Users
            NSArray *usersData = jsonObjects;
            for (int i=0; i < [usersData count]; i++) {
                NSDictionary *user = (NSDictionary*) [usersData objectAtIndex:i];
                NSLog(@"user name: %@", [user objectForKey:@"username"]);
                User *userObj = [[User alloc]init];
                userObj.userId = [user objectForKey:@"id"];
                userObj.name = [user objectForKey:@"name"];
                userObj.phone = [user objectForKey:@"phone"];
                userObj.email = [user objectForKey:@"email"];
                userObj.company = [[user objectForKey:@"company"] objectForKey:@"name"];
                userObj.suite = [[user objectForKey:@"address"] objectForKey:@"suite"];
                userObj.street = [[user objectForKey:@"address"] objectForKey:@"street"];
                userObj.city = [[user objectForKey:@"address"] objectForKey:@"city"];
                [usersArray addObject:userObj];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
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
        cell.company.text = userObj.company;
        cell.suite.text = userObj.suite;
        cell.street.text = userObj.street;
        cell.city.text = userObj.city;
        
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
    postsVC.userId = selUser.userId;
    [self.navigationController pushViewController:postsVC animated:YES];
}
@end
