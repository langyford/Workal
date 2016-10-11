//
//  YourPostsViewController.m
//  ParseStarterProject
//
//  Created by Luke Langford on 14/11/2015.
//
//

#import "YourPostsViewController.h"

@interface YourPostsViewController ()

@end

@implementation YourPostsViewController
@synthesize searchBar;
@synthesize searchString;
@synthesize activityView;
@synthesize loadingLabel;
@synthesize loadingView;

-(void)searchOnClick {
    
    // get text from search string and use in parse query
    searchString = searchBar.text;
    hasSearchCriteria = true;
    [self searchForUsersPostsWithSearch:searchString];
    
}

-(void)searchForUsersPostsWithSearch:(NSString *)userSearchString {
    
    // show loading icon
    [self presentLoadingIcon];
    
    PFUser *currentUser = [PFUser currentUser];
    
    // regex for case insensitve searches
    NSString *regex = [NSString stringWithFormat:@"(?i)%@", searchString];
    
    // lookup any posts that the user has made with the searchString criteria
    PFQuery *searchQuery = [PFQuery queryWithClassName:@"Jobs"];
    [searchQuery whereKey:@"Author" equalTo:currentUser.email];
    [searchQuery whereKey:@"Title" matchesRegex:regex];
    [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            // search succesful
            searchArray = objects;
            searchArraySize = objects.count;
            
            if (searchArraySize == 0) {
                
                // no posts were found.. alert
                UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:@"No Posts Found" message:@"Your search return no results, please try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [noResultsAlert show];
                
            }
            else {
                // posts were found, reload tableview with new data
                [usersPostsTableView reloadData];
            }
            
        }
        
    }];
    
}

-(void)loadFeedData {
    
    // show loading icon
    [self presentLoadingIcon];
    
    PFUser *currentUser = [PFUser currentUser];
    
    // query for all currentuser's job posts
    PFQuery *query = [PFQuery queryWithClassName:@"Jobs"];
    [query whereKey:@"Author" equalTo:currentUser.email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            // jobs found, reload tableview with new data
            usersPostsArray = objects;
            arraySize = objects.count;
            
            [usersPostsTableView reloadData];
            
        }
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // viewcontroller init data setting
    hasSearchCriteria = false;
    searchBar.delegate = self;
    
    [self loadFeedData];
    
    // Change the color of the Status Bar
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:109/255.0 green:76/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:statusBarView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // different tableview row size dependant on whether or not the user is searching for a specific job of theirs
    if (hasSearchCriteria) {
        return searchArraySize;
    }
    else {
        return arraySize;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // setup each cell of the table view
    static NSString *usersPostsTableViewID = @"UsersPostsTableView";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:usersPostsTableViewID];
    
    if (cell == nil) {
        // setup cell format here
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:usersPostsTableViewID];
        
        cell.textLabel.numberOfLines = 0; // no limit
        
    }
    
    PFImageView *imageHolder = [[PFImageView alloc] init];
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:@"Jobs"];
    [imageQuery whereKey:@"objectId" equalTo:[usersPostsArray[indexPath.row] objectId]];
    [imageQuery getFirstObjectInBackgroundWithBlock:^(PFObject *jobObject, NSError *error) {
        
        if (!error) {
            
            PFFile *imageFile = [jobObject objectForKey:@"JobPicture"];
            imageHolder.file = imageFile;
            [imageHolder loadInBackground:^(UIImage *jobImage, NSError *error) {
                
                cell.imageView.file = imageFile;
                
            }];
            
        }
        
    }];
    
    // if user is search for a specific post, use different array to setup cell
    if (!hasSearchCriteria) {
    
        cell.textLabel.text = [NSString stringWithFormat:@"%@ \n \n $%@ Should Take %@ Day(s) \n %@", usersPostsArray[indexPath.row][@"Title"], usersPostsArray[indexPath.row][@"Price"], usersPostsArray[indexPath.row][@"NumberOfDays"], usersPostsArray[indexPath.row][@"Location"]];
    
    }
    else {

        cell.textLabel.text = [NSString stringWithFormat:@"%@ \n \n $%@ Should Take %@ Day(s) \n %@", searchArray[indexPath.row][@"Title"], searchArray[indexPath.row][@"Price"], searchArray[indexPath.row][@"NumberOfDays"], searchArray[indexPath.row][@"Location"]];
        
    }
    
    // hide loading icon
    [activityView stopAnimating];
    [activityView removeFromSuperview];
    [loadingView removeFromSuperview];
    
    return cell;
}

// tableview cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

// tableview cell onclick
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get row id pressed and change to job detail viewcontroller
    rowNumberPressed = indexPath.row;
    [self performSegueWithIdentifier:@"ViewYourPostSegue" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ViewYourPostSegue"]) {
        
        // goto job detail viewcontroller
        EditYourPostViewController *editYourPostView = segue.destinationViewController;
        editYourPostView.objectID = [usersPostsArray[rowNumberPressed] valueForKey:@"objectId"];
        
    }
    
}

// keyboard return key onclick
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // keyboard 'search' button for search textfield onclick
    if (textField == searchBar) {
        
        [searchBar resignFirstResponder];
        [self searchOnClick];
        
    }
    
    return NO;
    
}

-(void)presentLoadingIcon {
    
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(112.5, 178.5, 170, 170)];
    loadingView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.9];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 10.0;
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(65, 40, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor grayColor];
    loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Loading...";
    [loadingView addSubview:loadingLabel];
    
    [self.view addSubview:loadingView];
    [activityView startAnimating];
    
}

// Change color of text in status bar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
