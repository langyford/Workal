//
//  LoginViewController.m
//  ParseStarterProject
//
//  Created by Luke Langford on 12/10/2015.
//
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
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

-(void)loadDetails {
    
    // load users email into the email field
    CProfile *currentProfile = [[CProfile alloc] init];
    [currentProfile getLoginDetails];
    
    emailField.text = currentProfile.email;
    
}

-(void)login {
    
    // login with current details
    [PFUser logInWithUsernameInBackground:emailField.text password:passwordField.text block:^(PFUser *user, NSError *error) {
        
        if (user) {
            
            // login successful
            NSLog(@"login successful");
            
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            [loadingView removeFromSuperview];
            
            // Goto Home Page
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            HomePageViewController *homepageViewController = (HomePageViewController*)[storyboard instantiateViewControllerWithIdentifier:@"HomePageViewController"];
            [self presentViewController:homepageViewController animated:YES completion:nil];
            
        }
        else {
            
            // login failed
            UIAlertView *loginFailedAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"%@", error] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [loginFailedAlert show];
            
        }
        
    }];
    
}

-(IBAction)loginOnClick {
    
    [self login];
    [self presentLoadingIcon];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadDetails];
    
    // UI setup
    // Change the color of the Status Bar
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:109/255.0 green:76/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:statusBarView];
    
}

// hide keyboard on return key press
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
