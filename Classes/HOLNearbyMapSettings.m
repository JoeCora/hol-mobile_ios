/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 24 Aug 2010
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

#import "HOLNearbyMapSettings.h"

@implementation HOLNearbyMapSettings

@synthesize delegate;
@synthesize distanceSlider;
@synthesize distanceLabel;
@synthesize mapTypeSwitcher;

- (void)viewWillAppear:(BOOL)animated {
	// Set title text when view is about to be shown
	[delegate updateTitleText:@"Nearby Settings"];
	
	// Update distance value within settings
	self.distanceSlider.value = [delegate getDistance];
	self.distanceLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)self.distanceSlider.value];
	self.mapTypeSwitcher.selectedSegmentIndex = [delegate getMapType];
	
	// Check for orientation change in another tab
	UIInterfaceOrientation currentOrientation = [UIDevice currentDevice].orientation;
	
	if (currentOrientation == UIInterfaceOrientationPortrait ||
		currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.navigationController setNavigationBarHidden:NO];
	} else if (currentOrientation == UIInterfaceOrientationLandscapeLeft ||
			   currentOrientation == UIInterfaceOrientationLandscapeRight) {	
		[self.navigationController setNavigationBarHidden:YES];
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
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.navigationController setNavigationBarHidden:NO];
	} else {
		[self.navigationController setNavigationBarHidden:YES];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.distanceSlider = nil;
	self.distanceLabel = nil;
	self.mapTypeSwitcher = nil;
}

- (void)dealloc {
	[super dealloc];
}

// Public functions
- (id)initWithiPad:(BOOL)isiPad {
	if (isiPad) {
		self = [super initWithNibName:@"HOLNearbyMapSettings-iPad" bundle:[NSBundle mainBundle]];
	} else {
		self = [super initWithNibName:@"HOLNearbyMapSettings" bundle:[NSBundle mainBundle]];
	}
	
	return self;
}

- (IBAction)setNewDistance {
	self.distanceLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)self.distanceSlider.value];
	
	[delegate updateDistance:(NSInteger)self.distanceSlider.value];
}

- (IBAction)switchMapType {
	[delegate switchMapType:(MKMapType)self.mapTypeSwitcher.selectedSegmentIndex];
}

@end
