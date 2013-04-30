/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 13 Aug 2010
 Last revised on 29 Apr 2013
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of The Ohio State University nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SHALL THE OHIO STATE UNIVERSITY BE BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ////////////////////////////////////////////////////////////////////////*/

#import "HOLMapInfoController.h"


@implementation HOLMapInfoController

@synthesize delegate;
@synthesize locInfo, sections, nNumRows;
@synthesize locCuids;
@synthesize locationManager;
@synthesize currentLocation;
@synthesize settings;
@synthesize sectionType;


#pragma mark -
#pragma mark Initialization

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if ((self = [super initWithStyle:style])) {
 }
 return self;
 }
 */


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.clearsSelectionOnViewWillAppear = YES;
	
	// Start the location services
	[self.locationManager startUpdatingLocation];
	
	// Set table view styles
	self.tableView.backgroundColor = UIColorFromRGB(0xFEF1B5);
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.rowHeight = 65.0;
	
	// Check if all specimens should be shown for locality (taxon map only)
	BOOL bShowAllSpecimens = NO;
	
	if (sectionType == HOLTABCONTROLLERTAXON) {
		bShowAllSpecimens = [delegate showAllSpecimens];
	}
	
	// Get the general information for taxon from server
	HOLServerInteraction *server = [[HOLServerInteraction alloc] initWithSettings:self.settings];
	NSDictionary *dictInfo = [server getLocalityInfo:self.sectionType showAll:bShowAllSpecimens];
	
	[server release];
	
	// Check if results were available (internet enabled)
	if (dictInfo != nil) {
		self.locInfo = [dictInfo objectForKey:@"locInfo"];
		self.locCuids = [self.locInfo objectForKey:@"cuids"];
		
		// Check which sections to show
		NSMutableArray *sectionsShow = [[NSMutableArray alloc] initWithCapacity:6];
		
		[sectionsShow addObject:@"name"];
		[sectionsShow addObject:@"coords"];
		
		// Check for available elements of geographic hierarchy
		NSDictionary *dictGeoHier = [self.locInfo objectForKey:@"hier"];
		
		if ([dictGeoHier objectForKey:@"pol0"] != nil) {
			[sectionsShow addObject:@"pol0"];
		}
		if ([dictGeoHier objectForKey:@"pol1"] != nil) {
			[sectionsShow addObject:@"pol1"];
		}
		if ([dictGeoHier objectForKey:@"pol2"] != nil) {
			[sectionsShow addObject:@"pol2"];
		}
		if ([dictGeoHier objectForKey:@"pol4"] != nil) {
			[sectionsShow addObject:@"pol4"];
		}
		
		[sectionsShow addObject:@"directions"];
		
		self.nNumRows = [sectionsShow count];
		self.sections = sectionsShow;
		
		[sectionsShow release];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Server communication error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release]; 
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Hide loading image
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HOLHIDELOADING" object:self];
	
	// Check for orientation change in another tab
	UIInterfaceOrientation currentOrientation = [UIDevice currentDevice].orientation;
	
	if (currentOrientation == UIInterfaceOrientationPortrait ||
		currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.navigationController setNavigationBarHidden:NO];
	} else if (currentOrientation == UIInterfaceOrientationLandscapeLeft ||
			   currentOrientation == UIInterfaceOrientationLandscapeRight) {	
		[self.navigationController setNavigationBarHidden:YES];
	}
	
	// Set title text when view is about to be shown
	if (self.sectionType == HOLTABCONTROLLERTAXON) {
		[self.settings.taxonNaviBar setText:@"Locality Information" withNaviBar:self.navigationController.navigationBar];
	} else {
		[self.settings.nearbyNaviBar setText:@"Locality Information" withNaviBar:self.navigationController.navigationBar];
	}
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.navigationController setNavigationBarHidden:NO];
	} else {
		[self.navigationController setNavigationBarHidden:YES];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0: {
			return self.nNumRows;
			
			break;
		}
		default: {
			return [self.locCuids count];
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0: {
			return @"General Information";
			
			break;
		}
		default: {
			return [NSString stringWithFormat:@"Specimen IDs (%d)", [self.locCuids count]];
		}
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
    // Configure the cell based on its position within the sections array
	switch (indexPath.section) {
		case 0: {
			static NSString *CellIdentifier = @"GenCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			}
			
			NSString *sectionName = [self.sections objectAtIndex:indexPath.row];
			
			cell.contentView.backgroundColor = [UIColor clearColor];
			
			cell.textLabel.numberOfLines = 2;
			
			if ([sectionName isEqualToString:@"name"]) {
				cell.detailTextLabel.text = @"Locality Name";
				cell.textLabel.text = [[self.locInfo objectForKey:sectionName] stringByReplacingOccurrencesOfString:@"&quot;"
																										 withString:@"\""];
			} else if ([sectionName isEqualToString:@"coords"]) {
				cell.detailTextLabel.text = @"Coordinates";
				cell.textLabel.text = [[self.locInfo objectForKey:sectionName] stringByReplacingOccurrencesOfString:@"&quot;"
																										 withString:@"\""];
			} else if ([sectionName isEqualToString:@"pol0"]) {
				NSDictionary *dictGeoHier = [self.locInfo objectForKey:@"hier"];
				
				cell.detailTextLabel.text = @"Country";
				cell.textLabel.text = [[[dictGeoHier objectForKey:sectionName] objectForKey:@"name"]
									   stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
			} else if ([sectionName isEqualToString:@"pol1"]) {
				NSDictionary *dictGeoHier = [self.locInfo objectForKey:@"hier"];
				
				cell.detailTextLabel.text = @"State";
				cell.textLabel.text = [[[dictGeoHier objectForKey:sectionName] objectForKey:@"name"]
									   stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
			} else if ([sectionName isEqualToString:@"pol2"]) {
				NSDictionary *dictGeoHier = [self.locInfo objectForKey:@"hier"];
				
				cell.detailTextLabel.text = @"County";
				cell.textLabel.text = [[[dictGeoHier objectForKey:sectionName] objectForKey:@"name"]
									   stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
			} else if ([sectionName isEqualToString:@"pol4"]) {
				NSDictionary *dictGeoHier = [self.locInfo objectForKey:@"hier"];
				
				cell.detailTextLabel.text = @"Town";
				cell.textLabel.text = [[[dictGeoHier objectForKey:sectionName] objectForKey:@"name"]
									   stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
			} else if ([sectionName isEqualToString:@"directions"]) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = @"Get Driving Directions";
				cell.detailTextLabel.text = @"Driving directions to collecting locality";
			} else {
				cell.detailTextLabel.text = [sectionName capitalizedString];
				cell.textLabel.text = [self.locInfo objectForKey:sectionName];
			}
			
			break;
		}
		default: {
			static NSString *CellIdentifier = @"CuidCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			
			cell.contentView.backgroundColor = [UIColor clearColor];
			cell.textLabel.text = [[self.locCuids objectAtIndex:indexPath.row] objectForKey:@"cuid"];
		}
	}
	
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Check which section the selected cell is located
	switch (indexPath.section) {
		case 0: {
			// Check if selected cell is a driving directions cell
			NSString *sectionName = [self.sections objectAtIndex:indexPath.row];
			
			if ([sectionName isEqualToString:@"directions"]) {
				NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@,%@&saddr=%f,%f",
								 [self.locInfo objectForKey:@"lat"], [self.locInfo objectForKey:@"long"],
								 self.currentLocation.latitude, self.currentLocation.longitude];
				
				// Send driving directions request off to Google Maps app
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];				
			}
			
			break;
		}
		default: {
		}
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


// Location-specific functions
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	self.currentLocation = newLocation.coordinate;
}

- (void)dealloc {
	[settings release];
	[locInfo release];
	[locCuids release];
	[sections release];
	[locationManager release];
    [super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings section:(HOLTABCONTROLLERTYPE)tabSection {
	self = [super initWithStyle:UITableViewStylePlain];
	
	self.settings = loadSettings;
	sectionType = tabSection;
	
	// Initialize the location services
	CLLocationManager *tempLocationManager = [[CLLocationManager alloc] init];
	tempLocationManager.delegate = self;
	tempLocationManager.distanceFilter = 1000.0;
	tempLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	
	self.locationManager = tempLocationManager;
	
	[tempLocationManager release];
	
	return self;
}

@end

