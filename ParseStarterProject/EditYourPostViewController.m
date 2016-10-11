//
//  EditYourPostViewController.m
//  ParseStarterProject
//
//  Created by Luke Langford on 17/11/2015.
//
//

#import "EditYourPostViewController.h"

@interface EditYourPostViewController ()

@end

@implementation EditYourPostViewController
@synthesize objectID;
@synthesize activityView;
@synthesize loadingLabel;
@synthesize loadingView;

// segment control onclick
-(IBAction)toggleAction {
    
    if ([toggle selectedSegmentIndex] == 0) {
        
        // save changes
        [self saveJobOnClick];
        [self deselectToggle];
        
    }
    else if ([toggle selectedSegmentIndex] == 1) {
        
        // edit job
        [self editJobOnClick];
        [self deselectToggle];
        
    }
    else if ([toggle selectedSegmentIndex] == 2) {
        
        // delete job
        [self deselectToggle];
        
        // double check author
        PFUser *currentUser = [PFUser currentUser];
        PFQuery *query = [PFQuery queryWithClassName:@"Jobs"];
        [query whereKey:@"objectId" equalTo:objectID];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *jobObject, NSError *error) {
            
            if ([currentUser.email isEqualToString:jobObject[@"Author"]]) {
                
                [self deleteJob];
                
            }
            else {
                
                // access denied (not the author)
                UIAlertView *accessDeniedAlert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"You are not allow to modify this job" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                YourPostsViewController *yourPostsView = (YourPostsViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"YourPostsViewController"];
                [self presentViewController:yourPostsView animated:YES completion:nil];
                
                [accessDeniedAlert show];
                
            }
            
        }];
        
    }
    
}

-(void)deleteJob {
    
    // alert
    UIAlertView *deleteJobAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure" message:@"are you sure you want to delete this job" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    deleteJobAlert.tag = 800;
    [deleteJobAlert show];
    
}

-(IBAction)getLocation {
    
    didUpLocation = true;
    
    // Start looking for users location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
    
}

-(void)editJobOnClick {
    
    // check to make sure the current user owns this post
    PFUser *currentuser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Jobs"];
    [query whereKey:@"objectId" equalTo:objectID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *jobObject, NSError *error) {
        
        if ([currentuser.email isEqualToString:jobObject[@"Author"]]) {
            
            // is the owner of the post
            
            // show text fields
            [self showTextFields];
            
            // set text of the fields
            titleField.text = jobObject[@"Title"];
            descriptionBox.text = jobObject[@"Description"];
            priceField.text = jobObject[@"Price"];
            numberOfDaysField.text = jobObject[@"NumberOfDays"];
            locationField.text = jobObject[@"Location"];
            categoryField.text = jobObject[@"Category"];
            
        }
        else {
            
            // somethings fucked up big.. alert and send them back YOU SHALL NOT PASS
            //TODO
            UIAlertView *accessDeniedAlert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"You are not allowed to edit this post" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [accessDeniedAlert show];
            
            // go back to yourpostsview
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            YourPostsViewController *yourPostsViewController = (YourPostsViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"YourPostsViewController"];
            [self presentViewController:yourPostsViewController animated:YES completion:nil];
            
        }
        
    }];
    
}

-(void)saveJobOnClick {
    
    // show loading icon
    [self presentLoadingIcon];
    
    // get the current job and overwrite data with new data
    PFQuery *query = [PFQuery queryWithClassName:@"Jobs"];
    [query getObjectInBackgroundWithId:objectID block:^(PFObject *jobObject, NSError *error) {
        
        jobObject[@"Title"] = titleField.text;
        jobObject[@"Description"] = descriptionBox.text;
        jobObject[@"Price"] = priceField.text;
        jobObject[@"NumberOfDays"] = numberOfDaysField.text;
        jobObject[@"Category"] = categoryField.text;
        jobObject[@"Location"] = locationField.text;
        
        // if a new auto location was set, overwrite old location data
        if (didUpLocation) {
            
            PFGeoPoint *point = [PFGeoPoint geoPointWithLocation:locationManager.location];
            jobObject[@"GeoLocation"] = point;
            didUpLocation = false;
            
        }
        
        // save new data to parse DB
        [jobObject saveInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
            
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            [loadingView removeFromSuperview];
            
            UIAlertView *changesSavedAlert = [[UIAlertView alloc] initWithTitle:@"Changes Saved" message:@"the changes have been made to your post" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [self showLabels];
            [changesSavedAlert show];
            
        }];
        
    }];
    
}

