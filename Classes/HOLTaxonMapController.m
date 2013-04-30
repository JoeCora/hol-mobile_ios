/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 13 Mar 2010
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

#import "HOLTaxonMapController.h"

// Private function declarations
@interface HOLTaxonMapController()
- (void)loadSettingsButton;
- (void)loadMap;
@end

@implementation HOLTaxonMapController

@synthesize mapView;
@synthesize arrayPlaces;
@synthesize settings;
@synthesize bNeedsUpdated;
@synthesize bShowAllSpecimens;
@synthesize currentMapType;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// Load the distribution map
	CGRect bodyFrame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height - 44.0);
	MKMapView *tempMapView = [[MKMapView alloc] initWithFrame:bodyFrame];
	self.mapView = tempMapView;
	
	[tempMapView release];
	
	self.mapView.delegate = self;
	
	// Set the map as the view
	self.view = self.mapView;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
	// Enable landscape orientation
	[self.settings disablePortraitLock];
	
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
	
	// Reload map is update is needed
	if (self.bNeedsUpdated) {
		[self loadMap];
		
		self.bNeedsUpdated = NO;
	}
	
	// Set title text when view is about to be shown
	[self.settings.taxonNaviBar setText:@"Map" withNaviBar:self.navigationController.navigationBar];
	
	// Load settings button
	[self loadSettingsButton];
	
	[super viewWillAppear:animated];
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
}


- (void)dealloc {
	[settings release];
	[mapView release];
	[arrayPlaces release];
    [super dealloc];
}

// Map specific functions
- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation {
	HOLMapPoint *mapAnn = (HOLMapPoint *)annotation;
	HOLMapPointView *annView;
	
	// Check if point or polygon
	if (mapAnn.pointType == HOLMAPPOINT) {
		static NSString *annIdentifier = @"distPoint";
		
		annView = (HOLMapPointView*)[theMapView dequeueReusableAnnotationViewWithIdentifier:annIdentifier];
		
		if (annView == nil) {
			annView = [[[HOLMapPointView alloc] initWithSettings:self.settings annotation:annotation ptType:HOLMAPPOINT
												 reuseIdentifier:annIdentifier] autorelease];
		}
	} else if (mapAnn.pointType == HOLMAPPOLYGON) {
		static NSString *annIdentifier = @"distPoly";
		
		annView = (HOLMapPointView*)[theMapView dequeueReusableAnnotationViewWithIdentifier:annIdentifier];
		
		if (annView == nil) {
			annView = [[[HOLMapPointView alloc] initWithSettings:self.settings annotation:annotation ptType:HOLMAPPOLYGON
												 reuseIdentifier:annIdentifier] autorelease];
		}
	} else if (mapAnn.pointType == HOLMAPPOINT_UNVOUCHERED) {
		static NSString *annIdentifier = @"distPointUnv";
		
		annView = (HOLMapPointView*)[theMapView dequeueReusableAnnotationViewWithIdentifier:annIdentifier];
		
		if (annView == nil) {
			annView = [[[HOLMapPointView alloc] initWithSettings:self.settings annotation:annotation ptType:HOLMAPPOINT_UNVOUCHERED
												 reuseIdentifier:annIdentifier] autorelease];
		}
	} else {
        // HOLMAPPOLYGON_UNVOUCHERED
		static NSString *annIdentifier = @"distPolyUnv";
		
		annView = (HOLMapPointView*)[theMapView dequeueReusableAnnotationViewWithIdentifier:annIdentifier];
		
		if (annView == nil) {
			annView = [[[HOLMapPointView alloc] initWithSettings:self.settings annotation:annotation ptType:HOLMAPPOLYGON_UNVOUCHERED
												 reuseIdentifier:annIdentifier] autorelease];
		}
	}
	
	return annView;
}

// Settings-specific functions
- (void)updateTitleText:(NSString *)titleText {
	[self.settings.taxonNaviBar setText:titleText withNaviBar:self.navigationController.navigationBar];
}

