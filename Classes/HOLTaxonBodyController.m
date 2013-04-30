/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 1 Mar 2010
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

#import "HOLTaxonBodyController.h"

// Private function declarations
@interface HOLTaxonBodyController()
- (void)loadContent;
@end

@implementation HOLTaxonBodyController

@synthesize hierController, contentController;
@synthesize settings;
@synthesize isInLandscape;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
	
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// Load controller view
	CGRect bodyFrame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height - 44.0);
	
	UIView *tempView = [[UIView alloc] initWithFrame:bodyFrame];
	self.view = tempView;
	[tempView release];
	
	// Set view styles
	self.view.backgroundColor = UIColorFromRGB(0xFEF1B5);
	
	// Load controller content, if internet is enabled
	if (self.settings.isInternetEnabled) {
		[self loadContent];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:
							  @"A connection to the server could not be established" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	// Set title text when view is about to be shown
	[self.settings.taxonNaviBar setText:@"Hymenoptera Online" withNaviBar:self.navigationController.navigationBar];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	// Check if hierarchy menu needs shown for orientation
	UIInterfaceOrientation currentOrientation = [UIDevice currentDevice].orientation;
	
	if (currentOrientation == UIInterfaceOrientationPortrait ||
		currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.navigationController setNavigationBarHidden:NO];
		self.hierController.view.hidden = NO;
		
		// If landscape variable is turned on, adjust down
		if (self.isInLandscape) {
			// Shift down content view 32px to acccount for shown hierarchy bar
			CGRect contentFrame = self.contentController.view.frame;
			
			contentFrame.origin.y += 32.0;
			
			self.contentController.view.frame = contentFrame;
			
			self.isInLandscape = NO;
		}
	} else if (currentOrientation == UIInterfaceOrientationLandscapeLeft ||
			   currentOrientation == UIInterfaceOrientationLandscapeRight) {	
		[self.navigationController setNavigationBarHidden:YES];
		self.hierController.view.hidden = YES;
		
		self.isInLandscape = YES;
	}
	
	[super viewWillAppear:animated];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
 */

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
		toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.navigationController setNavigationBarHidden:NO];
		self.hierController.view.hidden = NO;
		
		// Shift down content view 32px to acccount for shown hierarchy bar
		CGRect contentFrame = self.contentController.view.frame;
		
		contentFrame.origin.y += 32.0;
		
		self.contentController.view.frame = contentFrame;
		
		// Turn off the landscape variable
		self.isInLandscape = NO;
	} else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			   toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[self.navigationController setNavigationBarHidden:YES];
		self.hierController.view.hidden = YES;
		
		// Shift up content view 32px to acccount for hidden hierarchy bar
		CGRect contentFrame = self.contentController.view.frame;
		
		contentFrame.origin.y -= 32.0;
		
		self.contentController.view.frame = contentFrame;
		
		// Turn on the landscape variable
		self.isInLandscape = YES;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[hierController release];
	[contentController release];
	[settings release];
	[super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings {
	self = [super init];
	
	self.settings = loadSettings;
	self.isInLandscape = NO;
	
	return self;
}

- (void)loadNewTaxon {
	// Remove previous content views from root view
	[self.hierController.view removeFromSuperview];
	[self.contentController.view removeFromSuperview];
	
	[hierController release], hierController = nil;
	[contentController release], contentController = nil;
	
	// Load new content
	[self loadContent];
}

// Private functions
- (void)loadContent {
	// Load taxon hierarchy bar
	HOLTaxonHierBarController *taxonHierBar = [[HOLTaxonHierBarController alloc] initWithSettings:self.settings];
	HOLTaxonContentController *taxonContentTable = [[HOLTaxonContentController alloc] initWithSettings:self.settings];
	
	self.hierController = taxonHierBar;
	self.contentController = taxonContentTable;
	
	[taxonHierBar release];
	[taxonContentTable release];
	
	// Animate the display of the hierarchy bar
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	
	[self.view addSubview:self.contentController.view];
	[self.view addSubview:self.hierController.view];
	
	// Check if hierarchy menu needs shown for orientation
	UIInterfaceOrientation currentOrientation = [UIDevice currentDevice].orientation;
	
	if (currentOrientation == UIInterfaceOrientationLandscapeLeft ||
		currentOrientation == UIInterfaceOrientationLandscapeRight) {	
		self.hierController.view.hidden = YES;
		
		// Fit content and hierarchy to bounds
		CGRect contentFrame = self.contentController.view.frame;
		CGRect hierFrame = self.hierController.view.frame;
		
		contentFrame.size.width = [UIScreen mainScreen].applicationFrame.size.height;
		hierFrame.size.width = [UIScreen mainScreen].applicationFrame.size.height;
		
		// Shift up content view 12px to acccount for hidden hierarchy bar
		contentFrame.origin.y -= 12.0;
		
		self.contentController.view.frame = contentFrame;
		self.hierController.view.frame = hierFrame;
	} else {
		self.hierController.view.hidden = NO;
	}
	
	[UIView commitAnimations];
}

@end
