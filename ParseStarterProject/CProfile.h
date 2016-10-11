//
//  CProfile.h
//  ParseStarterProject
//
//  Created by Luke Langford on 12/10/2015.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface CProfile : NSObject {
    
}

@property (weak, nonatomic) IBOutlet NSString *name;
@property (weak, nonatomic) IBOutlet NSString *email;
@property (weak, nonatomic) IBOutlet NSString *age;
@property (weak, nonatomic) IBOutlet NSString *password;
@property (weak, nonatomic) IBOutlet NSString *location;
@property (weak, nonatomic) IBOutlet NSString *language;
@property (weak, nonatomic) IBOutlet UIImage *profileImage;


-(void)getProfileDetails;
-(void)getLoginDetails;

@end
