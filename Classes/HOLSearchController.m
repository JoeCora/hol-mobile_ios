/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 30 Mar 2010
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

#import "HOLSearchController.h"

// Private function declarations
@interface HOLSearchController()
- (void)cancelSearch;
@end

@implementation HOLSearchController

@synthesize searchBar;
@synthesize arrayTaxonResults;
@synthesize settings;

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Load controller content, if internet is enabled
	if (self.settings.isInternetEnabled) {
		// Add the search bar
		self.searchBar.frame = CGRectMake(0.0, 44.0, self.searchBar.frame.size.width, self.searchBar.frame.size.height);
		self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
		
		self.tableView.tableHeaderView = self.searchBar;
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:
							  @"A connection to the server could not be established" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
	[self.settings.searchNaviBar setText:@"Hymenoptera Online" withNaviBar:self.navigationController.navigationBar];
}

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
#pragma mark Search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	self.tableView.scrollEnabled = NO;
	
	// Show the cancel button
	[self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[self searchTableView];
	
	[self cancelSearch];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
	[self cancelSearch];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Number of rows it should expect should be based on the section
	return [self.arrayTaxonResults count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Taxon Search Results";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
	}
	
	// Get the cell value
	NSDictionary *dictResult = [self.arrayTaxonResults objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [dictResult objectForKey:@"name"], [dictResult objectForKey:@"author"]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Rank: %@, Validity: %@", [dictResult objectForKey:@"rank"], [dictResult objectForKey:@"valid"]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	HOLCell *cell = (HOLCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSArray *cellArray = [[NSArray alloc] initWithObjects:indexPath, nil];
	
	[tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationNone];
	
	return indexPath;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Show loading image
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLOADING" object:self];
	
	// Set new tnuid
	[self.settings updateTNUID:[[self.arrayTaxonResults objectAtIndex:indexPath.row] objectForKey:@"id"]];
	
	// Show selected taxon
	[self performSelector:@selector(showNewTaxon) withObject:nil afterDelay:0.0];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.searchBar = nil;
}

- (void)dealloc {
	[settings release];
	[arrayTaxonResults release];
	[searchBar release];
    [super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings {
	self = [super initWithNibName:@"HOLSearch" bundle:[NSBundle mainBundle]];
	
	self.settings = loadSettings;
	
	return self;
}

- (void)searchTableView {
	NSString *searchText = self.searchBar.text;
	
	if ([searchText length] > 2) {
		// Get the general information for taxon from server
		HOLServerInteraction *server = [[HOLServerInteraction alloc] initWithSettings:self.settings];
		NSDictionary *dictInfo = [server getSearchResultsFromString:searchText];
		
		[server release];
		
		// Check if results were available (internet enabled)
		if (dictInfo != nil) {
			self.arrayTaxonResults = [[dictInfo objectForKey:@"taxon_results"] objectForKey:@"taxa"];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Server communication error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release]; 
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Search must be at least 3 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release]; 
	}
}

// Private functions
- (void)cancelSearch {
	[self.searchBar resignFirstResponder];
	
	self.tableView.scrollEnabled = YES;
	
	// Hide the cancel button
	[self.searchBar setShowsCancelButton:NO animated:YES];
	
	[self.tableView reloadData];
}

- (void)showNewTaxon {
	// Send message to load new taxon page
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLLOADNEWTAXON" object:self];
}

@end
