/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 26 May 2010
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

#import "HOLLibraryController.h"

// Private function declarations
@interface HOLLibraryController()
- (void)loadEditButton;
@end

@implementation HOLLibraryController

@synthesize nNumRows;
@synthesize settings;
@synthesize bIsEditing;

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
	
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
	
	// Set table view styles
	self.tableView.backgroundColor = UIColorFromRGB(0xFEF1B5);
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.rowHeight = 80.0;
	
	// Check number of PDFs
	self.nNumRows = [self.settings.libraryList count];
	
	// Check for notifications for library
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLibrary) name:@"HOLUPDATELIBRARY" object:nil];
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
	
	// Show edit button
	[self loadEditButton];
	
	// Set title text when view is about to be shown
	[self.settings.libraryNaviBar setText:@"Hymenoptera Online" withNaviBar:self.navigationController.navigationBar];
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
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.textLabel.numberOfLines = 2;
	cell.detailTextLabel.numberOfLines = 2;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[cell showPDFIcon];
	
	// Check for publication type specific sections
	NSDictionary *dictPub = [self.settings.libraryList objectAtIndex:indexPath.row];
	NSString *szPubType = [dictPub objectForKey:@"type"];
	
	if ([szPubType isEqualToString:@"book"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [dictPub objectForKey:@"author"],
							   [dictPub objectForKey:@"year"]];
		
		cell.detailTextLabel.text = [dictPub objectForKey:@"title"];
		
		//[sectionsShow addObject:@"publisher"];
		//[sectionsShow addObject:@"city"];
		//[sectionsShow addObject:@"num_pages"];
	} else if ([szPubType isEqualToString:@"article"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [dictPub objectForKey:@"author"],
							   [dictPub objectForKey:@"year"]];
		
		cell.detailTextLabel.text = [dictPub objectForKey:@"title"];
		
		/*[sectionsShow addObject:@"journal"];
		
		// Check if series is defined
		if ([[self.generalInfo objectForKey:@"series"] length] > 0) {
			[sectionsShow addObject:@"series"];
		}
		
		// Check if volume is defined
		if ([[self.generalInfo objectForKey:@"volume"] length] > 0) {
			[sectionsShow addObject:@"volume"];
		}
		
		// Check if volume part is defined
		if ([[self.generalInfo objectForKey:@"vol_num"] length] > 0) {
			[sectionsShow addObject:@"vol_num"];
		}
		
		[sectionsShow addObject:@"pages"];*/
	} else if ([szPubType isEqualToString:@"bulletin"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [dictPub objectForKey:@"author"],
							   [dictPub objectForKey:@"year"]];
		
		cell.detailTextLabel.text = [dictPub objectForKey:@"title"];
		
		/*[sectionsShow addObject:@"author"];
		[sectionsShow addObject:@"year"];
		[sectionsShow addObject:@"title"];
		
		[sectionsShow addObject:@"journal"];
		
		// Check if series is defined
		if ([[self.generalInfo objectForKey:@"series"] length] > 0) {
			[sectionsShow addObject:@"series"];
		}
		
		// Check if volume is defined
		if ([[self.generalInfo objectForKey:@"volume"] length] > 0) {
			[sectionsShow addObject:@"volume"];
		}
		
		// Check if volume part is defined
		if ([[self.generalInfo objectForKey:@"vol_num"] length] > 0) {
			[sectionsShow addObject:@"vol_num"];
		}
		
		[sectionsShow addObject:@"pages"];*/
	} else if ([szPubType isEqualToString:@"chapter"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [dictPub objectForKey:@"chap_author"],
							   [dictPub objectForKey:@"year"]];
		
		cell.detailTextLabel.text = [dictPub objectForKey:@"chap_title"];
		/*
		// Check if chapter number is defined
		if ([[self.generalInfo objectForKey:@"chap_num"] length] > 0) {
			[sectionsShow addObject:@"chap_num"];
		}
		
		[sectionsShow addObject:@"pages"];
		[sectionsShow addObject:@"book_info"];*/
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		self.nNumRows--;
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		[self.settings removeFromLibrary:indexPath.row];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}   
}


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
	NSDictionary *dictPub = [self.settings.libraryList objectAtIndex:indexPath.row];
	
	// Check if PDF has been downloaded
	if ([[dictPub objectForKey:@"downloaded"] isEqualToString:@"Y"]) {
		// Show loading image
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLOADING" object:self];
		
		// Set PDF URL based on selected cell and send message to load PDF
		[self.settings updatePDFURL:[self.settings getFilenameFromURL:[dictPub objectForKey:@"url"]] isLocal:YES];
		
		// Show selected PDF
		[self performSelector:@selector(showPDF) withObject:nil afterDelay:0.0];
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
	self = [super initWithStyle:UITableViewStylePlain];
	
	self.settings = loadSettings;
	self.bIsEditing = NO;
	
	return self;
}

- (void)updateLibrary {
	// Check number of PDFs
	self.nNumRows = [self.settings.libraryList count];
	
	// Reload the table
	[self.tableView reloadData];
}

- (void)toggleLibraryEditing {
	// Toggle between editing and selection mode, and change button to reflect current states
	UIBarButtonSystemItem currentSystemItem;
	
	if (self.bIsEditing) {
		currentSystemItem = UIBarButtonSystemItemEdit;
		
		[self.tableView setEditing:NO animated:YES];
	} else {
		currentSystemItem = UIBarButtonSystemItemDone;
		
		[self.tableView setEditing:YES animated:YES];
	}
	
	// Update the right button
	UIBarButtonItem *tempEditButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:currentSystemItem
																					target:self
																					action:@selector(toggleLibraryEditing)];
	[self.navigationItem setRightBarButtonItem:tempEditButton];
	[tempEditButton release];
	
	self.bIsEditing = !self.bIsEditing;
}

- (void)showPDF {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLITVIEWER" object:self];
}

// Private functions
- (void)loadEditButton {
	UIBarButtonItem *tempEditButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																					target:self
																					action:@selector(toggleLibraryEditing)];
	[self.navigationItem setRightBarButtonItem:tempEditButton];
	[tempEditButton release];
}

@end

