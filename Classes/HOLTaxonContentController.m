/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 7 Mar 2010
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

#import "HOLTaxonContentController.h"

// Private function declarations
@interface HOLTaxonContentController()
- (void)showTaxonGeneralInfo;
- (void)showTaxonIncludedTaxa;
- (void)showTaxonSynonyms;
- (void)showTaxonLiterature;
- (void)showTaxonMap;
- (void)showTaxonImages;
- (void)showTaxonInsts;
- (void)showTaxonAssociations;
- (void)showTaxonHabitats;
- (void)showTaxonTypes;
int getSectionValue(NSString *sectionName);
int sortSections(id obj1, id obj2, void *context);
@end



@implementation HOLTaxonContentController

@synthesize sections, nNumRows;
@synthesize settings;

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
	
	// Set table view styles
	self.tableView.backgroundColor = UIColorFromRGB(0xFEF1B5);
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	// Set background view color on iPad
	if ([self.tableView respondsToSelector:@selector(setBackgroundView:)]) {
		self.tableView.backgroundView = nil;
	}
	
	// Check which taxon sections to show
	HOLServerInteraction *server = [[HOLServerInteraction alloc] initWithSettings:self.settings];
	NSDictionary *dictInfo = [server getTaxonStats];
	
	[server release];
	
	// Check if results were available (internet enabled)
	if (dictInfo != nil) {
		NSDictionary *dictStats = [dictInfo objectForKey:@"stats"];
		NSMutableArray *sectionsShow = [[NSMutableArray alloc] initWithCapacity:12];
		
		self.nNumRows = 1;
		
		// Add table header with the taxon name
		UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 35)];
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, [UIScreen mainScreen].applicationFrame.size.width, 30)];
		
		headerLabel.text = [NSString stringWithFormat:@"%@ %@", [dictInfo objectForKey:@"taxon"], [dictInfo objectForKey:@"author"]];
		headerLabel.textColor = [UIColor blackColor];
		headerLabel.shadowColor = UIColorFromRGB(0xE9C2A6);
		headerLabel.shadowOffset = CGSizeMake(1, 2);
		headerLabel.font = [UIFont boldSystemFontOfSize:20];
		headerLabel.backgroundColor = [UIColor clearColor];
		
		[containerView addSubview:headerLabel];
		
		self.tableView.tableHeaderView = containerView;
		
		[headerLabel release];
		[containerView release];
		
		// Add taxon sections
		[sectionsShow addObject:@"General Information"]; // Add general as first section title (always shown)
		
		for (NSString *keyText in dictStats) {
			NSString *dictStatValue = [dictStats objectForKey:keyText];
			
			// Add the section to the show list if items are available
			if (dictStatValue.intValue > 0) {
				// Add the appropriate title to the sections
				if ([keyText isEqualToString:@"included"]) {
					[sectionsShow addObject:@"Included Taxa"];
				} else if ([keyText isEqualToString:@"synonym"]) {
					[sectionsShow addObject:@"Synonyms"];
				} else if ([keyText isEqualToString:@"insts"]) {
					[sectionsShow addObject:@"Collections"];
				} else if ([keyText isEqualToString:@"maps"]) {
					[sectionsShow addObject:@"Map"];
				} else if ([keyText isEqualToString:@"lit_syns"]) {
					[sectionsShow addObject:@"Literature"];
				} else if ([keyText isEqualToString:@"type_syns"]) {
					[sectionsShow addObject:@"Types"];
				} else if ([keyText isEqualToString:@"assocs"]) {
					[sectionsShow addObject:@"Associations"];
				} else if ([keyText isEqualToString:@"habitats"]) {
					[sectionsShow addObject:@"Habitat"];
				} else if ([keyText isEqualToString:@"images"]) {
					[sectionsShow addObject:@"Images"];
				} else {
					// Omit
					self.nNumRows--;
				}
				
				self.nNumRows++;
			}
		}
		
		// Adjust the content downward and expand for overflow of sections (below hierarchy bar)
		UIEdgeInsets tableInset;
		
		tableInset.top = 15.0;
		tableInset.left = 0.0;
		tableInset.right = 0.0;
		tableInset.bottom = 0.0;
		
		if (self.nNumRows > 6) {
			tableInset.bottom = 10 + (self.nNumRows - 6) * 50.0;
		}
		
		self.tableView.contentInset = tableInset;
		
		// Sort the sections to display in desired order
		[sectionsShow sortUsingFunction:sortSections context:nil];
		
		self.sections = sectionsShow;
		
		[sectionsShow release];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Server communication error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	// Hide loading image
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HOLHIDELOADING" object:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.nNumRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
	
    // Configure the cell based on its position within the sections array
	cell.backgroundColor = UIColorFromRGB(0xEEDC82);
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = [self.sections objectAtIndex:indexPath.row];
	
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
/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return indexPath;
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Show loading image
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLOADING" object:self];
	
	// Load the section view
	NSString *keyText = [sections objectAtIndex:indexPath.row];
	
	if ([keyText isEqualToString:@"General Information"]) {
		[self performSelector:@selector(showTaxonGeneralInfo) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Included Taxa"]) {
		[self performSelector:@selector(showTaxonIncludedTaxa) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Synonyms"]) {
		[self performSelector:@selector(showTaxonSynonyms) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Collections"]) {
		[self performSelector:@selector(showTaxonInsts) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Map"]) {
		[self performSelector:@selector(showTaxonMap) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Literature"]) {
		[self performSelector:@selector(showTaxonLiterature) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Types"]) {
		[self performSelector:@selector(showTaxonTypes) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Associations"]) {
		[self performSelector:@selector(showTaxonAssociations) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Habitat"]) {
		[self performSelector:@selector(showTaxonHabitats) withObject:nil afterDelay:0.0];
	} else if ([keyText isEqualToString:@"Images"]) {
		[self performSelector:@selector(showTaxonImages) withObject:nil afterDelay:0.0];
	} else {
		// DO NOTHING
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


- (void)dealloc {
	[settings release];
    [super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings {
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	self.settings = loadSettings;
	
	return self;
}

// Private functions
- (void)showTaxonGeneralInfo {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONGENERALINFO" object:self];
}

- (void)showTaxonIncludedTaxa {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONINCLUDEDTAXA" object:self];
}

- (void)showTaxonSynonyms {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONSYNONYMS" object:self];
}

- (void)showTaxonLiterature {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONLITERATURE" object:self];
}

- (void)showTaxonMap {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONMAP" object:self];
}

- (void)showTaxonImages {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONIMAGES" object:self];
}

- (void)showTaxonInsts {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONCOLLECTIONS" object:self];
}

- (void)showTaxonAssociations {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONASSOCS" object:self];
}

- (void)showTaxonHabitats {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONHABITATS" object:self];
}

- (void)showTaxonTypes {
	// Send message
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONTYPES" object:self];
}

int getSectionValue(NSString *sectionName) {
	NSInteger nReturn;
	
	if ([sectionName isEqualToString:@"General Information"]) {
		nReturn = 0;
	} else if ([sectionName isEqualToString:@"Included Taxa"]) {
		nReturn = 1;
	} else if ([sectionName isEqualToString:@"Synonyms"]) {
		nReturn = 2;
	} else if ([sectionName isEqualToString:@"Collections"]) {
		nReturn = 3;
	} else if ([sectionName isEqualToString:@"Map"]) {
		nReturn = 4;
	} else if ([sectionName isEqualToString:@"Literature"]) {
		nReturn = 5;
	} else if ([sectionName isEqualToString:@"Types"]) {
		nReturn = 6;
	} else if ([sectionName isEqualToString:@"Images"]) {
		nReturn = 7;
	} else if ([sectionName isEqualToString:@"Associations"]) {
		nReturn = 8;
	} else if ([sectionName isEqualToString:@"Habitat"]) {
		nReturn = 9;
	} else {
		nReturn = 10;
	}
	
	return nReturn;
}

int sortSections(id obj1, id obj2, void *context) {
	NSInteger nSection1 = getSectionValue(obj1);
	NSInteger nSection2 = getSectionValue(obj2);
	
	if (nSection1 < nSection2) {
		return NSOrderedAscending;
	} else if (nSection1 > nSection2) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

@end

