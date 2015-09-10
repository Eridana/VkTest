//
//  NewsViewController.m
//  vkTest
//
//  Created by Женя Михайлова on 02.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import "NewsViewController.h"
#import "PostModel.h"
#import "DataSource.h"
#import "NewsTableViewCell.h"
#import "Post.h"
#import "User.h"
#import "Group.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Attachment.h"
#import "ImageViewController.h"
#import "DetailViewController.h"

const int count = 20;

@interface NewsViewController () <UITableViewDelegate, UITableViewDataSource, PostModelDelegate>
{
    PostModel *model;
    DataSource *dataSource;
    Post *selected;
    UIFont *textFont;
    UIRefreshControl *refreshControl;
    NSString *nextFrom;
}
@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    textFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(checkNewPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    model = [PostModel new];
    model.delegate = self;
    dataSource = [DataSource new];
    
    [self setLastUpdationDate];
    [self loadPosts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDataSource
{
    [dataSource setupFetchResultsControllerWithRequest:[model getPostsRequest]];
    [self.tableView reloadData];
}

- (void)setLastUpdationDate
{
    NSString *date = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastUnixTimeDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadPosts
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [model getPostsWithNextFrom:nextFrom];
    });
}

- (void)checkNewPosts
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastUnixTimeDate"]) {
            NSString *utDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUnixTimeDate"];
            double lastDate = [utDate doubleValue];
            [model getPostsToEndDate:lastDate];
        }
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[dataSource.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [dataSource.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *cell = (NewsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
    
    Post *data = [dataSource.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = data.postTitle;
    
    NSString *text = data.postText;
    if (data.attachments.count > 0) {
        Attachment *photo = [[data.attachments allObjects] firstObject];
        if (photo.text.length > 0) {
            if (text.length == 0) {
                text = photo.text;
            }
        }
        [cell.postImageView sd_setImageWithURL:[NSURL URLWithString:photo.attachmentUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.imageHeightConstraint.constant = 150;
            cell.postImageView.clipsToBounds = YES;
        }];
    }
    else {
        cell.postImageView.image = nil;
        cell.imageHeightConstraint.constant = 0;
    }
    
    if (text.length > 120) {
        text = [NSString stringWithFormat:@"%@...Читать дальше", [text substringToIndex:119]];
    }
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: textFont}];
    cell.postTextView.text = text;
    cell.postTextView.frame = CGRectMake(cell.postTextView.frame.origin.x, cell.postTextView.frame.origin.y, cell.postTextView.frame.size.width, textSize.height);

    if (data.postUser) {
        cell.userNameLabel.text = data.postUser.userName;
        [cell.avatarImgView sd_setImageWithURL:[NSURL URLWithString:data.postUser.userAvatarUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.avatarImgView.clipsToBounds = YES;
        }];
    }
    if (data.postGroup) {
        cell.userNameLabel.text = data.postGroup.groupName;
        [cell.avatarImgView sd_setImageWithURL:[NSURL URLWithString:data.postGroup.groupAvatarUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.avatarImgView.clipsToBounds = YES;
        }];
    }
    
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:data.date];
    cell.dateLabel.text = dateString;

    //[cell layoutIfNeeded];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    selected = [dataSource.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showPostDetail" sender:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > [dataSource.fetchedResultsController fetchedObjects].count - 2 ) {//&& [dataSource.fetchedResultsController fetchedObjects].count > 6) {
        [self loadPosts];
    }
}

#pragma mark- PostModelDelegate

- (void)getPostsSuccessWithNextFrom:(NSString *)nextFromStr
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (refreshControl.refreshing == YES) {
            [refreshControl endRefreshing];
            [self setLastUpdationDate];
        }
        else {
            nextFrom = nextFromStr;
        }
        NSLog(@"getPostsSuccess");
        [self setupDataSource];
    });
    
}

- (void)getPostsDidFailWithError
{
    NSLog(@"getPostsDidFailWithError");
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPostDetail"]) {
        DetailViewController *detailController = segue.destinationViewController;
        [detailController setPost:selected];
    }
}

@end
