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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://jsonplaceholder.typicode.com/comments?postid=%@",self.post.postId]];
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
            
            // Comments
            NSArray *commentsData = jsonObjects;
            for (int i=0; i < [commentsData count]; i++) {
                NSDictionary *post = (NSDictionary*) [commentsData objectAtIndex:i];
                Comment *commentObj = [[Comment alloc]init];
                commentObj.commentId = [post objectForKey:@"id"];
                commentObj.commentsTitle = [post objectForKey:@"name"];
                commentObj.commenterEmail = [post objectForKey:@"email"];
                commentObj.commentsBody = [post objectForKey:@"body"];
                [commentsArray addObject:commentObj];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
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
        cell.commentTitle.text = commentObj.commentsTitle;
        cell.commenterEmail.text = commentObj.commenterEmail;
        cell.commentBody.text = commentObj.commentsBody;
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