-(void)getJobDetails {
    
    // get the current job and set the data into the UI labels
    PFQuery *query = [PFQuery queryWithClassName:@"Jobs"];
    [query whereKey:@"objectId" equalTo:objectID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *jobObject, NSError *error) {
        
        // standard data
        titleLabel.text = jobObject[@"Title"];
        descriptionBox.text = jobObject[@"Description"];
        priceLabel.text = [NSString stringWithFormat:@"Price: $%@", jobObject[@"Price"]];
        numberOfDaysLabel.text = [NSString stringWithFormat:@"Should take %@ Day(s)", jobObject[@"NumberOfDays"]];
        locationLabel.text = jobObject[@"Location"];
        categoryLabel.text = jobObject[@"Category"];
        
        // job image
        [jobObject[@"JobPicture"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            jobImage = [UIImage imageWithData:data];
            jobImageView.image = jobImage;
            
        }];
        
    }];
    
}

-(IBAction)takePicture {
    
    UIAlertView *imageOptionsAlert;
    
    // check if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // give the user the option to either pick a photo from their library or take a new one
        imageOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Image options" message:@"Take photo or pick from library" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Pick photo", @"Take photo", nil];
        imageOptionsAlert.tag = 700;
        
    }
    else {
        
        // user can only pick a photo from their library
        imageOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Image options" message:@"Pick from library" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Pick photo", nil];
        imageOptionsAlert.tag = 700;
        
    }
    
    [imageOptionsAlert show];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Put image into UIImageView
    self->jobImageView.image = image;
    
    // Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

// alertview button onclick
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // photo source alert
    if (alertView.tag == 700) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // pick photo from library
        if (buttonIndex == 0) {
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
            
        }
        
        // take a new photo
        else if (buttonIndex == 1) {
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
            
        }
        
    }
    // delete job alert
    else if (alertView.tag == 800) {
        
        // send out ninjas to assassinate ze job
        if (buttonIndex == 1) {
            
            [self presentLoadingIcon];
            
            // delete job
            PFQuery *query = [PFQuery queryWithClassName:@"Jobs"];
            [query whereKey:@"objectId" equalTo:objectID];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *jobObject, NSError *error) {
                
                [jobObject deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
                    
                    if (!error) {
                        
                        // hide loading icon
                        [activityView stopAnimating];
                        [activityView removeFromSuperview];
                        [loadingView removeFromSuperview];
                        
                        // job deleted
                        UIAlertView *jobDeletedAlert = [[UIAlertView alloc] initWithTitle:@"Job Delete" message:@"Your job has been delete" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        
                        // go back to your posts
                        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                        YourPostsViewController *yourPostsView = (YourPostsViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"YourPostsViewController"];
                        [self presentViewController:yourPostsView animated:YES completion:nil];
                        
                        [jobDeletedAlert show];
                        
                    }
                    
                }];
                
            }];
            
        }
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Change the color of the Status Bar
    
    [self getJobDetails];
    [self showLabels];
    
    didUpLocation = false;
    
    // make status bar color brown
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:109/255.0 green:76/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:statusBarView];
    
}

// UI Handlers

-(void)showLabels {
    
    titleLabel.alpha = 1;
    categoryLabel.alpha = 1;
    priceLabel.alpha = 1;
    locationLabel.alpha = 1;
    numberOfDaysLabel.alpha = 1;
    descriptionBox.alpha = 1;
    
    titleField.alpha = 0;
    categoryField.alpha = 0;
    priceField.alpha = 0;
    locationField.alpha = 0;
    numberOfDaysField.alpha = 0;
    descriptionBox.editable = NO;
    cameraButton.alpha = 0;
    cameraButton.enabled = NO;
    locationButton.alpha = 0;
    locationButton.enabled = NO;
    
}
-(void)showTextFields {
    
    titleLabel.alpha = 0;
    categoryLabel.alpha = 0;
    priceLabel.alpha = 0;
    locationLabel.alpha = 0;
    numberOfDaysLabel.alpha = 0;
    
    titleField.alpha = 1;
    categoryField.alpha = 1;
    priceField.alpha = 1;
    locationField.alpha = 1;
    numberOfDaysField.alpha = 1;
    descriptionBox.editable = YES;
    cameraButton.alpha = 1;
    cameraButton.enabled = YES;
    locationButton.alpha = 1;
    locationButton.enabled = YES;
    
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

// deselect the segment control button so another one can be pressed
-(void)deselectToggle {

    toggle.selectedSegmentIndex = UISegmentedControlNoSegment;
    
}

// Location handling

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    // found current location, stop looking and convert into a usable format
    [self->locationManager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self->locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        locationField.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.subLocality];
        
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    // couldn't find users current location, log error message
    NSLog(@"%@", error);
    
}

// Change color of text in status bar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// keyboard return key onclick
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
