/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 21 May 2010
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

#import "HOLLitReferenceController.h"

@implementation HOLLitReferenceController

@synthesize generalInfo, sections, nNumRows;
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
	self.tableView.rowHeight = 65.0;
	
	// Get the general information for taxon from server
	HOLServerInteraction *server = [[HOLServerInteraction alloc] initWithSettings:self.settings];
	NSDictionary *dictInfo = [server getLitReference];
	
	[server release];
	
	// Check if results were available (internet enabled)
	if (dictInfo != nil) {
		self.generalInfo = [dictInfo objectForKey:@"pub_ref"];
		
		// Check which sections to show
		NSMutableArray *sectionsShow = [[NSMutableArray alloc] initWithCapacity:9];
		
		// Check for publication type specific sections
		NSString *szPubType = [self.generalInfo objectForKey:@"type"];
		
		if ([szPubType isEqualToString:@"book"]) {
			[sectionsShow addObject:@"author"];
			[sectionsShow addObject:@"year"];
			[sectionsShow addObject:@"title"];
			
			[sectionsShow addObject:@"publisher"];
			[sectionsShow addObject:@"city"];
			[sectionsShow addObject:@"num_pages"];
		} else if ([szPubType isEqualToString:@"article"]) {
			[sectionsShow addObject:@"author"];
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
			
			[sectionsShow addObject:@"pages"];
		} else if ([szPubType isEqualToString:@"bulletin"]) {
			[sectionsShow addObject:@"author"];
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
			
			[sectionsShow addObject:@"pages"];
		} else if ([szPubType isEqualToString:@"chapter"]) {
			[sectionsShow addObject:@"chap_author"];
			[sectionsShow addObject:@"year"];
			[sectionsShow addObject:@"chap_title"];
			
			// Check if chapter number is defined
			if ([[self.generalInfo objectForKey:@"chap_num"] length] > 0) {
				[sectionsShow addObject:@"chap_num"];
			}
			
			[sectionsShow addObject:@"pages"];
			[sectionsShow addObject:@"book_info"];
		}
		
		// Check if full PDF is specified
		NSString *szPDFURL = [self.generalInfo objectForKey:@"url"];
		
		if ([szPDFURL length] > 0 && [[self.generalInfo objectForKey:@"public"] isEqualToString:@"Y"]) {
			[sectionsShow addObject:@"pdf_info"];
			
			// Check if pub PDF is already in library
			if ([self.settings isPubInLibrary:[[self.generalInfo valueForKey:@"pub_id"] intValue]] == -1) {
				[sectionsShow addObject:@"pdf_add"];
			}
		}
		
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
	[self.settings.taxonNaviBar setText:@"Extended Reference" withNaviBar:self.navigationController.navigationBar];
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
	NSString *sectionName = [self.sections objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellPDFIdentifier = @"PDFCell";
	
    // Reuse cell for regular and PDF cell if available
	HOLCell *cell;
	
	if ([sectionName isEqualToString:@"pdf_info"] || [sectionName isEqualToString:@"pdf_add"]) {
		cell = (HOLCell *)[tableView dequeueReusableCellWithIdentifier:CellPDFIdentifier];
	} else {
		cell = (HOLCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	}
	
    if (cell == nil) {
		if ([sectionName isEqualToString:@"pdf_info"] || [sectionName isEqualToString:@"pdf_add"]) {
			cell = [[[HOLCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellPDFIdentifier] autorelease];
		} else {
			cell = (HOLCell *)[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
    }
    
    // Configure the cell based on its position within the sections array
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.textLabel.numberOfLines = 2;
	
	// Check the type of data needs displayed
	if ([sectionName isEqualToString:@"num_pages"]) {
		cell.detailTextLabel.text = @"Pages";
		cell.textLabel.text = [self.generalInfo objectForKey:sectionName];
	} else if ([sectionName isEqualToString:@"vol_num"]) {
		cell.detailTextLabel.text = @"Part";
		cell.textLabel.text = [self.generalInfo objectForKey:sectionName];
	} else if ([sectionName isEqualToString:@"pages"]) {
		cell.detailTextLabel.text = @"Page(s)";
		
		// Format the pages
		NSString *szPages = [self.generalInfo objectForKey:@"start_page"];
		
		if ([[self.generalInfo objectForKey:@"end_page"] length] > 0) {
			szPages = [NSString stringWithFormat:@"%@-%@", szPages, [self.generalInfo objectForKey:@"end_page"]];
		}
		
		cell.textLabel.text = szPages;
	} else if ([sectionName isEqualToString:@"chap_author"]) {
		cell.detailTextLabel.text = @"Author";
		cell.textLabel.text = [self.generalInfo objectForKey:sectionName];
	} else if ([sectionName isEqualToString:@"chap_title"]) {
		cell.detailTextLabel.text = @"Title";
		cell.textLabel.text = [self.generalInfo objectForKey:sectionName];
	} else if ([sectionName isEqualToString:@"chap_num"]) {
		cell.detailTextLabel.text = @"Chapter #";
		cell.textLabel.text = [self.generalInfo objectForKey:sectionName];
	} else if ([sectionName isEqualToString:@"book_info"]) {
		cell.detailTextLabel.text = @"Book";
		
		// Format the book reference
		NSString *szBookInfo = [NSString stringWithFormat:@"%@. %@. %@, %@. %@ pp.",
								[self.generalInfo objectForKey:@"author"], [self.generalInfo objectForKey:@"title"],
								[self.generalInfo objectForKey:@"publisher"], [self.generalInfo objectForKey:@"city"],
								[self.generalInfo objectForKey:@"num_pages"]];
		
		cell.textLabel.text = szBookInfo;
	} else if ([sectionName isEqualToString:@"pdf_info"]) {
		// Format the cell
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[cell showPDFIcon];
		
		cell.detailTextLabel.text = @"Full PDF";
		
		// Format the pdf info
		NSString *szPDFInfo = [NSString stringWithFormat:@"view PDF (%@)",
								[self.generalInfo objectForKey:@"filesize"]];
		
		cell.textLabel.text = szPDFInfo;
	} else if ([sectionName isEqualToString:@"pdf_add"]) {
		// Format the cell
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[cell showPDFIcon];
		
		cell.detailTextLabel.text = @"Save PDF";
		
		// Format the add pdf to library info
		NSString *szPDFInfo = [NSString stringWithFormat:@"add PDF to library (%@)",
								[self.generalInfo objectForKey:@"filesize"]];
		
		cell.textLabel.text = szPDFInfo;
	} else {
		// Format the information for the current cell (basic)
		cell.detailTextLabel.text = [sectionName capitalizedString];
		cell.textLabel.text = [self.generalInfo objectForKey:sectionName];
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
	// Check if selected cell is a PDF cell
	NSString *sectionName = [self.sections objectAtIndex:indexPath.row];
	
	if ([sectionName isEqualToString:@"pdf_info"]) {
		// Show loading image
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLOADING" object:self];
		
		// Set PDF URL based on selected cell and send message to load PDF
		[self.settings updatePDFURL:[self.generalInfo objectForKey:@"url"] isLocal:NO];
		
		// Show selected PDF
		[self performSelector:@selector(showPDF) withObject:nil afterDelay:0.0];
	} else if ([sectionName isEqualToString:@"pdf_add"]) {
		// Check if PDF download is possible
		if ([self.settings isDocDownloadAvailable]) {
			// Add publication info to library list and add PDF to library
			[self.settings addToLibrary:self.generalInfo];
			
			// Remove add PDFs row from display
			NSMutableArray *tempSections = [self.sections mutableCopy];
			
			[tempSections removeObjectAtIndex:indexPath.row];			
			[sections release], sections = nil;
			
			self.sections = tempSections;
			self.nNumRows--;
			
			[tempSections release];
			
			[tableView reloadData];
			
			// Send message to update library
			[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLUPDATELIBRARY" object:self];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Library Addition Error" message:@"PDF cannot be added to library!\n\nAnother document is already being downloaded. Please wait until the current download completes." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release]; 
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


- (void)dealloc {
	[settings release];
	[generalInfo release];
	[sections release];
    [super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings {
	self = [super initWithStyle:UITableViewStylePlain];
	
	self.settings = loadSettings;
	
	return self;
}

- (void)showPDF {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLITVIEWER" object:self];
}

@end

