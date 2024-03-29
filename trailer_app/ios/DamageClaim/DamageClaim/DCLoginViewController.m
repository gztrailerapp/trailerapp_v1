//
//  DCLoginViewController.m
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCLoginViewController.h"

#import "Const.h"

#import "DCLoginModel.h"

#import "DCSharedObject.h"

#import "RequestHeaders.h"

#import "MBProgressHUD.h"

#import "JSONKit.h"

#import "DCSurveyViewController.h"

#import "DCAboutViewController.h"

#import "DCChangePasswordViewController.h"

@interface DCLoginViewController ()
@property (retain, nonatomic) IBOutlet UIView *parentView;
@property (retain, nonatomic) IBOutlet UITableView *loginTableView;
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellLoginView;
@property (retain, nonatomic) DCLoginModel *loginModel;
@property (nonatomic) NSInteger httpStatusCode;
@property (retain, nonatomic) HTTPService *httpService;
@property (retain, nonatomic) DCAboutViewController *aboutViewController;
@property (nonatomic, getter = isAboutShown) BOOL aboutShown;

- (IBAction)openAbout:(id)sender;
-(void) keyboardWillShow:(NSNotification *)notification;
-(void) keyboardWillHide:(NSNotification *)notification;
- (IBAction)login:(id)sender;
-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier;
-(BOOL) isEmpty:(NSString *)string;
- (IBAction)resetPassword:(id)sender;

@end

@implementation DCLoginViewController
@synthesize parentView = _parentView;
@synthesize loginTableView = _loginTableView;
@synthesize customCellLoginView = _customCellLoginView;
@synthesize loginModel = _loginModel;
@synthesize httpStatusCode = _httpStatusCode;
@synthesize httpService = _httpService;
@synthesize aboutShown = _aboutShown;
@synthesize aboutViewController = _aboutViewController;

#pragma mark - View LifeCycle methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (!self.loginModel) {
        self.loginModel = [[[DCLoginModel alloc] init] autorelease];
    }
    
    [self.loginTableView reloadData];
}

-(void) viewDidAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    UITextField *usernameTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:LOGIN_USERNAME_TEXTFIELD_TAG];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME]) {
        
        self.loginModel.loginUsername = [[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME];
        usernameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME];
    } else {
        usernameTextField.text = @"";
    }
    
    UITextField *passwordTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:LOGIN_PASSWORD_TEXTFIELD_TAG];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD]) {
        self.loginModel.loginPassword = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD];
        passwordTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD];
    } else {
        passwordTextField.text = @"";
    }

}
-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.navigationController) {
        [DCSharedObject hideProgressDialogInView:self.navigationController.view];
    } else {
        [DCSharedObject hideProgressDialogInView:self.view];
    }
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self setLoginTableView:nil];
    [self setCustomCellLoginView:nil];
    [self setParentView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_loginTableView release];
    [_customCellLoginView release];
    [_parentView release];
    [_loginModel release];
    [_httpService release];
    [_aboutViewController release];
    [super dealloc];
}

#pragma mark - Touches delegate
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isAboutShown]) {
        if (self.aboutViewController) {
            [self.aboutViewController viewDidDisappear:YES];
            [self.aboutViewController viewDidUnload];
            [self.aboutViewController.view removeFromSuperview];
            self.aboutShown = NO;
        }
    }
}

#pragma mark - Others

- (IBAction)openAbout:(id)sender {
    if (![self isAboutShown]) {
        if (self.aboutViewController) {
            self.aboutViewController = nil;
        }
        self.aboutViewController = [[[DCAboutViewController alloc] initWithNibName:@"AboutView" bundle:nil] autorelease];
        self.aboutViewController.delegate = self;
        [self.aboutViewController viewDidLoad];
        [self.aboutViewController viewDidAppear:YES];
        [self.view addSubview:self.aboutViewController.view];
        self.aboutViewController.view.center = self.view.center;
        [self setAboutShown:YES];
    }
}

-(void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //get the parent view's currrent frame and change it
    CGRect newFrame = self.parentView.frame;
    newFrame.origin.y -=keyboardSize.height / 3;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25];
    [self.parentView setFrame:newFrame];
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //get the parent view's currrent frame and change it
    CGRect newFrame = self.parentView.frame;
    newFrame.origin.y +=keyboardSize.height / 3;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25];
    [self.parentView setFrame:newFrame];
    [UIView commitAnimations];
}

- (IBAction)login:(id)sender {
    
    UITextField *usernameTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:LOGIN_USERNAME_TEXTFIELD_TAG];
    
    UITextField *passwordTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:LOGIN_PASSWORD_TEXTFIELD_TAG];
    
