//
//  CreateJobViewController.m
//  ParseStarterProject
//
//  Created by Luke Langford on 15/10/2015.
//
//

#import "CreateJobViewController.h"

@interface CreateJobViewController ()

@end

@implementation CreateJobViewController
@synthesize pageIndicator;
@synthesize activityView;
@synthesize loadingLabel;
@synthesize loadingView;

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

-(void)getInfoForJob {
    
    // create an array with users job details
    NSMutableArray *jobDetails = [[NSMutableArray alloc] init];
    jobDetails[0] = titleField.text;
    jobDetails[1] = descriptionField.text;
    jobDetails[2] = numberOfDaysField.text;
    jobDetails[3] = priceField.text;
    jobDetails[4] = locationField.text;
    jobDetails[5] = categoryField.text;
    
    // job image
    NSData *imageData = UIImageJPEGRepresentation(imageView.image, 0.5);
    [jobDetails addObject:imageData];
    
    // create job with new array
    [self createJobWithDetails:jobDetails];
    
}

-(void)createJobWithDetails:(NSMutableArray *)jobDetails {
    
    [self presentLoadingIcon];
    
    // create new job object to save to Parse DB
    PFObject *newJob = [PFObject objectWithClassName:@"Jobs"];
    
    // set details
    newJob[@"Title"] = jobDetails[0];
    newJob[@"Description"] = jobDetails[1];
    newJob[@"NumberOfDays"] = jobDetails[2];
    newJob[@"Price"] = jobDetails[3];
    newJob[@"Location"] = jobDetails[4];
    newJob[@"Category"] = jobDetails[5];
    
    // set job image
    PFFile *imageFile = [PFFile fileWithName:@"jobPic.png" data:jobDetails[6]];
    [imageFile saveInBackground];
    [newJob setObject:imageFile forKey:@"JobPicture"];
    
    // set location of job from users current location
    PFGeoPoint *point = [PFGeoPoint geoPointWithLocation:locationManager.location];
    newJob[@"GeoLocation"] = point;
    
    // make the current user the author of the job
    PFUser *currentUser = [PFUser currentUser];
    newJob[@"Author"] = currentUser.username;
    
    // currently have to set public access to YES :S - TODO make this able to be private
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES];
    [readOnlyACL setPublicWriteAccess:YES];
    newJob.ACL = readOnlyACL;
    
    // save new job object in the background
    [newJob saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            // hide loading icon
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            [loadingView removeFromSuperview];
            
            // alert user
            NSLog(@"Post succeeded");
            UIAlertView *jobPostedAlert = [[UIAlertView alloc] initWithTitle:@"Job Posted!" message:@"Your job has been posted" delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
            [jobPostedAlert show];
            
            // change view
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            HomePageViewController *homepageViewController = (HomePageViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"HomePageViewController"];
            [self presentViewController:homepageViewController animated:YES completion:nil];
            
        }
        else {
            
            // failed
            // alert user
            NSLog(@"Post failed");
            UIAlertView *jobFailedAlert = [[UIAlertView alloc] initWithTitle:@"Failed to post job" message:[NSString stringWithFormat:@"%@", error] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [jobFailedAlert show];
            
        }
        
    }];
    
}

-(IBAction)takePhoto {
    
    UIAlertView *imageOptionsAlert;
    
    // check if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // user has option to either take photo or pick from photo library
        imageOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Image options" message:@"Take photo or pick from library" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Pick photo", @"Take photo", nil];
        imageOptionsAlert.tag = 200;
        
    }
    else {
        
        // user only has option to pick photo from library
        imageOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Image options" message:@"Take photo or pick from library" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Pick photo", nil];
        imageOptionsAlert.tag = 200;
        
    }
    
    [imageOptionsAlert show];
    
}

-(IBAction)getLocation {
    
    // Start looking for users location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
    
}

-(IBAction)createJobOnClick {
    [self getInfoForJob];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // UI setup
    // Change the color of the Status Bar
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:109/255.0 green:76/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:statusBarView];
    
    pageIndicator = 1;
    
    [[self.view viewWithTag:5] setAlpha:0];
    [[self.view viewWithTag:6] setAlpha:0];
    locationButton.alpha = 0;
    [[self.view viewWithTag:7] setAlpha:0];
    [[self.view viewWithTag:8] setAlpha:0];
    [[self.view viewWithTag:9] setAlpha:0];
    [[self.view viewWithTag:10] setAlpha:0];
    [[self.view viewWithTag:11] setAlpha:0];
    [[self.view viewWithTag:12] setAlpha:0];
    
    [leftArrow setAlpha:0];
    [leftArrow setEnabled:NO];
    [rightArrow setAlpha:1];
    [rightArrow setEnabled:YES];
    
    
}

