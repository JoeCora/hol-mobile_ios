/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 17 May 2010
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

#import "HOLNaviBarViewController.h"

@implementation HOLNaviBarViewController

@synthesize naviLabel;
@synthesize naviLogo;
@synthesize naviGradient;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
	// Set the background to a gradient
	self.naviGradient = [CAGradientLayer layer];
	self.naviGradient.frame = self.view.bounds;
	self.naviGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1.0 alpha:0.4] CGColor],
					   (id)[[UIColor colorWithWhite:0.8 alpha:0.3] CGColor], nil];
	[self.view.layer insertSublayer:self.naviGradient atIndex:0];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.naviLabel = nil;
}

- (void)dealloc {
	[naviLabel release];
    [naviLogo release];
    [super dealloc];
}

// Public functions
- (id)initWithiPad:(BOOL)isiPadDevice {
	// Load nib depending on device
	if (isiPadDevice) {
		self = [super initWithNibName:@"HOLNaviBar-iPad" bundle:[NSBundle mainBundle]];
	} else {
		self = [super initWithNibName:@"HOLNaviBar" bundle:[NSBundle mainBundle]];
	}
	
	return self;
}

- (void)setText:(NSString *)labelText {
	self.naviLabel.text = labelText;
    
    // Reset status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)setText:(NSString *)labelText withNaviBar:(UINavigationBar *)naviBar {
    // Reset navigation bar color
	naviBar.tintColor = UIColorFromRGB(0xCDCDC1); // For proper button colors
    
    // Toggle the logo depending on whether its a main page (i.e. Hymenoptera Online) or subsequent page
    if ([labelText isEqualToString:@"Hymenoptera Online"]) {
        self.naviLogo.hidden = NO;
    } else {
        self.naviLogo.hidden = YES;
    }
    
    // Set the navigation text
    [self setText:labelText];
}

@end
