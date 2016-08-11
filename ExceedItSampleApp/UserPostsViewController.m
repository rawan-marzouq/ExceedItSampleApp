//
//  UserPostsViewController.m
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/10/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "UserPostsViewController.h"
#import "PostTableViewCell.h"
#import "Post.h"
#import "CommentsViewController.h"


@interface UserPostsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *postsArray;
}
@property (weak, nonatomic) IBOutlet UITableView *postsTable;

@end

@implementation UserPostsViewController

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
    // Do any additional setup after loading the view.
    [self deleteAllEntities:@"Post"];
    [self GetUserPosts];
    
}
- (void)deleteAllEntities:(NSString *)nameEntity
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:nameEntity];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [[self managedObjectContext] deleteObject:object];
    }
    
    error = nil;
    [[self managedObjectContext] save:&error];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User's posts API
-(void)GetUserPosts{
    
    // Initialies posts array
    postsArray = [[NSMutableArray alloc]init];
    
    // REST CALL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://jsonplaceholder.typicode.com/posts?userId=%@",self.user.userId]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        // Handle response
        if (data.length > 0 && error == nil)
        {
            NSError *error = nil;
            id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
            
            
            NSLog(@"posts: %@",jsonObjects);
            
            if (error) {
                NSLog(@"error is %@", [error localizedDescription]);
                // Handle Error and return
                return;
            }
            NSManagedObjectContext *context = [self managedObjectContext];
            // Posts
            NSArray *postsData = jsonObjects;
            for (int i=0; i < [postsData count]; i++) {
                NSDictionary *post = (NSDictionary*) [postsData objectAtIndex:i];
                
                // Create a new post managed object
                NSManagedObject *postMO = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
                [postMO setValue:[post objectForKey:@"title"] forKey:@"title"];
                [postMO setValue:[post objectForKey:@"body"] forKey:@"body"];
                [postMO setValue:[[post objectForKey:@"id"] stringValue] forKey:@"postId"];
                
                // Add post to user
                [postMO setValue:self.user forKey:@"user"];
                NSLog(@"postMO: %@",postMO);
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Fetch the devices from persistent data store
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
                postsArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                

                
                if ([postsArray count]) {
                    // Reload posts table content
                    [_postsTable reloadData];
                }
                else{
                    // Handle Error
                    UIAlertController *errorVC = [UIAlertController alertControllerWithTitle:@"No Posts" message:@"Sorry, There are no posts for this user" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    }];
                    [errorVC addAction:okAction];
                    [self presentViewController:errorVC animated:YES completion:nil];
                }
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
    return [postsArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellReuseIdentifier:MyIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    }
    
    // Check if posts array is not null
    if ([postsArray count]) {
        Post *postObj = (Post*)[postsArray objectAtIndex:indexPath.row];
        cell.title.text = postObj.title;
        cell.body.text = postObj.body;
        
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
    Post *selPost = (Post*)[postsArray objectAtIndex:indexPath.row ];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentsViewController *commentsVC = [sb instantiateViewControllerWithIdentifier:@"Comments"];
    commentsVC.post = selPost;
    [self.navigationController pushViewController:commentsVC animated:YES];
}
@end