// UI Handlers

-(IBAction)leftArrowOnClick {
    
    [self textFieldShouldReturn:titleField];
    [self textFieldShouldReturn:numberOfDaysField];
    [self textFieldShouldReturn:priceField];
    [self textFieldShouldReturn:locationField];
    [self textFieldShouldReturn:categoryField];
    
    if (pageIndicator == 2) {
        
        // on second page
        
        // fade out page 2
        [UIView animateWithDuration:0.3f animations:^{
            
            locationButton.alpha = 0;
            [self hideElementsFrom:5 to:9];
            
        } completion:^(BOOL finished) {
            
            // fade in page 1
            [UIView animateWithDuration:0.3f animations:^{
                
                [self showElementsFrom:1 to:4];
                
            } completion:nil];
            
        }];
        
        // disable left arrow
        [leftArrow setAlpha:0];
        [leftArrow setEnabled:NO];
        
    }
    else if (pageIndicator == 3) {
        
        // on third page
        
        // fade out page 3
        [UIView animateWithDuration:0.3f animations:^{
            
            [self hideElementsFrom:10 to:12];
            
        } completion:^(BOOL finished) {
            
            // fade in page 2
            [UIView animateWithDuration:0.3f animations:^{
                
                [self showElementsFrom:5 to:9];
                locationButton.alpha = 1;
                
            } completion:nil];
            
        }];
        
        [rightArrow setAlpha:1];
        [rightArrow setEnabled:YES];
        
    }
    
    pageIndicator--;
    
}

-(IBAction)rightArrowOnClick {
    
    [self textFieldShouldReturn:titleField];
    [self textFieldShouldReturn:numberOfDaysField];
    [self textFieldShouldReturn:priceField];
    [self textFieldShouldReturn:locationField];
    [self textFieldShouldReturn:categoryField];
    
    if (pageIndicator == 1) {
        
        // on first page
        
        // fade out page 1
        [UIView animateWithDuration:0.3f animations:^{
            
            [self hideElementsFrom:1 to:4];
            
        } completion:^(BOOL finished) {
            
            // fade in page 2
            [UIView animateWithDuration:0.3f animations:^{
                
                [self showElementsFrom:5 to:9];
                locationButton.alpha = 1;
                
            } completion:nil];
            
        }];
        
        [leftArrow setAlpha:1];
        [leftArrow setEnabled:YES];
        
    }
    else if (pageIndicator == 2) {
        
        // on second page
        
        // fade out page 2
        [UIView animateWithDuration:0.3f animations:^{
            
            [self hideElementsFrom:5 to:9];
            locationButton.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            // fade in page 3
            [UIView animateWithDuration:0.3f animations:^{
                
                [self showElementsFrom:10 to:12];
                
            } completion:nil];
            
        }];
        
        // disable right arrow
        [rightArrow setAlpha:0];
        [rightArrow setEnabled:NO];
        
    }
    
    pageIndicator++;
    
}

// for fading in and out UI elements
-(void)hideElementsFrom:(int)min to:(int)max {
    
    for (int i = min; i <= max; i++) {
        
        [[self.view viewWithTag:i] setAlpha:0];
        
    }
    
}
-(void)showElementsFrom:(int)min to:(int)max {
    
    for (int i = min; i <= max; i++) {
        
        [[self.view viewWithTag:i] setAlpha:1];
        
    }
    
}

// return key on press
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

// Change color of text in status bar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// alert view button on click
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 200) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        if (buttonIndex == 0) {
            
            // pick photo from library
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
            
        }
        
        else if (buttonIndex == 1) {
            
            // take a new photo
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
            
        }
        
    }
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Put image into UIImageView
    self->imageView.image = image;
    
    // Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

// end UI Handlers

// Location handling

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    // found users location, stop looking and convert to usable format
    [self->locationManager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self->locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        locationField.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.subLocality];
        
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    // couldn't find user's location, log error
    NSLog(@"%@", error);
    
}

// end Location Handling

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
