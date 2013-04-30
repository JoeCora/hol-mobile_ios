/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 25 May 2010
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

#import "HOLPDFViewController.h"

@implementation HOLPDFViewController

@synthesize settings;
@synthesize pdfView;
@synthesize loadingView;
@synthesize loadingTimer;
@synthesize sectionType;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Load PDF into PDF view from the PDF URL
	[self.pdfView loadRequest:[NSURLRequest requestWithURL:[self.settings getPDFURL]]];
	
	// Show loading in center of view
	CGRect loadingFrame = self.loadingView.frame;
	
	loadingFrame.origin.x = [UIScreen mainScreen].applicationFrame.size.width / 2 - 22.0;
	loadingFrame.origin.y = [UIScreen mainScreen].applicationFrame.size.height / 2 - 66.0;
	
	self.loadingView.frame = loadingFrame;
	
	[self.view addSubview:self.loadingView];
	
	[self.loadingView startAnimating];
	
	// Set timer to check when PDF is finished loading
	self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
													 target:self selector:@selector(stopWhenPDFLoaded)
													   userInfo:nil repeats:YES];
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
		[self.settings.taxonNaviBar setText:@"Literature Viewer" withNaviBar:self.navigationController.navigationBar];
	} else {
		[self.settings.libraryNaviBar setText:@"Literature Viewer" withNaviBar:self.navigationController.navigationBar];
	}
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.pdfView = nil;
}

- (void)dealloc {
	[settings release];
	[pdfView release];
	[loadingView release];
	[loadingTimer release];
	[super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings section:(HOLTABCONTROLLERTYPE)tabSection {
	self = [super initWithNibName:@"HOLPDF" bundle:[NSBundle mainBundle]];
	
	self.settings = loadSettings;
	sectionType = tabSection;
	
	// Initialize loading indicator
	UIActivityIndicatorView *tempLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.loadingView = tempLoadingView;
	[tempLoadingView release];
	
	return self;
}

- (void)stopWhenPDFLoaded {
	// Remove loading image when PDF finishes loading
	if (!self.pdfView.loading) {
		[self.loadingView removeFromSuperview];
		[self.loadingView stopAnimating];
		
		[self.loadingTimer invalidate];
	}
}

@end
