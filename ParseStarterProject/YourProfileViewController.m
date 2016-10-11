//
//  YourProfileViewController.m
//  ParseStarterProject
//
//  Created by Luke Langford on 20/10/2015.
//
//

#import "YourProfileViewController.h"

@interface YourProfileViewController ()

@end

@implementation YourProfileViewController
@synthesize activityView;
@synthesize loadingLabel;
@synthesize loadingView;

-(IBAction)editProfileOnClick {

    // show text fields
    [self showTextFields];
    
    // load currentuser details into textfields
    PFUser *currentUser = [PFUser currentUser];
    nameField.text = currentUser[@"name"];
    ageField.text = currentUser[@"age"];
    emailField.text = currentUser.email;
    locationField.text = currentUser[@"location"];
    languageField.text = currentUser[@"language"];
    
}

-(IBAction)saveProfileOnClick {
    
    [self presentLoadingIcon];
    
    // save changes to users profile
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"name"] = nameField.text;
    currentUser[@"age"] = ageField.text;
    currentUser.email = emailField.text;
    currentUser[@"location"] = locationField.text;
    currentUser[@"language"] = languageField.text;
    
    // reupload profile picture
    NSData *imageData = UIImageJPEGRepresentation(profileImageView.image, 1);
    PFFile *imageFile = [PFFile fileWithName:@"profilepic.png" data:imageData];
    [imageFile saveInBackground];
    [currentUser setObject:imageFile forKey:@"profilepicture"];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // hide loading icon
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        [loadingView removeFromSuperview];
        
        // alert and change back to labels
        UIAlertView *detailsSaved = [[UIAlertView alloc] initWithTitle:@"Your details have been saved" message:@"Your profile has been updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [detailsSaved show];
        
        [self loadProfileDetails];
        
    }];
    
}

-(IBAction)discardChangesOnClick {
    
    // simply hide the textfields and show the labels
    [self showLabels];
    
}

-(void)loadProfileDetails {
    
    [self showLabels];
    
    // using CProfile class to handle getting current users profile data
    CProfile *cProfile = [[CProfile alloc] init];
    [cProfile getProfileDetails];
    
    nameLabel.text = cProfile.name;
    ageLabel.text = cProfile.age;
    emailLabel.text = cProfile.email;
    locationLabel.text = cProfile.location;
    languageLabel.text = cProfile.language;
    
    // get current users profile picture
    PFUser *currentuser = [PFUser currentUser];
    [currentuser[@"profilepicture"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        profileImage = [UIImage imageWithData:data];
        profileImageView.image = profileImage;
        
    }];
    
}

-(IBAction)takePicture {
    
    UIAlertView *imageOptionsAlert;
    
    // check if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // give user the option to either take a photo or pick one from their photo library
        imageOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Image options" message:@"Take photo or pick from library" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Pick photo", @"Take photo", nil];
        imageOptionsAlert.tag = 100;
        
    }
    else {
        
        // user will only have the option to pick a photo from their library
        imageOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Image options" message:@"Pick a photo from your library" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Pick photo", nil];
        imageOptionsAlert.tag = 100;
        
    }
    
    [imageOptionsAlert show];
    
}

-(IBAction)getCurrentLocation {
    
    // Start looking for users location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // UI setup
    // Change the color of the Status Bar
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:109/255.0 green:76/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:statusBarView];
    
    [self loadProfileDetails];
    
}

// alertview button on click
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // imagepicker alert
    if (alertView.tag == 100) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // pick photo
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
    
}

// Location handling

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    // current location found, stop looking and convert into a usable format
    [self->locationManager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self->locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        locationField.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.subLocality];
        
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    // couldn't find user's location for some reason, log the error message
    NSLog(@"%@", error);
    
}

// end Location Handling

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Put image into UIImageView
    self->profileImageView.image = image;
    
    // Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

// keyboard return key on click
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)showLabels {
    
    nameLabel.alpha = 1;
    ageLabel.alpha = 1;
    emailLabel.alpha = 1;
    locationLabel.alpha = 1;
    languageLabel.alpha = 1;
    editProfileButton.alpha = 1;
    editProfileButton.enabled = YES;
    yourJobsButton.alpha = 1;
    yourJobsButton.enabled = YES;
    
    nameField.alpha = 0;
    ageField.alpha = 0;
    emailField.alpha = 0;
    locationField.alpha = 0;
    languageField.alpha = 0;
    saveProfileButton.alpha = 0;
    saveProfileButton.enabled = NO;
    cameraButton.alpha = 0;
    cameraButton.enabled = NO;
    locationButton.alpha = 0;
    locationButton.enabled = NO;
    discardChanges.alpha = 0;
    discardChanges.enabled = NO;
    
}
-(void)showTextFields {
    
    nameLabel.alpha = 0;
    ageLabel.alpha = 0;
    emailLabel.alpha = 0;
    locationLabel.alpha = 0;
    languageLabel.alpha = 0;
    editProfileButton.alpha = 0;
    editProfileButton.enabled = NO;
    yourJobsButton.alpha = 0;
    yourJobsButton.enabled = NO;
    
    nameField.alpha = 1;
    ageField.alpha = 1;
    emailField.alpha = 1;
    locationField.alpha = 1;
    languageField.alpha = 1;
    saveProfileButton.alpha = 1;
    saveProfileButton.enabled = YES;
    cameraButton.alpha = 1;
    cameraButton.enabled = YES;
    locationButton.alpha = 1;
    locationButton.enabled = YES;
    discardChanges.alpha = 1;
    discardChanges.enabled = YES;
    
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
