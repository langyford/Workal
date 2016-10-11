//
//  HomePageViewController.m
//  ParseStarterProject
//
//  Created by Luke Langford on 12/10/2015.
//
//

#import "HomePageViewController.h"

@interface HomePageViewController ()

@end

@implementation HomePageViewController
@synthesize activityView;
@synthesize loadingLabel;
@synthesize loadingView;

-(IBAction)toggleAction {
    
    if ([toggle selectedSegmentIndex] == 0) {
        
        // map view
        jobFeedTableView.alpha = 0;
        mapView.alpha = 1;
        
        MKUserLocation *userLocation = mapView.userLocation;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 10000,10000);
        [mapView setRegion:region animated:YES];
        
        [self setMapPins];
        
    }
    else if ([toggle selectedSegmentIndex] == 1) {
        
        // feed view
        jobFeedTableView.alpha = 1;
        mapView.alpha = 0;
        
        [self loadFeedData];
        
    }
    else if ([toggle selectedSegmentIndex] == 2) {
        
        // cards view
        jobFeedTableView.alpha = 0;
        mapView.alpha = 0;
        // TODO
        
    }
    
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

-(void)setMapPins {
    
    // query for jobs - CHANGE THIS so that it only shows local posts
    PFQuery *mapPinQuery = [PFQuery queryWithClassName:@"Jobs"];
    [mapPinQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSUInteger jobCount = objects.count;
        
        for (int i = 0; i <= jobCount; i++) {
        
            PFGeoPoint *point = objects[i][@"GeoLocation"];
        
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(point.latitude, point.longitude);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setTitle:objects[i][@"Title"]];
            [annotation setCoordinate:coord];
            [mapView addAnnotation:annotation];
            
        }
        
    }];
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
     MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.canShowCallout = YES;
    
    return annotationView;
    
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"Pin Pressed!");
}

-(void)loadFeedData {
    
    [self presentLoadingIcon];
    
    // querying for all posts - CHANGE THIS so that it only shows local posts
    PFQuery *query = [PFQuery queryWithClassName:@"Jobs"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            jobFeedArray = [[NSArray alloc] init];
            
            jobFeedArray = objects;
            arraySize = objects.count;
            [jobFeedTableView reloadData];
            
        }
        else {
            
            // error loading data
            UIAlertView *errorLoadingAlert = [[UIAlertView alloc] initWithTitle:@"Error loading data" message:@"try refreshing the page" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [errorLoadingAlert show];
            
        }
        
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arraySize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *jobFeedTableID = @"JobFeedTableID";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:jobFeedTableID];
    
    if (cell == nil) {
        
        // cell format
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jobFeedTableID];
        cell.textLabel.numberOfLines = 0; // no limit
        
    }
    
    PFImageView *imageHolder = [[PFImageView alloc] init];
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:@"Jobs"];
    [imageQuery whereKey:@"objectId" equalTo:[jobFeedArray[indexPath.row] objectId]];
    [imageQuery getFirstObjectInBackgroundWithBlock:^(PFObject *jobObject, NSError *error) {
        
        if (!error) {
            
            PFFile *imageFile = [jobObject objectForKey:@"JobPicture"];
            imageHolder.file = imageFile;
            [imageHolder loadInBackground:^(UIImage *jobImage, NSError *error) {
                
                cell.imageView.file = imageFile;
                
            }];
            
        }
        else {
            
            // TODO: if unable to load job image, load a default image instead
            
        }
        
    }];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ \n \n $%@ Should Take %@ Day(s) \n %@", jobFeedArray[indexPath.row][@"Title"], jobFeedArray[indexPath.row][@"Price"], jobFeedArray[indexPath.row][@"NumberOfDays"], jobFeedArray[indexPath.row][@"Location"]];
    
    [activityView stopAnimating];
    [activityView removeFromSuperview];
    [loadingView removeFromSuperview];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    rowNumberPressed = indexPath.row;
    [self performSegueWithIdentifier:@"ViewJobSegue" sender:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadFeedData];
    
    // UI setup
    // hide map and make tableview visible
    jobFeedTableView.alpha = 1;
    mapView.alpha = 0;
    
    // Change the color of the Status Bar
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:109/255.0 green:76/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:statusBarView];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ViewJobSegue"]) {
        
        // going to job details view
        ViewJobViewController *viewJobViewController = segue.destinationViewController;
        viewJobViewController.objectID = [jobFeedArray[rowNumberPressed] valueForKey:@"objectId"];
        
    }
    
}

// UI Handlers

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
