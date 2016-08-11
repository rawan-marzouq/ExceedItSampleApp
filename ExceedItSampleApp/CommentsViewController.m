//
//  CommentsViewController.m
//  ExceedItSampleApp
//
//  Created by Rawan Marzouq on 8/10/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentsTableViewCell.h"
#import "Comment.h"



@interface CommentsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *commentsArray;
}
@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *postBody;

@property (weak, nonatomic) IBOutlet UITableView *commentsTable;
@end

@implementation CommentsViewController


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
    self.postTitle.text = self.post.title;
    self.postBody.text = self.post.body;
    
    // Load Post's comments
    [self GetPostComments];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Post's comments API
-(void)GetPostComments{
    
    // Initialies comments array
    commentsArray = [[NSMutableArray alloc]init];
    
    // REST CALL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://jsonplaceholder.typicode.com/comments?postId=%@",self.post.postId]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        // Handle response
        if (data.length > 0 && error == nil)
        {
            NSError *error = nil;
            id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
            
            
            NSLog(@"comments: %@",jsonObjects);
            
            if (error) {
                NSLog(@"error is %@", [error localizedDescription]);
                // Handle Error and return
                return;
            }
            NSManagedObjectContext *context = [self managedObjectContext];
            // Comments
            NSArray *commentsData = jsonObjects;
            for (int i=0; i < [commentsData count]; i++) {
                NSDictionary *comment = (NSDictionary*) [commentsData objectAtIndex:i];
                
                // Create a new post managed object
                NSManagedObject *commentMO = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
                [commentMO setValue:[comment objectForKey:@"name"] forKey:@"name"];
                [commentMO setValue:[comment objectForKey:@"body"] forKey:@"body"];
                [commentMO setValue:[comment objectForKey:@"email"] forKey:@"email"];
                
                // Add post to user
                [commentMO setValue:self.post forKey:@"post"];
                NSLog(@"commentMO: %@",commentMO);
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Fetch the devices from persistent data store
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Comment"];
                commentsArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                NSLog(@"commentsArray: %@",commentsArray);
                
                // Reload comments table content
                [_commentsTable reloadData];
                
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
    return [commentsArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    
    CommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil] forCellReuseIdentifier:MyIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    }
    
    // Check if posts array is not null
    if ([commentsArray count]) {
        Comment *commentObj = (Comment*)[commentsArray objectAtIndex:indexPath.row];
        cell.commentTitle.text = commentObj.name;
        cell.commenterEmail.text = commentObj.email;
        cell.commentBody.text = commentObj.body;
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
@end
