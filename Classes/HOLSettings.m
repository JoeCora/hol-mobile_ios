/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 13 May 2010
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

#import "HOLSettings.h"

// Private function declarations
@interface HOLSettings()
- (void)checkInternet;
- (void)savePDFToLibrary:(NSDictionary *)pub_info;
- (void)savePDFToLibraryThreaded:(NSDictionary *)pub_info;
- (void)removePDFFromLibrary:(NSDictionary *)pub_info;
- (void)writeLibraryList;
- (BOOL)writePropertyList:(id)plist toFile:(NSString *)fileName;
- (BOOL)writeDocumentFromUrl:(NSString *)url toFile:(NSString *)fileName;
- (id)readPropertyListFromFile:(NSString *)fileName;
- (BOOL)writeApplicationData:(NSData *)data toFile:(NSString *)fileName;
- (BOOL)removeApplicationFile:(NSString *)fileName;
- (NSData *)applicationDataFromFile:(NSString *)fileName;
- (NSData *)getURLData:(NSString *)url;
@end

@implementation HOLSettings

@synthesize taxonNaviBar;
@synthesize nearbyNaviBar;
@synthesize searchNaviBar;
@synthesize libraryNaviBar;
@synthesize moreNaviBar;
@synthesize currentTNUID;
@synthesize currentPubID;
@synthesize currentLocID;
@synthesize currentPDFURL;
@synthesize libraryList;
@synthesize isiPad;
@synthesize isInternetEnabled;
@synthesize isPortraitLocked;
@synthesize nNumDownloads;

- (void)dealloc {
	[taxonNaviBar release];
	[searchNaviBar release];
	[libraryNaviBar release];
	[moreNaviBar release];
	[currentTNUID release];
	[currentPubID release];
	[currentLocID release];
	[currentPDFURL release];
	[libraryList release];
    [super dealloc];
}

// Public functions
- (id)initWithiPad:(BOOL)isiPadDevice {
	isiPad = isiPadDevice;
	
	// Set starting taxon ID (Hymenoptera)
	self.currentTNUID = @"52";
	
	// Check if internet is enabled
	[self checkInternet];
	
	self.isPortraitLocked = YES;
	self.nNumDownloads = 0;
	
    return self;
}

- (void)loadLibraryList {
	self.libraryList = [self readPropertyListFromFile:LIBRARY_LIST_FILENAME];
	
	// If library list is empty, create an empty array for the library list
	if (self.libraryList == nil) {
		self.libraryList = [NSArray array];
	} else {
		// Start downloads for PDFs that didn't finish downloading
		for (NSDictionary *dictPub in self.libraryList) {
			if ([[dictPub objectForKey:@"downloaded"] isEqualToString:@"N"]) {
				// Download PDF
				[self savePDFToLibrary:dictPub];
			}
		}
	}
	
	//NSLog(@"Library: %@", self.libraryList);
}

- (NSString *)getTNUID {
	return self.currentTNUID;
}

- (void)updateTNUID:(NSString *)tnuid {
	self.currentTNUID = tnuid;
}

- (NSString *)getPubID {
	return self.currentPubID;
}

- (void)updatePubID:(NSString *)pub_id {
	self.currentPubID = pub_id;
}

- (NSURL *)getPDFURL {
	return self.currentPDFURL;
}

- (void)updatePDFURL:(NSString *)pdf_url isLocal:(BOOL)local {
	NSString* escapedUrl;
	
	if (local) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		escapedUrl = [documentsDirectory stringByAppendingPathComponent:pdf_url];
		escapedUrl = [escapedUrl stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
	} else {
		// URL encode the string, prepend the http protocol, and update
		escapedUrl = [pdf_url stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
		escapedUrl = [NSString stringWithFormat:@"http://%@", escapedUrl];
	}
	
	self.currentPDFURL = [NSURL URLWithString:escapedUrl];
}

- (NSString *)getLocID {
	return self.currentLocID;
}

- (void)updateLocID:(NSString *)loc_id {
	self.currentLocID = loc_id;
}

- (NSArray *)getLibraryList {
	return self.libraryList;
}

- (NSInteger)isPubInLibrary:(NSInteger)pub_id {
	NSInteger nLibPos = 0;
	
	// Loop through all pubs in library to see if the pub is in the library
	for (NSDictionary *dictPub in self.libraryList) {
		if ([[dictPub objectForKey:@"pub_id"] intValue] == pub_id) {
			return nLibPos;
		}
		
		nLibPos++;
	}
	
	return -1;
}

- (void)addToLibrary:(NSDictionary *)pub_info {
	NSMutableArray *litLibrary = [self.libraryList mutableCopy];
	NSMutableDictionary *dictPub = [pub_info mutableCopy];
	
	// Reclaim memory
	[libraryList release], libraryList = nil;
	
	// Add variable to hold whether the PDF finished downloading
	[dictPub setObject:@"N" forKey:@"downloaded"];
	
	// Add pub reference to library
	[litLibrary addObject:dictPub];
	
	self.libraryList = litLibrary;
	
	[litLibrary release];
    [dictPub release];
	
	// Save the library list
	[self writeLibraryList];
	
	// Download PDF
	[self savePDFToLibrary:dictPub];
}

- (void)removeFromLibrary:(NSInteger)pub_pos {
	NSMutableArray *litLibrary = [self.libraryList mutableCopy];
	
	// Reclaim memory
	[libraryList release], libraryList = nil;
	
	// Get the pub information
	NSDictionary *pubToRemove = [[litLibrary objectAtIndex:pub_pos] retain];
	
	// Remove pub at position from library
	[litLibrary removeObjectAtIndex:pub_pos];
	
	self.libraryList = litLibrary;
	
	[litLibrary release];
	
	// Save the library list
	[self writeLibraryList];
	
	// Remove the PDF
	[self removePDFFromLibrary:pubToRemove];
	
	[pubToRemove release];
}

- (BOOL)allowRotateToOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Check if orientation is locked to portrait
	if (self.isPortraitLocked) {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	} else {
		return YES;
	}
}

