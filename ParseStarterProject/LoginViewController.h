//
//  LoginViewController.h
//  ParseStarterProject
//
//  Created by Luke Langford on 12/10/2015.
//
//

#import <UIKit/UIKit.h>
#import "CProfile.h"
#import <Parse/Parse.h>
#import "HomePageViewController.h"

@interface LoginViewController : UIViewController {
    
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *passwordField;
    
}

// loading icon
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

// methods and functions
-(void)loadDetails;
-(void)login;

-(IBAction)loginOnClick;

@end
