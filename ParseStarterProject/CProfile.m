//
//  CProfile.m
//  ParseStarterProject
//
//  Created by Luke Langford on 12/10/2015.
//
//

#import "CProfile.h"

@implementation CProfile
@synthesize email, name, age, password, location, language, profileImage;

-(void)getProfileDetails {
    
    PFUser *currentuser = [PFUser currentUser];
    name = currentuser[@"name"];
    email = currentuser.email;
    age = currentuser[@"age"];
    location = currentuser[@"location"];
    language = currentuser[@"language"];
    
    [currentuser[@"profilepicture"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        profileImage = [UIImage imageWithData:data];
        
    }];
    
}

-(void)getLoginDetails {
    
    PFUser *currentUser = [PFUser currentUser];
    email = currentUser.email;
    password = currentUser.password;
    
}

@end