- (void)enablePortraitLock {
	self.isPortraitLocked = YES;
}

- (void)disablePortraitLock {
	self.isPortraitLocked = NO;
}

- (BOOL)isDocDownloadAvailable {
	return (self.nNumDownloads == 0);
}

- (NSString *)getFilenameFromURL:(NSString *)url {
	NSArray *parts = [url componentsSeparatedByString:@"/"];
	NSString *filename = [parts objectAtIndex:[parts count] - 1];
	
	return filename;
}

// Private functions
- (void)checkInternet {
	BOOL bSuccess;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [@"hol.osu.edu" UTF8String]);
	SCNetworkReachabilityFlags flags;
	
	// Check whether the host is accessible (internet probably disabled)
	bSuccess = SCNetworkReachabilityGetFlags(reachability, &flags);
	
	self.isInternetEnabled = bSuccess && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	
	CFRelease(reachability);
}

- (void)savePDFToLibrary:(NSDictionary *)pub_info {
	// Download PDF (in new thread)
	self.nNumDownloads++;
	
	// Send message to show start of download
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLUPDATELIBRARYINDICATOR" object:self];
	
	// Start download in new thread
	[NSThread detachNewThreadSelector:@selector(savePDFToLibraryThreaded:) toTarget:self withObject:pub_info];
}

- (void)savePDFToLibraryThreaded:(NSDictionary *)pub_info {
	// Setup autorelease memory pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Get the filename from the PDF URL for saving
	NSString *filename = [self getFilenameFromURL:[pub_info objectForKey:@"url"]];
	
	// Start download
	if ([self writeDocumentFromUrl:[pub_info objectForKey:@"url"] toFile:filename]) {
		self.nNumDownloads--;
		
		// Change status of pub in library list to downloaded
		NSMutableArray *litLibrary = [self.libraryList mutableCopy];
		NSMutableDictionary *dictPub = [litLibrary objectAtIndex:
										[self isPubInLibrary:[[pub_info objectForKey:@"pub_id"] intValue]]];
		
		// Reclaim memory
		[libraryList release], libraryList = nil;
		
		// Add variable to hold whether the PDF finished downloading
		[dictPub setObject:@"Y" forKey:@"downloaded"];
		
		self.libraryList = litLibrary;
		
		[litLibrary release];
		
		// Save the library list
		[self writeLibraryList];
		
		// Send message to show end of download
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HOLUPDATELIBRARYINDICATOR" object:self];
	}
	
	[pool release];
}

- (void)removePDFFromLibrary:(NSDictionary *)pub_info {
	// Get the filename from the PDF URL for saving
	NSString *filename = [self getFilenameFromURL:[pub_info objectForKey:@"url"]];
	
	// Remove the PDF
	[self removeApplicationFile:filename];
}

- (void)writeLibraryList {
	[self writePropertyList:self.libraryList toFile:LIBRARY_LIST_FILENAME];
}

- (BOOL)writePropertyList:(id)plist toFile:(NSString *)fileName {
    NSString *error;
    NSData *pData = [NSPropertyListSerialization dataFromPropertyList:plist format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	
    if (!pData) {
        NSLog(@"%@", error);
		
        return NO;
    }
	
    return ([self writeApplicationData:pData toFile:(NSString *)fileName]);
}

- (BOOL)writeDocumentFromUrl:(NSString *)url toFile:(NSString *)fileName {
    NSData *pData = [self getURLData:url];
	
    if (!pData) {
        NSLog(@"%@", @"Problem writing document from the specified URL!");
		
        return NO;
    }
	
	
    return ([self writeApplicationData:pData toFile:(NSString *)fileName]);
}

- (id)readPropertyListFromFile:(NSString *)fileName {
    NSData *retData;
    NSString *error;
    id retPlist;
    NSPropertyListFormat format;
	
    retData = [self applicationDataFromFile:fileName];
	
    if (!retData) {
        NSLog(@"Data file not returned.");
		
        return nil;
    }
	
    retPlist = [NSPropertyListSerialization propertyListFromData:retData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
	
    if (!retPlist) {
        NSLog(@"Property list not returned, error: %@", error);
    }
	
    return retPlist;
}

- (BOOL)writeApplicationData:(NSData *)data toFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
    if (!documentsDirectory) {
        NSLog(@"Documents directory not found!");
		
        return NO;
    }
	
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
	
    return ([data writeToFile:appFile atomically:YES]);
}

- (BOOL)removeApplicationFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
    if (!documentsDirectory) {
        NSLog(@"Documents directory not found!");
		
        return NO;
    }
	
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	// Remove file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:filePath error:NULL];
	
	return YES;
}

- (NSData *)applicationDataFromFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSData *myData = [[[NSData alloc] initWithContentsOfFile:appFile] autorelease];
	
    return myData;
}

- (NSData *)getURLData:(NSString *)url {
	// URL encode the string
	NSString* escapedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
	escapedUrl = [NSString stringWithFormat:@"http://%@", escapedUrl];
	NSURL* urlRequest = [NSURL URLWithString:escapedUrl];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
														   cachePolicy:NSURLRequestReloadIgnoringCacheData
													   timeoutInterval:120];	
	NSURLResponse *response;
	NSError *error;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:&response
															 error:&error];
	
	return responseData;
}

@end
