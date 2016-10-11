//
//  YourPostsViewController.h
//  ParseStarterProject
//
//  Created by Luke Langford on 14/11/2015.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "EditYourPostViewController.h"

@interface YourPostsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
   
    NSArray *usersPostsArray;
    NSArray *searchArray;
    NSUInteger *arraySize;
    NSUInteger *searchArraySize;
    NSInteger rowNumberPressed;
    
    bool hasSearchCriteria;
    
    IBOutlet UITableView *usersPostsTableView;
    
}

@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

@property () bool reloadBool;
@property (strong, nonatomic) IBOutlet UITextField *searchBar;
@property (strong, nonatomic) NSString *searchString;

@end
