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

#import "HOLPicture.h"

@implementation HOLPicture

@synthesize photoSource;
@synthesize urlThumbnail;
@synthesize urlCompressed;
@synthesize caption;
@synthesize size;
@synthesize index;

// Public functions
- (id)initWithThumbnail:(NSString *)thumb compressed:(NSString *)compress caption:(NSString *)imageCaption size:(CGSize)imageSize {
	self = [super init];
	
	self.urlThumbnail = [thumb stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
	self.urlCompressed = [compress stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
	self.caption = imageCaption;
	self.size = imageSize;
	
    return self;
}

#pragma mark -
#pragma mark TTPhoto protocol

- (NSString*)URLForVersion:(TTPhotoVersion)version {
	if (version == TTPhotoVersionThumbnail && self.urlThumbnail) {
		return self.urlThumbnail;
	} else {
		return self.urlCompressed;
	}
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[urlThumbnail release];
	[urlCompressed release];
	[caption release];
    [super dealloc];
}

@end
