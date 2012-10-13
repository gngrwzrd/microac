
#import "QCTableCellView.h"

@implementation QCTableCellView
@synthesize progress = _progress;
@synthesize operation = _operation;
@synthesize customLabel = _customLabel;
@synthesize warning = _warning;
@synthesize check = _check;
@synthesize formatLabel = _formatLabel;
@synthesize outputLabel = _outputLabel;

- (void) updateFrames {
	NSRect frame = self.frame;
	NSRect customLabelFrame = _customLabel.frame;
	NSRect warningFrame = _warning.frame;
	NSRect checkFrame = _check.frame;
	NSRect progressFrame = _progress.frame;
	NSRect formatFrame = _formatLabel.frame;
	NSRect outputLabel = _outputLabel.frame;
	NSInteger rp = 4; //rightPadding
	
	//find width of format label
	NSString * format = [_operation shortFormatLabel];
	NSFont * font = [_formatLabel font];
	NSSize size = [format sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil]];
	
	//set frames
	[_formatLabel setFrame:NSMakeRect(formatFrame.origin.x,formatFrame.origin.y,size.width+2,formatFrame.size.height)];
	[_outputLabel setFrame:NSMakeRect(formatFrame.origin.x+size.width+10, outputLabel.origin.y, outputLabel.size.width, outputLabel.size.height)];
	[_customLabel setFrame:NSMakeRect(frame.size.width-customLabelFrame.size.width-rp,customLabelFrame.origin.y,customLabelFrame.size.width,customLabelFrame.size.height)];
	[_warning setFrame:NSMakeRect(frame.size.width-warningFrame.size.width-rp,warningFrame.origin.y,warningFrame.size.width,warningFrame.size.height)];
	[_check setFrame:NSMakeRect(frame.size.width-checkFrame.size.width-rp,checkFrame.origin.y,checkFrame.size.width,checkFrame.size.height)];
	[_progress setFrame:NSMakeRect(frame.size.width-progressFrame.size.width-rp,progressFrame.origin.y,progressFrame.size.width,progressFrame.size.height)];
}

- (void) invalidate {
	[_warning setToolTip:@"Output settings are invalid for this file"];
	[_check setToolTip:@"Finished successfully"];
	
	if(_validSettings) {
		[self addSubview:_warning];
		[_progress stopAnimation:self];
		[_progress removeFromSuperview];
		[_check removeFromSuperview];
		[_customLabel removeFromSuperview];
	}
	
	if(!_validSettings) {
		[self addSubview:_warning];
		[_customLabel removeFromSuperview];
		[_progress stopAnimation:self];
		[_progress removeFromSuperview];
		[_check removeFromSuperview];
		[self setToolTip:@"Output settings are invalid for this file"];
	}
	
	if(_operation.isExecuting) {
		[self addSubview:_progress];
		[_progress startAnimation:self];
		[_warning removeFromSuperview];
		[_check removeFromSuperview];
		[_customLabel removeFromSuperview];
		[self setToolTip:@"Processing..."];
	}
	
	if(!_operation.isExecuting && _validSettings) {
		[_progress stopAnimation:self];
		[_progress removeFromSuperview];
		[self addSubview:_customLabel];
		[_customLabel setStringValue:@"Waiting..."];
		[_check removeFromSuperview];
		[_warning removeFromSuperview];
		[self setToolTip:@"In the queue waiting for my turn"];
	}
	
	if(_operation.queue.isSuspended) {
		[_customLabel setStringValue:@"Ready..."];
	} else {
		[_customLabel setStringValue:@"Waiting..."];
	}
	
	if(_operation.conversionOutputDirectory.length < 1) {
		[_customLabel setStringValue:@""];
		[self setToolTip:@"Destination is not set."];
		[self addSubview:_warning];
	}
	
	if(_operation.isFinished && !_operation.isCancelled) {
		[self addSubview:_check];
		[_warning removeFromSuperview];
		[_customLabel removeFromSuperview];
		[_progress stopAnimation:self];
		[_progress removeFromSuperview];
		[self setToolTip:@"Finished successfully"];
	}
	
	[self.imageView setImage:[[NSWorkspace sharedWorkspace] iconForFile:_operation.file]];
	[_outputLabel setStringValue:[_operation outputLabel]];
	[_formatLabel setStringValue:[_operation shortFormatLabel]];
	
	[self updateFrames];
}

- (void) setOperation:(QCOperation *) operation {
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	
	if(operation != _operation) {
		if(_operation) {
			[nfc removeObserver:self];
			[_operation release];
		}
		_operation = [operation retain];
		
		//operation observers
		[nfc addObserver:self selector:@selector(onOperationSettingsValid:) name:QCOperationSettingsValid object:_operation];
		[nfc addObserver:self selector:@selector(onOperationSettingsInvalid:) name:QCOperationSettingsInvalid object:_operation];
		[nfc addObserver:self selector:@selector(onOperationComplete:) name:QCOperationComplete object:_operation];
		[nfc addObserver:self selector:@selector(onOperationCancel:) name:QCOperationCancel object:_operation];
		[nfc addObserver:self selector:@selector(onOperationStart:) name:QCOperationStart object:_operation];
		
		//global observers
		[nfc addObserver:self selector:@selector(onQueueSuspendChange:) name:QCOperationQueueSuspendChange object:nil];
	}
	
	self.textField.stringValue = [_operation.file lastPathComponent];
	[self invalidate];
}

- (void) onQueueSuspendChange:(NSNotification *) notification {
	if(_operation.queue.isSuspended) {
		[_customLabel setStringValue:@"Ready..."];
	} else {
		[_customLabel setStringValue:@"Waiting..."];
	}
}

- (void) onOperationSettingsValid:(NSNotification *) notification {
	_validSettings = true;
	[self invalidate];
}

- (void) onOperationSettingsInvalid:(NSNotification *) notification {
	NSLog(@"invalid!");
	_validSettings = false;
	[self invalidate];
}

- (void) onOperationStart:(NSNotification *) notification {
	[_warning removeFromSuperview];
	[_customLabel removeFromSuperview];
	[self addSubview:_progress];
	[self updateFrames];
	[_progress startAnimation:self];
}

- (void) onOperationComplete:(NSNotification *) notification {
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	[_progress stopAnimation:self];
	[_progress removeFromSuperview];
	[self updateFrames];
	[self addSubview:_check];
	[nfc removeObserver:self];
}

- (void) onOperationCancel:(NSNotification *) notification {
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	[_progress stopAnimation:self];
	[_progress removeFromSuperview];
	[nfc removeObserver:self];
}

- (void) dealloc {
	NSLog(@"DEALLOC: QCTableCellView");
	
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	[nfc removeObserver:self];
	
	if(_progress) {
		[_progress release];
		_progress = NULL;
	}
	
	if(_operation) {
		[_operation release];
		_operation = NULL;
	}
	
	if(_customLabel) {
		[_customLabel release];
		_customLabel = NULL;
	}
	
	if(_warning) {
		[_warning release];
		_warning = NULL;
	}
	
	if(_check) {
		[_check release];
		_check = NULL;
	}
	
	[super dealloc];
}

@end
