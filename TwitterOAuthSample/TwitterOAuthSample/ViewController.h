//
//  ViewController.h
//  TwitterOAuthSample
//
//  Created by HyunJun Sung on 1/29/13.
//  Copyright (c) 2013 BlinkFactory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"

@interface ViewController : UIViewController <SA_OAuthTwitterControllerDelegate> {
    SA_OAuthTwitterEngine *_engine;
}

@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *isConnectedLabel;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) IBOutlet UITextField *twitMsg;
@property (retain, nonatomic) IBOutlet UIImageView *profile;

- (IBAction)twitterButtonTouched:(id)sender;
- (IBAction)sendButtonTouched:(id)sender;

@end
