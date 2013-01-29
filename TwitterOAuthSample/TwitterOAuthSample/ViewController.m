//
//  ViewController.m
//  TwitterOAuthSample
//
//  Created by HyunJun Sung on 1/29/13.
//  Copyright (c) 2013 BlinkFactory. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"

// 트위터 연동 방법
// 1. Twitter+OAuth 프로젝트에 추가 (svn에서 받은 z경우 .svn은 삭제하고 넣을 것 find ./ -name ".svn" | xargs rm -R )
// 2. Target - Build Phases - Link Binary with Libraries : libxml2.dylib 추가
// 3. Target - Build Settings - Header Search Paths : $(SDKROOT)/usr/include/libxml2 추가하고 recursive 체크
// 4. 트위터 연동할 뷰 컨트롤러에 SA_OAuthTwitterEngine *_engine 객체 추가
// 5. 발급받은 ConsumerKey, ConsumerSecret 준비
// 6. SA_OAuthTwitterEngine 생성. delegate 설정.
// 7. [_engine isAuthorized]로 인증 체크
// 7-1. 인증이 안되어 있으면 SA_OAuthTwitterController 를 생성. 모달로 띄운다. 인증 성공후 NSUserDefaults에 authData, userName을 저장.
// 7-2. 인증 해제시 [_engine clearAccessToken] 로 초기화. 저장된 authData, userName 삭제.
// 8. 인증 성공후 sendUpdate로 트위터 업로드 (delegate로 성공, 실패 처리) (이미지 업로드는 불가)

// 참고 : 트위터 프로필 이미지 API (SDWebImage 사용)
// https://api.twitter.com/1/users/profile_image?screen_name=[username]&size=bigger
// size : original, mini (24x24), normal (48x48), bigger (73x73) 원하는 크기로 요청

#define kOAuthConsumerKey		@"zr00UtVOTtjh0TfWTxOUkg"
#define kOAuthConsumerSecret	@"kFB44Idn8NdAhwTcsvZGqBwBMc2Z5P6msCRwQPn2tA"

static NSString *const kTWAuthDataKey = @"TWAuthData";
static NSString *const kTWUserNameKey = @"TWUserName";


@interface ViewController ()

@end

@implementation ViewController

- (void) setTwitterConnected:(NSString*)username {
    if (username) {
        self.isConnectedLabel.text = @"Connected.";
        [self.twitterButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        self.userName.text = username;
        [self.profile setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", username]]];
    } else {
        self.isConnectedLabel.text = @"Disconnected.";
        [self.twitterButton setTitle:@"Connect" forState:UIControlStateNormal];
        self.userName.text = @"";
        [self.profile setImage:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (!_engine) {
        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
        _engine.consumerKey = kOAuthConsumerKey;
        _engine.consumerSecret = kOAuthConsumerSecret;
    }
    
    NSString *authData = [[NSUserDefaults standardUserDefaults] objectForKey:kTWAuthDataKey];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kTWUserNameKey];
    NSLog(@"auth - %@",authData);
    NSLog(@"user - %@",userName);
    if ([_engine isAuthorized]) {
        [self setTwitterConnected:userName];
    } else {
        [self setTwitterConnected:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)twitterButtonTouched:(id)sender {
    NSLog(@"Authorized : %@", [_engine isAuthorized]?@"YES":@"NO");
    if (![_engine isAuthorized]) {
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
        NSLog(@"controller : %@", controller);
        if (controller) {
            [self presentViewController:controller animated:YES completion:nil];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTWAuthDataKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTWUserNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_engine clearAccessToken];
        [self setTwitterConnected:nil];
    }
}

- (IBAction)sendButtonTouched:(id)sender {
    if (_engine && [_engine isAuthorized]) {
        [_engine sendUpdate:self.twitMsg.text];
    } else {
        NSLog(@"Not Connected.");
    }
}

- (void)dealloc {
    [_engine release];
    [_twitMsg release];
    [_profile release];
    [_userName release];
    [_twitterButton release];
    [_isConnectedLabel release];
    [super dealloc];
}

#pragma mark - SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
    NSLog(@"OAuth Success : %@", username);
}
- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
    NSLog(@"OAuth Failed.");
}
- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
    NSLog(@"OAuth Canceled.");
}

#pragma mark - SA_OAuthTwitterEngine
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
    //implement these methods to store off the creds returned by Twitter
    NSLog(@"cached Oauth Data %@", data);
    NSLog(@"user name : %@", username);
    
    // 인증성공. 인증정보 저장
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:kTWAuthDataKey];
    [defaults setObject:username forKey:kTWUserNameKey];
    [defaults synchronize];
    
    [self setTwitterConnected:username];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
    // 트위터 연동상태 유지를 위해 인증성공시 저장된 authData를 반환.
    NSLog(@"cachedTwitterOAuthDataForUsername : %@", username);
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTWAuthDataKey];
}

- (void) twitterOAuthConnectionFailedWithData: (NSData *) data {
    NSLog(@"twitterOAuthConnectionFailedWithData : %@", data);
}

- (void) requestSucceeded: (NSString *) requestIdentifier {
    // 트위터 업로드 성공
    NSLog(@"Request %@ succeeded", requestIdentifier);
}
- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
    // 트위터 업로드 실패
    NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

@end
