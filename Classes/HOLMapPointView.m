/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 17 Aug 2010
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

#import "HOLMapPointView.h"

@implementation HOLMapPointView

@synthesize settings;
@synthesize filter;
@synthesize clickable;
@synthesize didTouch;

- (void)dealloc {
	[settings release];
	[filter release];
    [super dealloc];
}

// Touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.clickable) {
		// Create icon filter if necessary
		if (self.filter == nil) {
			self.filter = [CALayer layer];
			self.filter.frame = self.bounds;
			self.filter.backgroundColor = [UIColor blackColor].CGColor;
			self.filter.opacity = 0.5;
			self.filter.cornerRadius = 8.0;
		}
		
		// Add icon filter
		[self.layer insertSublayer:self.filter atIndex:0];
		
		self.didTouch = YES;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	// Remove icon filter
	[self.filter removeFromSuperlayer];
	
	self.didTouch = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.didTouch) {
		// Show loading image
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLOADING" object:self];
		
		// Set located ID based on selected point and send message to load full locality info page
		HOLMapPoint *mapAnno = (HOLMapPoint *)self.annotation;
		
		[self.settings updateLocID:mapAnno.locID];
		
		// Show selected locality information
		[self performSelector:@selector(showLocInfo) withObject:nil afterDelay:0.0];
		
		// Remove icon filter
		[self.filter removeFromSuperlayer];
		
		self.didTouch = NO;
	}
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings annotation:(id <MKAnnotation>)annotation ptType:(HOLMAPPOINTTYPE)ptType reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	
	self.settings = loadSettings;
	
	// Initialize variables
	self.enabled = YES;
	self.draggable = NO;
	self.clickable = YES;
	self.didTouch = NO;
	
	switch (ptType) {
		case HOLMAPPOINT: {
			UIImage *ptImage = [UIImage imageNamed:@"pt_icon_17x17.png"];
			
			self.image = ptImage;
			
			break;
		}
		case HOLMAPPOLYGON: {
			UIImage *ptImage = [UIImage imageNamed:@"poly_icon_17x17.png"];
			
			self.image = ptImage;
			
			break;
		}
		case HOLMAPPOINT_UNVOUCHERED: {
			UIImage *ptImage = [UIImage imageNamed:@"pt_unv_icon_17x17.png"];
			
			self.image = ptImage;
			
			break;
		}
		case HOLMAPPOLYGON_UNVOUCHERED: {
			UIImage *ptImage = [UIImage imageNamed:@"poly_unv_icon_17x17.png"];
			
			self.image = ptImage;
			
			break;
		}
		case HOLMAPLOCATION: {
			UIImage *ptImage = [UIImage imageNamed:@"location-icon.png"];
			
			self.image = ptImage;
			
			break;
		}
	}
	
	return self;
}

- (void)showLocInfo {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLSHOWLOCINFO" object:self];
}

@end