#if kDebug
    NSLog(@"username: %@ password: %@", usernameTextField.text, passwordTextField.text);
#endif
    //store the username temporariy to share amongst the objects
    [[[DCSharedObject sharedPreferences] preferences] setValue:usernameTextField.text forKey:USER_NAME];
    //store the username temporariy to share amongst the screen
    [[[DCSharedObject sharedPreferences] preferences] setValue:passwordTextField.text forKey:PASSWORD];
    
    //remove the old username and password
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_KEY] &&
        [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_SECRET_KEY]) {
        
        if ([self isEmpty:usernameTextField.text] || [self isEmpty:passwordTextField.text]) {
            [self showAlertWithMessage:NSLocalizedString(@"EMPTY_USERNAME_PASSWORD", @"")];
            
        } else {
            [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:AUTHENTICATE_LOGIN requestMethod:kRequestMethodPOST model:AUTHENTICATE delegate:self viewController:self];
        }
    } else {
        [self showAlertWithMessage:NSLocalizedString(@"NO_API_KEY_ERROR", @"")];
    }
}

-(BOOL) isEmpty:(NSString *)string {
    NSCharacterSet *whiteSpaces = [NSCharacterSet whitespaceCharacterSet];
    NSString *validatedString = [string stringByTrimmingCharactersInSet:whiteSpaces];
    if ([validatedString length] == 0) {
        return YES;
    }
    return NO;
}

- (IBAction)resetPassword:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.loginTableView reloadData];
    self.loginModel.loginPassword = nil;
    [DCSharedObject makeURLCALLWithHTTPService:self.httpService
                                  extraHeaders:nil
                                          body:nil
                                    identifier:AUTHENTICATE_RESET
                                 requestMethod:kRequestMethodPUT
                                         model:AUTHENTICATE
                                      delegate:self
                                viewController:self];
}


-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier {
    //logout irrespective of the response string
    if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
        if (self.navigationController) {
            [DCSharedObject hideProgressDialogInView:self.navigationController.view];
        } else {
            [DCSharedObject hideProgressDialogInView:self.view];
        }
        [DCSharedObject processLogout:self.navigationController clearData:NO];
        return;
    } else
    if ([identifier isEqualToString:AUTHENTICATE_LOGIN]) {
        NSDictionary *jsonDict = [responseString objectFromJSONString];
        if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
            NSNumber *status = [jsonDict valueForKey:SUCCESS];
            if ([status boolValue]) {
                //store the info till the user logs out
                if ([[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_KEY] &&
                    [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_SECRET_KEY]) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[[[DCSharedObject sharedPreferences] preferences] valueForKey:USER_NAME] forKey:USER_NAME];
                    [[NSUserDefaults standardUserDefaults] setValue:[[[DCSharedObject sharedPreferences] preferences] valueForKey:PASSWORD] forKey:PASSWORD];
                }
                
                //store the contact name and account name
                if ((NSNull *)[jsonDict valueForKey:@"contactname"] != [NSNull null]) {
                    NSString *contactName = [jsonDict valueForKey:@"contactname"];
                    [[NSUserDefaults standardUserDefaults] setValue:contactName forKey:CONTACT_NAME];
                }
                
                if ((NSNull *)[jsonDict valueForKey:@"accountname"] != [NSNull null]) {
                    NSString *accountName = [jsonDict valueForKey:@"accountname"];
                    [[NSUserDefaults standardUserDefaults] setValue:accountName forKey:ACCOUNT_NAME];
                    
                }
                
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:USER_LOGGED_IN];
                
                id parentViewController = [self.navigationController parentViewController];
                if ([parentViewController isKindOfClass:[DCSurveyViewController class]]) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    DCSurveyViewController *surveyViewController = [[[DCSurveyViewController alloc] initWithNibName:@"SurveyView" bundle:nil] autorelease];
                    [self.navigationController pushViewController:surveyViewController animated:YES];
                }
                
                
                
            } else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                    NSString *errorCode = [errorDict valueForKey:@"code"];
                    if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                        if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                            [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];

                            //timestamp is adjusted. call the same url again
                            [self login:nil];
                        }
                    } else {
                        [self showAlertWithMessage:NSLocalizedString(@"INVALID_LOGIN", @"")];
                    }
                }
            }
            else {
                [self showAlertWithMessage:NSLocalizedString(@"INVALID_LOGIN", @"")];
            }
        }
    }
    
    if ([identifier isEqualToString:AUTHENTICATE_RESET]) {
        NSDictionary *jsonDict = [responseString objectFromJSONString];
        if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
            NSNumber *status = [jsonDict valueForKey:SUCCESS];
            if ([status boolValue]) {
                [self showAlertWithMessage:NSLocalizedString(@"PASSWORD_RESET_SUCCESSFUL", @"")];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIAlertViewDelegate methods
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [super alertView:alertView didDismissWithButtonIndex:buttonIndex];
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"LOGOUT", @"")]) {
        [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:AUTHENTICATE_LOGOUT requestMethod:kRequestMethodGET model:AUTHENTICATE delegate:self viewController:self];
    }
}



