//
//  SignUpViewController.m
//  
//
//  Created by Luke Langford on 12/10/2015.
//
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController
@synthesize pageIndicator;
@synthesize activityView;
@synthesize loadingLabel;
@synthesize loadingView;

-(IBAction)signupOnClick {
    
    // start loading animation and create the new PFUser
    [self getProfileInfo];
    [self presentLoadingIcon];
    
}

-(void)getProfileInfo {
    
    // create an array of the users details
    NSMutableArray *profileDetails = [[NSMutableArray alloc] init];
    
    // standard details
    [profileDetails addObject:nameField.text];
    [profileDetails addObject:emailField.text];
    [profileDetails addObject:passwordField.text];
    [profileDetails addObject:ageField.text];
    
    // profile image
    NSData *imageData = UIImageJPEGRepresentation(imageView.image, 1);
    [profileDetails addObject:imageData];
    
    // current location
    [profileDetails addObject:locationField.text];
    
    // use new array to create a new PFUser
    [self signUpWithDetailsWithDetails:profileDetails];
    
}

-(void)signUpWithDetailsWithDetails:(NSMutableArray *)profileDetails {
    
    // create a new PFUser to add to the Parse DB
    PFUser *newUser = [PFUser user];
    
    newUser[@"name"] = profileDetails[0];
    newUser.email = profileDetails[1];
    newUser.password = profileDetails[2];
    newUser[@"age"] = profileDetails[3];
    newUser.username = profileDetails[1];
    newUser[@"location"] = profileDetails[5];
    
    // upload image to PFUser's profile
    PFFile *imageFile = [PFFile fileWithName:@"profilepic.png" data:profileDetails[4]];
    [imageFile saveInBackground];
    [newUser setObject:imageFile forKey:@"profilepicture"];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            
            // Success
            // stop loading animation
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            [loadingView removeFromSuperview];
            
            // signup successful
            NSLog(@"Signup was Successful");
            
            // goto login page
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            LoginViewController *loginViewController = (LoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:loginViewController animated:YES completion:nil];
            
        }
        else {
            
            // signup failed
            UIAlertView *signupFailedAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:[NSString stringWithFormat:@"%@", error] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [signupFailedAlert show];
            
        }
        
    }];
    
}

-(IBAction)takePicture {
    
    UIAlertView *imageOptionsAlert;
    
    // check if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // show option to take photo or pick photo from library
        imageOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Image options" message:@"Take photo or pick from library" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Pick photo", @"Take photo", nil];
        imageOptionsAlert.tag = 100;
        
    }
    else {
        
        // only show option to pick photo
        imageOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Image options" message:@"Take photo or pick from library" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Pick photo", nil];
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
    
    // sign out any existing current users
    [PFUser logOut];
    PFUser *currentUser;
    currentUser = [PFUser currentUser];// this will now be nil
    
    [self UISetup];
    
}

-(void)UISetup {
    
    // UI setup
    // Change the color of the Status Bar
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:109/255.0 green:76/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:statusBarView];
    
    pageIndicator = 1;
    [leftArrow setAlpha:0];
    [leftArrow setEnabled:NO];
    
    // Hide views with tag 5-11
    for (int i = 5; i <= 11; i++) {
        
        [[self.view viewWithTag:i] setAlpha:0];
        
    }
    
    [rightArrow setAlpha:1];
    [rightArrow setEnabled:YES];
    
}

-(IBAction)leftArrowOnClick {
    
    [self textFieldShouldReturn:locationField];
    
    if (pageIndicator == 2) {
        
        // on second page
        
        // fade out page 2
        [UIView animateWithDuration:0.3f animations:^{
            
            [self hideElementsFrom:5 to:8];
            
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
            
            [self hideElementsFrom:9 to:11];
            
        } completion:^(BOOL finished) {
            
            // fade in page 2
            [UIView animateWithDuration:0.3f animations:^{
                
                [self showElementsFrom:5 to:8];
                
            } completion:nil];
            
        }];
        
        [rightArrow setAlpha:1];
        [rightArrow setEnabled:YES];
        
    }
    
    pageIndicator--;
    
}

-(IBAction)rightArrowOnClick {
    
    [self textFieldShouldReturn:passwordField];
    [self textFieldShouldReturn:nameField];
    [self textFieldShouldReturn:emailField];
    [self textFieldShouldReturn:ageField];
    [self textFieldShouldReturn:locationField];
    
    if (pageIndicator == 1) {
        
        // on first page
        
        // fade out page 1
        [UIView animateWithDuration:0.3f animations:^{
            
            [self hideElementsFrom:1 to:4];
            
        } completion:^(BOOL finished) {
            
            // fade in page 2
            [UIView animateWithDuration:0.3f animations:^{
                
                [self showElementsFrom:5 to:8];
                
            } completion:nil];
            
        }];
        
        [leftArrow setAlpha:1];
        [leftArrow setEnabled:YES];
        
    }
    else if (pageIndicator == 2) {
        
        // on second page
        
        // fade out page 2
        [UIView animateWithDuration:0.3f animations:^{
            
            [self hideElementsFrom:5 to:8];
            
        } completion:^(BOOL finished) {
            
            // fade in page 3
            [UIView animateWithDuration:0.3f animations:^{
                
                [self showElementsFrom:9 to:11];
                
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

// Location handling

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    // Found users location, stop looking and convert to a usable format
    [self->locationManager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self->locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        locationField.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.subLocality];
        
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"%@", error);
    
}

// end Location Handling

// UI Handlers

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

// Alertview button on click
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 100) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        if (buttonIndex == 0) {
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
            
        }
        
        else if (buttonIndex == 1) {
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
            
        }
        
    }
    
}

// Show the loading animation
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    // Put image into UIImageView
    self->imageView.image = image;
    
    // Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

// Change color of text in status bar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// end UI Handlers
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