- (BOOL)showAllSpecimens {
	return self.bShowAllSpecimens;
}

- (MKMapType)getMapType {
	return self.currentMapType;
}

- (void)toggleAllSpecimens {
	self.bNeedsUpdated = YES;
	
	self.bShowAllSpecimens = !self.bShowAllSpecimens;
}

- (void)switchMapType:(MKMapType)mapType {
	self.bNeedsUpdated = YES;
	
	self.currentMapType = mapType;
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings {
	self = [super init];
	
	// Initialize variables
	self.bNeedsUpdated = YES;
	self.settings = loadSettings;
	self.bShowAllSpecimens = NO;
	self.currentMapType = MKMapTypeStandard;
	
	return self;
}

- (void)showSettings {
	HOLTaxonMapSettings *tempSettings = [[HOLTaxonMapSettings alloc] initWithiPad:self.settings.isiPad];
	
	tempSettings.delegate = self;
	
	[self.navigationController pushViewController:tempSettings animated:YES];
	
	[tempSettings release];
}

// Private functions
- (void)loadSettingsButton {
	// Show settings option
	UIBarButtonItem *tempSettingsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																						target:self action:@selector(showSettings)];
	//[self.navigationItem setRightBarButtonItem:tempSettingsButton];
	self.navigationItem.rightBarButtonItem = tempSettingsButton;
	[tempSettingsButton release];
}

- (void)loadMap {
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	
	span.latitudeDelta = 150.0;
	span.longitudeDelta = 150.0;
	
	CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
	
	location.latitude = 0.0;
	location.longitude = 0.0;
	region.span = span;
	region.center = location;
	
	self.mapView.mapType = self.currentMapType;
	
	[self.mapView setRegion:region animated:TRUE];
	[self.mapView regionThatFits:region];
	
	// Add the distribution points to the map
	HOLServerInteraction *server = [[HOLServerInteraction alloc] initWithSettings:self.settings];
	NSDictionary *dictInfo = [server getLocalities:self.bShowAllSpecimens];
	
	[server release];
	
	// Unload previous annotations
	[self.mapView removeAnnotations:self.arrayPlaces];
	
	[arrayPlaces release], arrayPlaces = nil;
	
	// Check if results were available (internet enabled)
	if (dictInfo != nil) {
		NSArray *arrayLocs = [dictInfo objectForKey:@"localities"];
		
		NSMutableArray *tempArrayPlaces = [[NSMutableArray alloc] initWithCapacity:[arrayLocs count]];
		HOLMapPoint *placemark;
		HOLMAPPOINTTYPE ptType;
		
		for (NSDictionary *dictLoc in arrayLocs) {
			location.latitude = [[dictLoc objectForKey:@"lat"] floatValue];
			location.longitude = [[dictLoc objectForKey:@"long"] floatValue];
			
			// Check if point or polygon
			if ([[dictLoc objectForKey:@"type"] isEqualToString:@"point"]) {
                // Check if point is vouchered or unvouchered
                if ([[dictLoc objectForKey:@"source"] isEqualToString:@"vouchered"]) {
                    ptType = HOLMAPPOINT;
                } else {
                    ptType = HOLMAPPOINT_UNVOUCHERED;
                }
			} else {
                // Check if polygon is vouchered or unvouchered
                if ([[dictLoc objectForKey:@"source"] isEqualToString:@"vouchered"]) {
                    ptType = HOLMAPPOLYGON;
                } else {
                    ptType = HOLMAPPOLYGON_UNVOUCHERED;
                }
			}
			
			placemark = [[HOLMapPoint alloc] initWithCoordinates:location ptType:ptType];
			
			placemark.locID = [dictLoc objectForKey:@"id"];
			
			[tempArrayPlaces addObject:placemark];
			
			[placemark release];
		}
		
		[self.mapView addAnnotations:tempArrayPlaces];
		
		self.arrayPlaces = tempArrayPlaces;
		
		[tempArrayPlaces release];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Server communication error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release]; 
	}
}

@end
