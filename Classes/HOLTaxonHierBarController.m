/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 6 Mar 2010
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

#import "HOLTaxonHierBarController.h"

// Private function declarations
@interface HOLTaxonHierBarController()
- (void)loadHierarchy;
- (void)addHierTaxon:(NSString *)taxon;
- (void)adjustHierBarWithWidth:(CGFloat)widthToAdd;
@end


// Controller implementation
@implementation HOLTaxonHierBarController

@synthesize viewScroll, fHierWidth, nHierTaxonPos;
@synthesize settings;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// Empty
    }
	
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// Load controller scroll view with a horizontal scroll only
	CGRect bodyFrame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].applicationFrame.size.width, 35.0);
	CGSize bodySize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.width, 35.0);
	UIScrollView *bodyView = [[UIScrollView alloc] initWithFrame:bodyFrame];
	
	bodyView.bounces = NO;
	
	[bodyView setContentSize:bodySize];
	
	// Set the controller scroll view background color and border
	bodyView.backgroundColor = UIColorFromRGB(0xE9C2A6);
	bodyView.layer.borderWidth = 1.0;
	bodyView.layer.borderColor = [[UIColor blackColor] CGColor];
	
	// Adjust controller scroll view layer so only bottom border is shown
	CGRect layerBounds = bodyView.layer.bounds;
	layerBounds.size.width += 2.0;
	bodyView.layer.bounds = layerBounds;
	
	// Add hierarchy text to the hierarchy bar (and match frame to text width)
	CGRect hierTextFrame = CGRectMake(5.0, 0.0, 0.0, 35.0);
	UILabel *hierText = [[UILabel alloc] initWithFrame:hierTextFrame];
	NSString *textHier = @"Hierarchy: ";
	UIFont* fontHier = [UIFont fontWithName:@"Verdana" size:14.0];
	CGSize hierTextSize = [textHier sizeWithFont:fontHier];
	
	hierText.text = textHier;
	hierText.font = fontHier;
	hierText.backgroundColor = [UIColor clearColor];
	
	hierTextFrame.size.width = hierTextSize.width;	
	hierText.frame = hierTextFrame;
	
	[bodyView addSubview:hierText];
	
	// Set the hierarchy bar width and adjust content area to fit width
	[self adjustHierBarWithWidth:hierTextSize.width];
	
	// Finally, set the controller scroll view
	self.viewScroll = bodyView;
	self.view = bodyView;
	
	// Load the hierarchy for the current taxon
	[self loadHierarchy];
	
	[bodyView release];
	[hierText release];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
	// Check if hierarchy menu needs shown for orientation
	UIInterfaceOrientation currentOrientation = [UIDevice currentDevice].orientation;
	
	if (currentOrientation == UIInterfaceOrientationPortrait ||
		currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		NSLog(@"Portrait");
		
		self.view.hidden = NO;
	} else {
		NSLog(@"Landscape");
		
		self.view.hidden = YES;
	}
	
	[super viewWillAppear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
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
	[settings release];
	[viewScroll release];
    [super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings {
	self = [super init];
	
	self.settings = loadSettings;
	
	// Initialize variables
	self.fHierWidth = 0.0;
	self.nHierTaxonPos = 0;
	
	return self;
}

- (void)newTaxonSelector:(HOLTaxonHierButton *)sender {
	// Show loading image
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLOADING" object:self];
	
	// Set new tnuid
	[self.settings updateTNUID:sender.tnuid];
	
	// Show selected taxon
	[self performSelector:@selector(showNewTaxon) withObject:nil afterDelay:0.0];
}

- (void)showNewTaxon {
	// Send message to load new taxon page
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLLOADNEWTAXON" object:self];
}

// Private functions
- (void)loadHierarchy {
	HOLServerInteraction *server = [[HOLServerInteraction alloc] initWithSettings:self.settings];
	NSDictionary *dictHier = [server getTaxonHierarchy];
	
	// Start with order and add child taxa until the current taxon is reached
	NSString* nextRank = @"Order";
	id hier = [dictHier objectForKey:@"hier"];
	id currentHierTaxon = [hier objectForKey:nextRank];
	
	while (currentHierTaxon != nil) {
		[self addHierTaxon:currentHierTaxon];
		
		nextRank = [currentHierTaxon objectForKey:@"next"];
		currentHierTaxon = [hier objectForKey:nextRank];
	}
	
	[server release];
}

- (void)addHierTaxon:(id)taxon {
	// Add hierarchical separator '>' if necessary
	if (self.nHierTaxonPos > 0) {
		// Add separator text to the hierarchy bar (and match frame to text width)
		CGRect sepTextFrame = CGRectMake(self.fHierWidth, 0.0, 0.0, 35.0);
		UILabel *sepText = [[UILabel alloc] initWithFrame:sepTextFrame];
		NSString *sepHier = @">";
		UIFont* fontSep = [UIFont fontWithName:@"Verdana" size:14.0];
		CGSize sepTextSize = [sepHier sizeWithFont:fontSep];
		
		sepText.text = sepHier;
		sepText.font = fontSep;
		sepText.backgroundColor = [UIColor clearColor];
		
		sepTextFrame.size.width = sepTextSize.width;	
		sepText.frame = sepTextFrame;
		
		[self.viewScroll addSubview:sepText];
		
		// Adjust hierarachy bar width
		[self adjustHierBarWithWidth:sepTextSize.width];
		
		[sepText release];
	}
	
	// Add hierarchy text to the hierarchy bar (and match frame to text width)
	CGRect hierTextFrame = CGRectMake(self.fHierWidth, 0.0, 0.0, 35.0);
	HOLTaxonHierButton *hierText = [[HOLTaxonHierButton alloc] initWithFrame:hierTextFrame];
	NSString *textHier = [taxon objectForKey:@"name"];
	UIFont* fontHier = [UIFont fontWithName:@"Verdana-Bold" size:14.0];
	CGSize hierTextSize = [textHier sizeWithFont:fontHier];
	
	[hierText setTitle:textHier forState:UIControlStateNormal];
	[hierText setTitleColor:UIColorFromRGB(0x934207) forState:UIControlStateNormal];
	hierText.titleLabel.font = fontHier;
	hierText.titleLabel.backgroundColor = [UIColor clearColor];
	hierText.tnuid = [taxon objectForKey:@"id"];
	
	hierTextFrame.size.width = hierTextSize.width;	
	hierText.frame = hierTextFrame;
	
	// Specify click action for taxon
	[hierText addTarget:self action:@selector(newTaxonSelector:) forControlEvents:UIControlEventTouchDown];
	
	[self.viewScroll addSubview:hierText];
	
	// Adjust hierarachy bar width
	[self adjustHierBarWithWidth:hierTextSize.width];
	
	// Increment taxon position within the hierarchy bar
	self.nHierTaxonPos++;
	
	[hierText release];
}

- (void)adjustHierBarWithWidth:(CGFloat)widthToAdd {
	self.fHierWidth += widthToAdd + 5.0;
	
	// Check if width is greater than current content width to adjust content bounds
	if (self.fHierWidth > self.viewScroll.contentSize.width) {
		CGSize bodySize = CGSizeMake(self.fHierWidth, 35.0);
		
		[self.viewScroll setContentSize:bodySize];
	}
}

@end