#pragma mark - DCAboutViewControllerDelegate methods
-(void) aboutViewWillClose {
    //aboutViewController is getting closed, set BOOL to NO
    self.aboutShown = NO;
}

#pragma mark - HTTPServiceDelegate
-(void) responseCode:(int)code {
    self.httpStatusCode = code;
}

-(void) didReceiveResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#if kDebug
    NSLog(@"%@", responseString);
#endif

    if (self.httpStatusCode == 200 || self.httpStatusCode == 403) {        
        [self parseResponse:responseString forIdentifier:identifier];
    } else if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
        if (self.navigationController) {
            [DCSharedObject hideProgressDialogInView:self.navigationController.view];
        } else {
            [DCSharedObject hideProgressDialogInView:self.view];
        }
        [DCSharedObject processLogout:self.navigationController clearData:NO];
        
    } else {
        [self showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
    if (self.navigationController) {
        [DCSharedObject hideProgressDialogInView:self.navigationController.view];
    } else {
        [DCSharedObject hideProgressDialogInView:self.view];
    }

}

-(void) serviceDidFailWithError:(NSError *)error forIdentifier:(NSString *)identifier {
    if (self.navigationController) {
        [DCSharedObject hideProgressDialogInView:self.navigationController.view];
    } else {
        [DCSharedObject hideProgressDialogInView:self.view];
    }
    if ([error code] >= kNetworkConnectionError && [error code] <= kHostUnreachableError) {
        [self showAlertWithMessage:NSLocalizedString(@"NETWORK_ERROR", @"")];
    } else if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
        [DCSharedObject processLogout:self.navigationController clearData:NO];
        
    } else {
        [self showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
}

-(void) storeResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    
}


#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == LOGIN_USERNAME_TEXTFIELD_TAG) {
#if kDebug
        NSLog(@"Entered Username: %@", textField.text);
#endif
        
        //assign it to the model
        if (self.loginModel && ![self isEmpty:textField.text]) {
            self.loginModel.loginUsername = textField.text;
            
        }
    UITextField *passwordTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:LOGIN_PASSWORD_TEXTFIELD_TAG];
        [passwordTextField becomeFirstResponder];
    }
    
    if (textField.tag == LOGIN_PASSWORD_TEXTFIELD_TAG) {
#if kDebug
        NSLog(@"Entered Password: %@", textField.text);
#endif
        //assign it to the model
        if (self.loginModel && ![self isEmpty:textField.text]) {
            self.loginModel.loginPassword = textField.text;
            
        }
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"LOGIN", nil);
    }
    return @"";
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *customCellLoginView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellLoginView" owner:nil options:nil];
    if (customCellLoginView) {
        if ([customCellLoginView count] > 0) {
            UIView *view = (UIView *)[customCellLoginView objectAtIndex:0];
            return view.frame.size.height;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        NSArray *customCellLoginView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellLoginView" owner:self options:nil];
        if (customCellLoginView) {
            if ([customCellLoginView count] > 0) {
                cell = [customCellLoginView objectAtIndex:0];
            }
        }
    }
    
    UITextField *textField = (UITextField *)[cell viewWithTag:LOGIN_CUSTOM_CELL_TEXT_FIELD_TAG];
    textField.delegate = self;
    if (indexPath.row == 0) {
        textField.placeholder = NSLocalizedString(@"USERNAME", nil);
        textField.tag = LOGIN_USERNAME_TEXTFIELD_TAG;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.returnKeyType = UIReturnKeyNext;
        if (self.loginModel.loginUsername) {
            textField.text = self.loginModel.loginUsername;
        }
    } else if (indexPath.row == 1) {
        textField.secureTextEntry = YES;
        textField.placeholder = NSLocalizedString(@"PASSWORD", nil);
        textField.tag = LOGIN_PASSWORD_TEXTFIELD_TAG;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        if (self.loginModel.loginPassword) {
            textField.text = self.loginModel.loginPassword;
        }
    }
    
    return cell;
}
@end
