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

#import "HOLServerInteraction.h"

// Private function declarations
@interface HOLServerInteraction()
- (NSString *)getURL:(NSString *)url;
- (NSDictionary *)convertJSONtoDictionary:(NSString *)jsonString;
@end


// Interaction implementation
@implementation HOLServerInteraction

@synthesize settings;
@synthesize nMaxAttempts;
@synthesize nNumAttempts;

- (void)dealloc {
	[settings release];
    [super dealloc];
}

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings {
	self = [super init];
	
	self.settings = loadSettings;
    
    // Setup network attempts
    nMaxAttempts = 5;
    self.nNumAttempts = 0;
	
	return self;
}

- (NSDictionary *)getSearchResultsFromString:(NSString *)searchString {
	NSString *url = [NSString stringWithFormat:@"%@getSearchResults?name=%@%%&limit=50&callback=", HOL_BASE_URL, searchString];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getTaxonStats {
	NSString *url = [NSString stringWithFormat:@"%@getTaxonStats?tnuid=%@&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getTaxonHierarchy {
	NSString *url = [NSString stringWithFormat:@"%@getTaxonHierarchy?tnuid=%@&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getTaxonInfo {
	NSString *url = [NSString stringWithFormat:@"%@getTaxonInfo?tnuid=%@&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getIncludedTaxa {
	NSString *url = [NSString stringWithFormat:@"%@getIncludedTaxa?tnuid=%@&showSyns=N&showFossils=Y&callback=", HOL_BASE_URL,
					 [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getTaxonSynonyms {
	NSString *url = [NSString stringWithFormat:@"%@getTaxonSynonyms?tnuid=%@&showFossils=Y&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getTaxonLiterature {
	NSString *url = [NSString stringWithFormat:@"%@getTaxonLiterature?tnuid=%@&showSyns=N&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getLocalities:(BOOL)showAllSpecimens {
	NSString *szShowAllSpecimen = @"N";
	
	// Check if all specimens subordinate to this taxon should be displayed
	if (showAllSpecimens) {
		szShowAllSpecimen = @"Y";
	}
	
	NSString *url = [NSString stringWithFormat:@"%@getLocalities?tnuid=%@&instID=0&precDecimals=4&showChildren=%@&callback=", HOL_BASE_URL,
					 [self.settings getTNUID], szShowAllSpecimen];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getTaxonImages {
	NSString *url = [NSString stringWithFormat:@"%@getTaxonImages?tnuid=%@&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getInsts {
	NSString *url = [NSString stringWithFormat:@"%@getInsts?tnuid=%@&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getAssociations {
	NSString *url = [NSString stringWithFormat:@"%@getAssociations?tnuid=%@&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getHabitats {
	NSString *url = [NSString stringWithFormat:@"%@getHabitats?tnuid=%@&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getTypes {
	NSString *url = [NSString stringWithFormat:@"%@getTypes?tnuid=%@&showSyns=Y&callback=", HOL_BASE_URL, [self.settings getTNUID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getLitReference {
	NSString *url = [NSString stringWithFormat:@"%@getLitReference?pub_id=%@&callback=", HOL_BASE_URL, [self.settings getPubID]];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getLocalityInfo:(HOLTABCONTROLLERTYPE)tabSection showAll:(BOOL)showAllSpecimens {
	NSString *tnuid = @"0";
	NSString *szShowAllSpecimen = @"N";
	
	// Check if all specimens subordinate to this taxon should be displayed
	if (showAllSpecimens) {
		szShowAllSpecimen = @"Y";
	}
	
	// Check whether to include tnuid in query (taxon maps only)
	if (tabSection == HOLTABCONTROLLERTAXON) {
		tnuid = [self.settings getTNUID];
	}
	
	NSString *url = [NSString stringWithFormat:@"%@getLocalityInfo?locID=%@&tnuid=%@&instID=0&showChildren=%@&callback=",
					 HOL_BASE_URL, [self.settings getLocID], tnuid, szShowAllSpecimen];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

- (NSDictionary *)getProximityCollTripsWithLat:(double)lat lng:(double)lng miles:(NSInteger)miles {
	NSString *url = [NSString stringWithFormat:@"%@getProximityCollTrips?lat=%f&lng=%f&miles=%d&callback=",
					 HOL_BASE_URL, lat, lng, miles];
	NSString *jsonResponse = [self getURL:url];
	NSDictionary *dictResponse = [self convertJSONtoDictionary:jsonResponse];
	
	return dictResponse;
}

// Private functions
- (NSString *)getURL:(NSString *)url {
	// URL encode the string
	NSString* escapedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL* urlRequest = [NSURL URLWithString:escapedUrl];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
														   cachePolicy:NSURLRequestReloadIgnoringCacheData
													   timeoutInterval:120];	
	NSURLResponse *response;
	NSError *error;
	NSData *responseData;
    NSString *jsonString = @"";
    NSInteger nResponseSize = 0;
    
    // Continue network attempts until data is received or attempt limit is reached
    while (!nResponseSize > 0 && self.nNumAttempts < self.nMaxAttempts) {
        responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        jsonString = [NSString stringWithCString:[responseData bytes] encoding:NSUTF8StringEncoding];
        nResponseSize = [jsonString length];
        self.nNumAttempts++;
    }
    
    self.nNumAttempts = 0;
	
	// Remove invalid portions of JSON string [beginning '(' and ending ');']
	NSRange jsonRange = NSMakeRange(1, [jsonString length] - 3);
	NSString *correctedJSON = [jsonString substringWithRange:jsonRange];
	
	return correctedJSON;
}

- (NSDictionary *)convertJSONtoDictionary:(NSString *)jsonString {
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	
	return dictionary;
}

@end
