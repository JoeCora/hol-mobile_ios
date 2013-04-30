/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 13 Aug 2010
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
#import <CoreLocation/CoreLocation.h>
#import "HOLTaxonMapSettings.h"
#import "HOLServerInteraction.h"
#import "HOLSettings.h"

@interface HOLMapInfoController : UITableViewController <CLLocationManagerDelegate> {
	id<HOLTaxonMapSettingsDelegate> delegate;
	HOLSettings *settings;
	NSDictionary *locInfo;
	NSArray *locCuids;
	NSArray *sections;
	CLLocationManager *locationManager;
	CLLocationCoordinate2D currentLocation;
	NSInteger nNumRows;
	HOLTABCONTROLLERTYPE sectionType;
}

@property (assign) id<HOLTaxonMapSettingsDelegate> delegate;
@property (nonatomic, retain) HOLSettings *settings;
@property (nonatomic, retain) NSDictionary *locInfo;
@property (nonatomic, retain) NSArray *locCuids;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) NSInteger nNumRows;
@property (nonatomic, readonly) HOLTABCONTROLLERTYPE sectionType;

// Public function declarations
- (id)initWithSettings:(HOLSettings *)loadSettings section:(HOLTABCONTROLLERTYPE)tabSection;

@end
