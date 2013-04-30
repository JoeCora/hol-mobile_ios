/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 22 Mar 2010
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

#import "HOLCell.h"

@implementation HOLCell

@synthesize pdfIconView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	self.indentationWidth = 15.0;
	
	self.contentMode = UIViewContentModeTopRight;
	
	// Configure PDF icon
	UIImage *pdfIcon = [UIImage imageNamed:@"pdf_icon.gif"];
	UIImageView *tempPDFIcon = [[UIImageView alloc] initWithImage:pdfIcon];
	self.pdfIconView = tempPDFIcon;
	[tempPDFIcon release];
	
	CGRect imageFrame = self.pdfIconView.frame;
	
	imageFrame.origin.x = 5.0;
	imageFrame.origin.y = 30.0;
	
	self.pdfIconView.frame = imageFrame;
	
	// Dont let PDF icon get clipped
	self.textLabel.clipsToBounds = NO;
	
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[pdfIconView release];
    [super dealloc];
}

// Public functions
- (void)showPDFIcon {
	self.indentationLevel = 1;
	[self.contentView addSubview:self.pdfIconView];
}

- (void)hidePDFIcon {
	self.indentationLevel = 0;
	[self.pdfIconView removeFromSuperview];
}

@end
