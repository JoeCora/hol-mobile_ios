/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 3 Apr 2010
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

#import "HOLPictureSource.h"

@implementation HOLPictureSource

@synthesize images;
@synthesize title;
@synthesize settings;

// Public functions
- (id)initWithSettings:(HOLSettings *)loadSettings type:(NSString *)type {
	self = [super init];
	
	self.settings = loadSettings;
	
	// Get the images based on type of page (taxon only as of now)
	HOLServerInteraction *server = [[HOLServerInteraction alloc] initWithSettings:self.settings];
	NSDictionary *dictInfo = [server getTaxonImages];
	
	[server release];
	
	// Check if results were available (internet enabled)
	if (dictInfo != nil) {
		NSArray *arrayImageRefs = [dictInfo objectForKey:@"images"];
		NSMutableArray *arrayImages = [[NSMutableArray alloc] initWithCapacity:[arrayImageRefs count]];
		
		for (NSDictionary *dictImage in arrayImageRefs) {
			HOLPicture *currentImage = [[HOLPicture alloc] initWithThumbnail:[dictImage objectForKey:@"thumb"] compressed:[dictImage objectForKey:@"normalRes"]
																	 caption:[NSString stringWithFormat:@"%@\ncc)%@ / © 2013, %@", [dictImage objectForKey:@"caption"], [dictImage objectForKey:@"license"], [dictImage objectForKey:@"copyright"]]
																		size:CGSizeMake(1600, 1200)];
			
			currentImage.photoSource = self;
			currentImage.index = [arrayImages count];
			
			[arrayImages addObject:currentImage];
			
			[currentImage release];
		}
		
		self.images = arrayImages;
		
		[arrayImages release];
	}
	
    return self;
}

#pragma mark -
#pragma mark TTPhotoSource protocol

- (NSInteger)numberOfPhotos {
    return [self.images count];
}

- (NSInteger)maxPhotoIndex {
    return [self.images count] - 1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)index {
	if (index < [self.images count]) {
		return (id<TTPhoto>)[self.images objectAtIndex:index];
	} else {
		return nil;
	}
}

#pragma mark -
#pragma mark TTModel protocol

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	[self didFinishLoad];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[settings release];
	[images release];
	[title release];
    [super dealloc];
}

@end
