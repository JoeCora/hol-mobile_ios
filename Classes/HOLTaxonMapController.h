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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HOLMapPoint.h"
#import "HOLMapPointView.h"
#import "HOLTaxonMapSettings.h"
#import "HOLServerInteraction.h"
#import "HOLSettings.h"

@interface HOLTaxonMapController : UIViewController <MKMapViewDelegate, HOLTaxonMapSettingsDelegate> {
	HOLSettings *settings;
	MKMapView *mapView;
	NSArray *arrayPlaces;
	BOOL bNeedsUpdated;
	BOOL bShowAllSpecimens;
	MKMapType currentMapType;
}

@property (nonatomic, retain) HOLSettings *settings;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSArray *arrayPlaces;
@property (nonatomic, readwrite) BOOL bNeedsUpdated;
@property (nonatomic, readwrite) BOOL bShowAllSpecimens;
@property (nonatomic, readwrite) MKMapType currentMapType;

// Public function declarations
- (id)initWithSettings:(HOLSettings *)loadSettings;
- (void)showSettings;

@end
