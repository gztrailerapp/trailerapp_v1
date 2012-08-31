//
//  DCDamageListViewController.m
//  DamageClaim
//
//  Created by Dev on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCDamageListViewController.h"

#import "DCDamageDetailModel.h"

#import "Const.h"

#import "DCDamageViewController.h"


@interface DCDamageListViewController ()
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (nonatomic, retain) NSMutableArray *modelArray;

-(void) customizeNavigationBar;
-(void) logout;
-(void) submitDamageReport;

@end

@implementation DCDamageListViewController
@synthesize damageTableView = _damageTableView;
@synthesize modelArray = _modelArray;

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
    //fill array with dummy values
    self.modelArray = [[[NSMutableArray alloc] init] autorelease];
    
    [self customizeNavigationBar];
    
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"9 Damages Reported";
        damageModel.damagePosition = @"2 Days ago";
        [self.modelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"2 Damages Reported";
        damageModel.damagePosition = @"11 Days ago";
        [self.modelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"7 Damages Reported";
        damageModel.damagePosition = @"15 Days ago";
        [self.modelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"3 Damages Reported";
        damageModel.damagePosition = @"2 Months ago";
        [self.modelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"1 Damage Reported";
        damageModel.damagePosition = @"6 Months ago";
        [self.modelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"5 Damages Reported";
        damageModel.damagePosition = @"2 Years ago";
        [self.modelArray addObject:damageModel];
    }
    
#if kDebug
    for (DCDamageDetailModel *damage in self.modelArray) {
        NSLog(@"%@", damage.damageType);
    }
    
#endif
    
    [self.damageTableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc {
    [_damageTableView release];
    [_modelArray release];
    [super dealloc];

}

#pragma mark - Others
-(void) customizeNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SUBMIT", @"") style:UIBarButtonItemStylePlain target:self action:@selector(submitDamageReport)] autorelease];
//self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)] autorelease];
    
    //    if (self.navigationItem) {
    //        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LOGOUT", @"") style:UIBarButtonItemStylePlain target:self action:@selector(logout)] autorelease];
    //    }
}

-(void) logout {
    
}


//sends the damage report to the server
-(void) submitDamageReport {
    
}

#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            if (self.modelArray) {
                return [self.modelArray count];
            }
        default:
            break;
    }
    
    return 0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"REPORTED_DAMAGES", @"");
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    
    
    if (!cell) {
        if (indexPath.section == 0) {
            NSArray *customCellAddNewItemView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
            if (customCellAddNewItemView) {
                if ([customCellAddNewItemView count] > 0) {
                    cell = [customCellAddNewItemView objectAtIndex:0];
                }
            }
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
            
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (indexPath.section == 0) {
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_LABEL_ADD_NEW_ITEM_TAG];
        titleLabel.text = NSLocalizedString(@"REPORT_NEW_DAMAGE", @"");
    } else if (indexPath.row < [self.modelArray count]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        DCDamageDetailModel *damageModel = [self.modelArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = @"";
        if (damageModel.damageType) {
            cell.textLabel.text = damageModel.damageType;
        }
        
        cell.detailTextLabel.text = @"";
        if (damageModel.damagePosition) {
            cell.detailTextLabel.text = damageModel.damagePosition;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DCDamageViewController *damageViewController = [[[DCDamageViewController alloc] initWithNibName:@"DamageView" bundle:nil] autorelease];
        [self.navigationController pushViewController:damageViewController animated:YES];
    }
}



@end
