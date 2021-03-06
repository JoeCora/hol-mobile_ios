/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 18 May 2010
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

#import "HOLTaxonLiteratureController.h"

// Private function declarations
@interface HOLTaxonLiteratureController()
	int sortLiterature(id obj1, id obj2, void *context);
@end

@implementation HOLTaxonLiteratureController

@synthesize litInfo;
@synthesize sections;
@synthesize nNumRows;
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
	
	// Set table view styles
	self.tableView.backgroundColor = UIColorFromRGB(0xFEF1B5);
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.rowHeight = 105.0;
	
	// Get the general information for taxon from server
	HOLServerInteraction *server = [[HOLServerInteraction alloc] initWithSettings:self.settings];
	NSDictionary *dictLit = [server getTaxonLiterature];
	
	[server release];
	
	// Check if results were available (internet enabled)
	if (dictLit != nil) {
		self.litInfo = [dictLit objectForKey:@"lit"];
		
		// Get number of literature citations and save citations for sorting
		NSMutableArray *arrayCits = [[NSMutableArray alloc] initWithCapacity:[[self.litInfo objectForKey:@"pubs"] count]];
		[arrayCits addObjectsFromArray:[self.litInfo objectForKey:@"pubs"]];
		self.nNumRows = [arrayCits count];
		
		// Sort the literature
		[arrayCits sortUsingFunction:sortLiterature context:nil];
		
		self.sections = arrayCits;
		
		[arrayCits release];
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
	[self.settings.taxonNaviBar setText:@"Literature" withNaviBar:self.navigationController.navigationBar];
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.nNumRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    HOLCell *cell = (HOLCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[HOLCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell based on its position within the sections array
	NSDictionary *dictCell = [self.sections objectAtIndex:indexPath.row];
	
	cell.contentView.backgroundColor = [UIColor clearColor];
	
	// Merge page annotations
	NSArray *arrayPages = [dictCell objectForKey:@"pages"];
	NSString *szPages = @"";
	NSInteger nPageCount = 0;
	
	for (NSDictionary *dictPage in arrayPages) {
		if (nPageCount > 0) {
			szPages = [NSString stringWithFormat:@"%@, %@", szPages, [dictPage objectForKey:@"page"]];
		} else {
			szPages = [dictPage objectForKey:@"page"];
		}
		
		nPageCount++;
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// Check if describer exists for taxon name and describer separation
	NSString *szTNameSeparator = @" ";
	
	if ([[dictCell objectForKey:@"describer"] isEqualToString:@""]) {
		szTNameSeparator = @"";
	}
	
	// Set text and adjust cell
	if ([[dictCell objectForKey:@"author"] isEqualToString:[dictCell objectForKey:@"describer"]]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@, %@",
							   [dictCell objectForKey:@"name"], szTNameSeparator, [dictCell objectForKey:@"author"],
							   [dictCell objectForKey:@"year"]];
		cell.textLabel.numberOfLines = 2;
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@: %@, %@",
							   [dictCell objectForKey:@"name"], szTNameSeparator, [dictCell objectForKey:@"describer"],
							   [dictCell objectForKey:@"author"], [dictCell objectForKey:@"year"]];
		cell.textLabel.numberOfLines = 3;
	}
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@. %@",
								 szPages, [dictCell objectForKey:@"comments"]];
	cell.detailTextLabel.numberOfLines = 2;
	
	// Add PDF icon if PDFs are present and public
	NSString *szPDFURL = [dictCell objectForKey:@"full_pdf"];
	
	if ([szPDFURL length] > 0 && [[dictCell objectForKey:@"public"] isEqualToString:@"Y"]) {
		[cell showPDFIcon];
	} else {
		[cell hidePDFIcon];
	}
	
    return cell;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
    NSString *label = [self.aNote length] == 0 ? kDefaultNoteLabel : self.aNote;
    CGFloat height = [label RAD_textHeightForSystemFontOfSize:kTextViewFontSize] + 20.0;
    return height;
}*/

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
	// Show loading image
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLOADING" object:self];
	
	// Set publication ID based on selected cell and send message to load full reference page
	[self.settings updatePubID:[[self.sections objectAtIndex:indexPath.row] objectForKey:@"pub_id"]];
	
	// Show selected literature reference
	[self performSelector:@selector(showLitReference) withObject:nil afterDelay:0.0];
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
	[litInfo release];
	[sections release];
    [super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings {
	self = [super initWithStyle:UITableViewStylePlain];
	
	self.settings = loadSettings;
	
	return self;
}

// Private functions
int sortLiterature(id obj1, id obj2, void *context) {
	NSDictionary *lit1 = obj1;
	NSDictionary *lit2 = obj2;
	
	// First, sort by year
	NSString *szYear1 = [lit1 objectForKey:@"year"];
	NSString *szYear2 = [lit2 objectForKey:@"year"];
	
	NSComparisonResult sortResult = [szYear1 caseInsensitiveCompare:szYear2];
	
	if (sortResult != NSOrderedSame) {
		return sortResult;
	} else {
		// Last, sort by author
		NSString *szAuthor1 = [lit1 objectForKey:@"author"];
		NSString *szAuthor2 = [lit2 objectForKey:@"author"];
		
		return [szAuthor1 caseInsensitiveCompare:szAuthor2];
	}
}

- (void)showLitReference {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWTAXONLITREFERENCE" object:self];
}

@end
