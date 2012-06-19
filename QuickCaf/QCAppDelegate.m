
#import "QCAppDelegate.h"
#import "QCTableCellView.h"

@implementation QCAppDelegate
@synthesize window = _window;
@synthesize tableView = _tableView;
@synthesize tableScrollView = _tableScrollView;
@synthesize containerFormat = _containerFormat;
@synthesize dataFormat = _dataFormat;
@synthesize sampleRate = _sampleRate;
@synthesize outputChooseDir = _outputChooseDir;
@synthesize outputDir = _outputDir;
@synthesize outputSameDir = _outputSameDir;
//@synthesize totalProgress = _totalProgress;
@synthesize revealOutputDir = _revealOutputDir;
//@synthesize totalProgressLabel = _totalProgressLabel;
@synthesize removeItemsFromQueue = _removeItemsFromQueue;
@synthesize channelsLabel = _channelsLabel;
@synthesize channelsCountLabel = _channelsCountLabel;
@synthesize channelsStepper = _channelsStepper;
@synthesize targetFormat = _targetFormat;
@synthesize convertButton = _convertButton;
@synthesize audioAlerts = _audioAlerts;
@synthesize concurrencyLabel = _concurrencyLabel;
@synthesize concurrencyStepper = _concurrencyStepper;
@synthesize quickDropLabel = _quickDropLabel;
@synthesize quickDropProgress = _quickDropProgress;
@synthesize quickDropView = _quickDropView;
@synthesize quickDropViewContainer = _quickDropViewContainer;
@synthesize quickDropBGImage = _quickDropBGImage;

- (void) windowWillClose:(NSNotification *) notification {
	[[NSApplication sharedApplication] terminate:self];
}

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification {
	self.window.delegate = self;
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	
	//setup sounds
	_glass = [[NSSound soundNamed:@"Glass"] retain];
	
	//setup table view
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[_tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
	
	//setup quick dropts
	[nfc addObserver:self selector:@selector(onQuickDrop:) name:QCDragDropViewDroppedFiles object:_quickDropView];
	[_quickDropProgress removeFromSuperview];
	_quickQueue = [[NSOperationQueue alloc] init];
	[_quickQueue setMaxConcurrentOperationCount:1];
	
	//setup work queue
	_workQueue = [[NSOperationQueue alloc] init];
	_workOperations = [[NSMutableArray alloc] init];
	_workOperationsLock = [[NSRecursiveLock alloc] init];
	[_workQueue setMaxConcurrentOperationCount:4];
	[_workQueue setSuspended:TRUE];
	
	//supported input file extensions
	_extensions = [[NSArray arrayWithObjects:
		@"3gp",@"3g2",@"aac",@"adts",@"ac3",@"aifc",@"aiff",@"aif",@"amr",
		@"m4a",@"m4r",@"m4b",@"caf",@"mp1",@"mp2",@"mp3",@"mpeg",@"mp4",@"snd",
		@"au",@"sd2",@"wav",
	nil] retain];
	
	//setup the formats dictionaries for easy lookup
	_formats = [[NSMutableDictionary alloc] init];
	_targetFormats = [[NSMutableArray alloc] init];
	NSMutableDictionary * tmp = NULL;
	
	//3GP
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"3GP Audio" forKey:@"description"];
	[tmp setObject:@"3gp" forKey:@"postfix"];
	[tmp setObject:@"3gpp" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".3gp", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf",@"aach", @"aacl", @"aacp",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf",@"aach", @"aacl", @"aacp",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//3GP2
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"3GP-2 Audio" forKey:@"description"];
	[tmp setObject:@"3gp2" forKey:@"postfix"];
	[tmp setObject:@"3gp2" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".3gp2", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf",@"aach", @"aacl", @"aacp", nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf",@"aach", @"aacl", @"aacp", nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//adts
	/*
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"AAC ADTS" forKey:@"description"];
	[tmp setObject:@"adts" forKey:@"postfix"];
	[tmp setObject:@"adts" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".aac", @".adts", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"Qclp",@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp", nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"Qclp",@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp", nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	*/
	
	//ac-3
	/*
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"AC3" forKey:@"description"];
	[tmp setObject:@"ac3" forKey:@"postfix"];
	[tmp setObject:@"ac-3" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".ac3",nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"ac-3",nil]forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"ac-3",nil]forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	*/
	
	//AIFC
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"AIFC" forKey:@"description"];
	[tmp setObject:@"aifc" forKey:@"postfix"];
	[tmp setObject:@"AIFC" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".aifc",@".aiff",@".aif",nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:
	@"ima4",@"PCM I8",@"PCM UI8",@"PCM BEI16",@"PCM BEI24",
	@"PCM BEI32",@"PCM BEF32",@"PCM BEF64",nil] forKey:@"dataFormats"];
	
	[tmp setObject:[NSArray arrayWithObjects:
	@"ima4",@"I8", @"UI8" , @"BEI16", @"BEI24", @"BEI32", @"BEF32", @"BEF64",
	nil] forKey:@"dataFormatArguments"];
	
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//AIFF
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"AIFF" forKey:@"description"];
	[tmp setObject:@"aiff" forKey:@"postfix"];
	[tmp setObject:@"AIFF" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".aiff",@".aif",nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"PCM I8", @"PCM BEI16", @"PCM BEI24", @"PCM BEI32",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"I8", @"BEI16", @"BEI24", @"BEI32", nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//AMR
	/*
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"AMR" forKey:@"description"];
	[tmp setObject:@"amr" forKey:@"postfix"];
	[tmp setObject:@"amrf" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".amr",nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"samr",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"samr",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	*/
	
	//m4af
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"Apple MPEG-4 Audio" forKey:@"description"];
	[tmp setObject:@"m4af" forKey:@"postfix"];
	[tmp setObject:@"m4af" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".m4a",@".m4r",nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//m4bf
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"Apple MPEG-4 AudioBooks" forKey:@"description"];
	[tmp setObject:@"m4bf" forKey:@"postfix"];
	[tmp setObject:@"m4bf" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".m4b",nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//caff
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"CAF" forKey:@"description"];
	[tmp setObject:@"caf" forKey:@"postfix"];
	[tmp setObject:@"caff" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".caf", nil] forKey:@"extensions"];
	
	[tmp setObject:[NSArray arrayWithObjects:
	@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp", @"ilbc", @"ima4",
	@"PCM I8", @"PCM BEI16", @"PCM BEI24", @"PCM BEI32", @"PCM BEF32", @"PCM BEF64",
	@"PCM LEI16", @"PCM LEI24", @"PCM LEI32", @"PCM LEF32", @"PCM LEF64",
	nil] forKey:@"dataFormats"];
	
	[tmp setObject:[NSArray arrayWithObjects:
	@"aac", @"aace", @"aacf", @"aach",@"aacl", @"aacp", @"ilbc", @"ima4",
	@"I8", @"BEI16", @"BEI24", @"BEI32", @"BEF32", @"BEF64",
	@"LEI16", @"LEI24", @"LEI32", @"LEF32", @"LEF64",
	nil] forKey:@"dataFormatArguments"];
	
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//MPEG1
	/*
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"MPEG-1" forKey:@"description"];
	[tmp setObject:@"mpeg1" forKey:@"postfix"];
	[tmp setObject:@"MPG1" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".mp1", @".mpeg", @".mpa", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"mp1",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"mp1",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	*/
	
	//MPEG2
	/*
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"MPEG-2" forKey:@"description"];
	[tmp setObject:@"mpeg2" forKey:@"postfix"];
	[tmp setObject:@"MPG2" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".mp2", @".mpeg", @".mpa", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"mp2",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"mp2",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	*/
	
	//MPEG3
	/*
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"MPEG-3" forKey:@"description"];
	[tmp setObject:@"mpeg3" forKey:@"postfix"];
	[tmp setObject:@"MPG3" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".mp3", @".mpeg", @".mpa", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"mp3",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"mp3",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	*/
	
	//MPEG4
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"MPEG-4 Audio" forKey:@"description"];
	[tmp setObject:@"mp4f" forKey:@"postfix"];
	[tmp setObject:@"mp4f" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".mp4", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp", nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"aac", @"aace", @"aacf", @"aach", @"aacl", @"aacp", nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//NeXT
	/*
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"NeXT/Sun" forKey:@"description"];
	[tmp setObject:@"next" forKey:@"postfix"];
	[tmp setObject:@"NeXT" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".snd",@".au", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"PCM I8", @"PCM BEI16", @"PCM BEI24", @"PCM BEI32",@"PCM BEF32", @"PCM BEF64", @"ulaw",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"I8", @"BEI16", @"BEI24", @"BEI32",@"BEF32", @"BEF64", @"ulaw",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	*/
	
	/*
	//Sound Designer 2
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"Sound Designer 2" forKey:@"description"];
	[tmp setObject:@"Sd2f" forKey:@"postfix"];
	[tmp setObject:@"Sd2f" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".sd2", nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"PCM I8", @"PCM BEI16", @"PCM BEI24", @"PCM BEI32",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"I8", @"BEI16", @"BEI24", @"BEI32",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	*/
	
	//WAVE
	tmp = [NSMutableDictionary dictionary];
	[tmp setObject:@"WAVE" forKey:@"description"];
	[tmp setObject:@"wav" forKey:@"postfix"];
	[tmp setObject:@"WAVE" forKey:@"fileFormat"];
	[tmp setObject:[NSArray arrayWithObjects:@".wav",nil] forKey:@"extensions"];
	[tmp setObject:[NSArray arrayWithObjects:@"PCM I8", @"PCM LEI16", @"PCM LEI24", @"PCM LEI32", @"PCM LEF32", @"PCM LEF64",nil] forKey:@"dataFormats"];
	[tmp setObject:[NSArray arrayWithObjects:@"I8", @"LEI16", @"LEI24", @"LEI32", @"LEF32", @"LEF64",nil] forKey:@"dataFormatArguments"];
	[_formats setObject:tmp forKey:[tmp objectForKey:@"description"]];
	[_targetFormats addObject:tmp];
	
	//setup target formats combobox
	[_targetFormat removeAllItems];
	for(NSMutableDictionary * item in _targetFormats) {
		[_targetFormat addItemWithTitle:[item objectForKey:@"description"]];
	}
	[_targetFormat selectItemAtIndex:0];
	
	//setup the other combo boxes
	NSString * key = [[_targetFormat selectedItem] title];
	NSMutableDictionary * info = [_formats objectForKey:key];
	[_containerFormat removeAllItems];
	[_containerFormat addItemsWithTitles:[info objectForKey:@"extensions"]];
	[_dataFormat removeAllItems];
	[_dataFormat addItemsWithTitles:[info objectForKey:@"dataFormats"]];
}

- (void) onQuickDrop:(NSNotification *) notification {
	NSArray * files = _quickDropView.droppedFiles;
	if(files.count > 1) {
		NSBeep();
		return;
	}
	
	NSString * file = [files objectAtIndex:0];
	if(![_extensions containsObject:[file pathExtension]]) {
		NSBeep();
		return;
	}
	
	[self invalidateQuickDrop];
	[_quickDropViewContainer addSubview:_quickDropProgress];
	[_quickDropProgress startAnimation:self];
	//[_quickDropBGImage removeFromSuperview];
	
	NSMutableDictionary * info = [_formats objectForKey:[_targetFormat selectedItem].title];
	
	QCOperation * op = [[[QCOperation alloc] init] autorelease];
	op.queue = _quickQueue;
	op.isInQueue = TRUE;
	[op setConversionInfo:[_formats objectForKey:[_targetFormat selectedItem].title]];
	[op setConversionExtension:[_containerFormat selectedItem].title];
	
	NSInteger selectedDataFormatIndex = [[_dataFormat menu] indexOfItem:[_dataFormat selectedItem]];
	NSString * df = [[info objectForKey:@"dataFormatArguments"] objectAtIndex:selectedDataFormatIndex];
	[op setConversionDataFormat:df];
	[op setConversionSampleRate:[_sampleRate stringValue]];
	[op setConversionChannels:_channelsCountLabel.integerValue];
	[op setFile:[files objectAtIndex:0]];
	if(![_outputSameDir state]) [op setConversionOutputDirectory:[_outputDir stringValue]];
	else [op setConversionOutputDirectory:nil];
	
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	[nfc addObserver:self selector:@selector(onQuickDropComplete:) name:QCOperationComplete object:op];
	
	[_quickQueue addOperation:op];
}

- (void) invalidateQuickDrop {
	NSRect frame = _quickDropViewContainer.frame;
	NSRect cframe = _quickDropProgress.frame;
	cframe.size.width = frame.size.width-1;
	[_quickDropProgress setFrame:cframe];
}

- (void) onQuickDropComplete:(NSNotification *) notification {
	if(_audioAlerts) [_glass play];
	[_quickDropProgress removeFromSuperview];
}

- (IBAction) onDestinationSameAsSource:(id) sender {
	if(_outputDir.isEnabled) {
		[_outputDir setEnabled:FALSE];
		[_outputChooseDir setEnabled:FALSE];
		[_revealOutputDir setEnabled:FALSE];
	} else {
		[_outputDir setEnabled:TRUE];
		[_outputChooseDir setEnabled:TRUE];
		[_revealOutputDir setEnabled:TRUE];
	}
	
	[self invalidateOutputDirectory];
}

- (IBAction) onTypeChosen:(id) sender {
	if([_targetFormat selectedItem] == _selectedType) return;
	_selectedType = [_targetFormat selectedItem];
	
	NSString * key = [[_targetFormat selectedItem] title];
	NSMutableDictionary * info = [_formats objectForKey:key];
	[_containerFormat removeAllItems];
	[_containerFormat addItemsWithTitles:[info objectForKey:@"extensions"]];
	[_dataFormat removeAllItems];
	[_dataFormat addItemsWithTitles:[info objectForKey:@"dataFormats"]];
	
	[self invalidateWorkQueue];
}

- (IBAction) onContainerFormatChosen:(id) sender {
	if([_containerFormat selectedItem] == _selectedContainer) return;
	_selectedContainer = [_containerFormat selectedItem];
	[self invalidateWorkQueue];
}

- (IBAction) onDataFormatChosen:(id) sender {
	if([_dataFormat selectedItem] == _selectedDataFormat) return;
	_selectedDataFormat = [_dataFormat selectedItem];
	[self invalidateWorkQueue];
}

- (IBAction) onBitrateChosen:(id) sender {
	[self invalidateWorkQueue];
}

- (IBAction) onConcurrencyChange:(id) sender {
	[_workQueue setMaxConcurrentOperationCount:[_concurrencyStepper integerValue]];
	[_concurrencyLabel setStringValue:[NSString stringWithFormat:@"%li",[_concurrencyStepper integerValue]]];
}

- (void) invalidateSettings {
	_settingsAreValid = TRUE;
}

- (NSInteger) addFiles:(NSArray *) files {
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	NSFileManager * fm = [NSFileManager defaultManager];
	NSMutableArray * acceptedFiles = [NSMutableArray array];
	
	//process files, make sure we have accepted files
	NSString * extension = NULL;
	BOOL isdir = false;
	for(NSString * file in files) {
		isdir = false;
		if(([fm fileExistsAtPath:file isDirectory:&isdir]) && isdir) {
			//TODO: directory scanning
		} else {
			extension = [file pathExtension];
			if([_extensions containsObject:extension]) {
				[acceptedFiles addObject:file];
			}
		}
	}
	
	if(acceptedFiles.count < 1) return 0;
	
	NSInteger selectedDataFormatIndex = 0;
	NSMutableDictionary * info = [_formats objectForKey:[_targetFormat selectedItem].title];
	
	//update workOperations array with new files
	[_workOperationsLock lock];
	QCOperation * operation = NULL;
	for(NSString * filePath in acceptedFiles) {
		operation = [[[QCOperation alloc] init] autorelease];
		[_workOperations addObject:operation];
		[nfc addObserver:self selector:@selector(onOperationComplete:) name:QCOperationComplete object:operation];
		[nfc addObserver:self selector:@selector(onOperationStart:) name:QCOperationStart object:operation];
		[operation setFile:filePath];
		[operation setQueue:_workQueue];
		selectedDataFormatIndex = [[_dataFormat menu] indexOfItem:[_dataFormat selectedItem]];
		[operation setConversionInfo:info];
		[operation setConversionType:[_targetFormat stringValue]];
		NSString * df = [[info objectForKey:@"dataFormatArguments"] objectAtIndex:selectedDataFormatIndex];
		[operation setConversionDataFormat:df];
		[operation setConversionDataFormatLabel:[_dataFormat selectedItem] .title];
		[operation setConversionExtension:[_containerFormat selectedItem].title];
		[operation setConversionSampleRate:[_sampleRate stringValue]];
		[operation setConversionChannels:[_channelsCountLabel integerValue]];
		if(![_outputSameDir state]) [operation setConversionOutputDirectory:[_outputDir stringValue]];
		else [operation setConversionOutputDirectory:nil];
		[operation invalidate];
		if(!operation.isInQueue) {
			[_workQueue addOperation:operation];
			operation.isInQueue = TRUE;
		}
	}
	[_workOperationsLock unlock];
	[_tableView reloadData];
	
	[self invalidateWorkQueue];
	return acceptedFiles.count;
}

- (void) invalidateWorkQueue {
	[self invalidateSettings];
	if(!_settingsAreValid) return;
	
	//can't edit all UNSELECTED settings if the queue is running.
	NSIndexSet * selectedRows = [_tableView selectedRowIndexes];
	if(selectedRows.count < 1 && !_workQueue.isSuspended) return;
	
	//make sure there's at least 1 operation
	[_workOperationsLock lock];
	if(_workOperations.count < 1) {
		[_workOperationsLock unlock];
		return;
	}
	
	//get dictionary lookup for selected type
	NSInteger selectedDataFormatIndex = 0;
	NSMutableDictionary * info = [_formats objectForKey:[_targetFormat selectedItem].title];
	
	//select which array of operations update
	NSArray * workOperations = NULL;
	if(selectedRows.count > 0) {
		workOperations = [_workOperations objectsAtIndexes:selectedRows];
	} else {
		workOperations = _workOperations;
	}
	
	//update the operations
	for(QCOperation * operation in workOperations) {
		if(operation.isExecuting || operation.isFinished) continue;
		selectedDataFormatIndex = [[_dataFormat menu] indexOfItem:[_dataFormat selectedItem]];
		[operation setConversionInfo:info];
		[operation setConversionType:[_targetFormat stringValue]];
		NSString * df = [[info objectForKey:@"dataFormatArguments"] objectAtIndex:selectedDataFormatIndex];
		[operation setConversionDataFormat:df];
		[operation setConversionDataFormatLabel:[_dataFormat selectedItem].title];
		[operation setConversionExtension:[_containerFormat selectedItem].title];
		[operation setConversionSampleRate:[_sampleRate stringValue]];
		[operation setConversionChannels:[_channelsCountLabel integerValue]];
		if(![_outputSameDir state]) {
			if(_outputDir.stringValue.length < 1) {
				[operation setConversionOutputDirectory:[[_outputDir cell] placeholderString]];
			} else {
				[operation setConversionOutputDirectory:[_outputDir stringValue]];
			}
		} else {
			[operation setConversionOutputDirectory:nil];
		}
		[operation invalidate];
		if(!operation.isInQueue) {
			[_workQueue addOperation:operation];
			operation.isInQueue = TRUE;
		}
	}
	
	[_workOperationsLock unlock];
}

- (void) invalidateOutputDirectory {
	[self invalidateSettings];
	if(!_settingsAreValid) return;
	
	//can't edit all UNSELECTED settings if the queue is running.
	NSIndexSet * selectedRows = [_tableView selectedRowIndexes];
	if(selectedRows.count < 1 && !_workQueue.isSuspended) return;
	
	//make sure there's at least 1 operation
	[_workOperationsLock lock];
	if(_workOperations.count < 1) {
		[_workOperationsLock unlock];
		return;
	}
	
	//select which array of operations update
	NSArray * workOperations = NULL;
	if(selectedRows.count > 0) {
		workOperations = [_workOperations objectsAtIndexes:selectedRows];
	} else {
		workOperations = _workOperations;
	}
	
	//update the operations
	for(QCOperation * operation in workOperations) {
		if(operation.isExecuting || operation.isFinished) continue;
		if(![_outputSameDir state]) {
			if(_outputDir.stringValue.length < 1) {
				[operation setConversionOutputDirectory:[[_outputDir cell] placeholderString]];
			} else {
				[operation setConversionOutputDirectory:[_outputDir stringValue]];
			}
		} else {
			[operation setConversionOutputDirectory:nil];
		}
		[operation invalidate];
	}
	
	[_workOperationsLock unlock];
}

- (void) invalidateChannels {
	[self invalidateSettings];
	if(!_settingsAreValid) return;
	
	//can't edit all UNSELECTED settings if the queue is running.
	NSIndexSet * selectedRows = [_tableView selectedRowIndexes];
	if(selectedRows.count < 1 && !_workQueue.isSuspended) return;
	
	//make sure there's at least 1 operation
	[_workOperationsLock lock];
	if(_workOperations.count < 1) {
		[_workOperationsLock unlock];
		return;
	}
	
	//select which array of operations update
	NSArray * workOperations = NULL;
	if(selectedRows.count > 0) {
		workOperations = [_workOperations objectsAtIndexes:selectedRows];
	} else {
		workOperations = _workOperations;
	}
	
	//update the operations
	for(QCOperation * operation in workOperations) {
		if(operation.isExecuting || operation.isFinished) continue;
		[operation setConversionChannels:[_channelsCountLabel integerValue]];
		[operation invalidate];
	}
	
	[_workOperationsLock unlock];
}

- (void) onOperationComplete:(NSNotification *) notification {
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	[nfc removeObserver:self name:QCOperationComplete object:notification.object];
	[self performSelectorOnMainThread:@selector(_onOperationComplete) withObject:nil waitUntilDone:false];
}

- (void) onOperationStart:(NSNotification *) notification {
	//[_totalProgressLabel setStringValue:@"Running..."];
}

- (void) updateTotalProgress {
	//double val = 100 - (100 / _workOperations.count);
	//double val = 100 / _workOperations.count;
	//[_totalProgress setDoubleValue:val];
}

- (void) _onOperationComplete {
	if(_reloadLater) [_reloadLater invalidate];
	_reloadLater = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(reloadTable:) userInfo:nil repeats:false];
}

- (void) reloadTable:(NSTimer *) timer {
	//NSLog(@"workQueue.operationCount: %li",_workQueue.operationCount);
	//NSLog(@"tableView.numberOfRows: %li",_tableView.numberOfRows);
	
	if([_workQueue operationCount] < 1) {
		[_workQueue setSuspended:TRUE];
		if(_audioAlerts.state) [_glass play];
		//[_totalProgressLabel setStringValue:@"Stopped"];
	}
	
	if(_reloadLater) {
		[_reloadLater invalidate];
		_reloadLater = NULL;
	}
	
	if(_removeItemsFromQueue.state) {
		[_workOperationsLock lock];
		NSInteger i = _workOperations.count - 1;
		QCOperation * operation = NULL;
		for(; i > -1; i--) {
			operation = [_workOperations objectAtIndex:i];
			if(operation.isFinished && !operation.isCancelled) {
				[_workOperations removeObjectAtIndex:i];
			}
		}
		[_workOperationsLock unlock];
		[_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:TRUE];
	}
	
	[self updateTotalProgress];
}

- (IBAction) onChooseDirectory:(id) sender {
	NSOpenPanel * open = [NSOpenPanel openPanel];
	[open setCanChooseDirectories:TRUE];
	[open setCanChooseFiles:FALSE];
	[open beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if(result) {
			[_outputDir setObjectValue:[[open directoryURL] path]];
			//[self invalidateWorkQueue];
			[self invalidateOutputDirectory];
		}
	}];
}

- (IBAction) onRevealOutputDir:(id) sender {
	NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
	NSURL * url = NULL;
	if([[_outputDir cell] stringValue].length == 0) {
		url = [NSURL fileURLWithPath:[[[_outputDir cell] placeholderString] stringByExpandingTildeInPath]];
	} else {
		url = [NSURL fileURLWithPath:[[_outputDir stringValue] stringByExpandingTildeInPath]];
	}
	[workspace openURL:url];
}

- (IBAction) onChannelStep:(id) sender {
	[_channelsCountLabel setStringValue:[_channelsStepper stringValue]];
	[self invalidateChannels];
}

- (IBAction) onToolbarPlay:(id) sender {
	if(_workQueue.operationCount < 1) return;
	[_workQueue setSuspended:FALSE];
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	[nfc postNotificationName:QCOperationQueueSuspendChange object:nil];
}

- (IBAction) onToolbarStop:(id) sender {
	[_workQueue setSuspended:TRUE];
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	[nfc postNotificationName:QCOperationQueueSuspendChange object:nil];
}

- (void) addFilesFromOpenPanel {
	NSOpenPanel * openPanel = [[NSOpenPanel openPanel] retain];
	[openPanel setAllowedFileTypes:_extensions];
	[openPanel setCanChooseDirectories:TRUE];
	[openPanel setAllowsMultipleSelection:TRUE];
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if(result) {
			NSArray * urls = [openPanel URLs];
			NSMutableArray * files = [NSMutableArray array];
			for(NSURL * url in urls) [files addObject:[url path]];
			[self addFiles:files];
		}
	}];
}

- (IBAction) onOpenFromMenu:(id) sender {
	[self addFilesFromOpenPanel];
}

- (IBAction) onToolbarAddFiles:(id) sender {
	[self addFilesFromOpenPanel];
}

- (IBAction) onToolbarEmptyQueue:(id) sender {
	if(_workOperations.count < 1) return;
	Boolean suspended = [_workQueue isSuspended];
	NSInteger maxConcurrency = [_workQueue maxConcurrentOperationCount];
	[_workQueue setSuspended:TRUE];
	[_workOperationsLock lock];
	[_workOperations removeAllObjects];
	[_workOperationsLock unlock];
	[_tableView reloadData];
	[_workQueue release];
	_workQueue = [[NSOperationQueue alloc] init];
	[_workQueue setMaxConcurrentOperationCount:maxConcurrency];
	[_workQueue setSuspended:suspended];
	[_workQueue setSuspended:TRUE];
}

- (IBAction) onToolbarClear:(id) sender {
	[_workOperationsLock lock];
	NSInteger i = _workOperations.count-1;
	QCOperation * op = NULL;
	for(; i > -1; i--) {
		op = [_workOperations objectAtIndex:i];
		if(op.isFinished && !op.isCancelled) {
			[_workOperations removeObjectAtIndex:i];
		}
	}
	[_workOperationsLock unlock];
	[_tableView reloadData];
	
	if(_workQueue.operationCount < 1) {
		[_workQueue setSuspended:TRUE];
	}
}

- (IBAction) onToolbarRequeue:(id) sender {
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	NSIndexSet * indexes = [_tableView selectedRowIndexes];
	
	[_workOperationsLock lock];
	
	NSInteger i = 0;
	QCOperation * operation = NULL;
	QCOperation * newOperation = NULL;
	
	for(; i < _workOperations.count; i++) {
		operation = [[_workOperations objectAtIndex:i] retain];
		
		if(operation.isExecuting) continue;
		if(!operation.isExecuting && !operation.isCancelled && !operation.isFinished && operation.isInQueue) continue;
		if(indexes.count > 0 && ![indexes containsIndex:i]) continue;
		
		//create new operation
		//newOperation = [[operation copy] autorelease];
		newOperation = [[[QCOperation alloc] init] autorelease];
		newOperation.queue =_workQueue;
		newOperation.isInQueue = TRUE;
		newOperation.file = operation.file;
		newOperation.conversionInfo = operation.conversionInfo;
		newOperation.conversionType = operation.conversionType;
		newOperation.conversionExtension = operation.conversionExtension;
		newOperation.conversionDataFormat = operation.conversionDataFormat;
		newOperation.conversionSampleRate = operation.conversionSampleRate;
		newOperation.conversionChannels = operation.conversionChannels;
		
		//add new observers
		[nfc addObserver:self selector:@selector(onOperationComplete:) name:QCOperationComplete object:newOperation];
		[nfc addObserver:self selector:@selector(onOperationStart:) name:QCOperationStart object:newOperation];
		
		//remove observers for old object
		[nfc removeObserver:self name:QCOperationComplete object:operation];
		[nfc removeObserver:self name:QCOperationCancel object:operation];
		
		//replace queue operation
		[_workOperations replaceObjectAtIndex:i withObject:newOperation];
		
		//add to queue
		[_workQueue addOperation:newOperation];
		
		[newOperation invalidate];
		[operation release];
	}
	
	[_workOperationsLock unlock];
	[_tableView reloadData];
}

- (BOOL) validateToolbarItem:(NSToolbarItem *) theItem {
	if([[theItem itemIdentifier] isEqualToString:@"AddFiles"]) {
		return TRUE;
	}
	
	if([[theItem itemIdentifier] isEqualToString:@"StartQueue"]) {
		if(!_workQueue.isSuspended) return FALSE;
		if(_workQueue.operationCount < 1) return FALSE;
	}
	
	if([[theItem itemIdentifier] isEqualToString:@"StopQueue"]) {
		if(_workQueue.isSuspended) return FALSE;
	}
	
	if([[theItem itemIdentifier] isEqualToString:@"Requeue"]) {
		for(QCOperation * op in _workOperations) {
			if(op.isFinished && !op.isCancelled) {
				return TRUE;
			}
		}
		return FALSE;
	}
	
	if([[theItem itemIdentifier] isEqualToString:@"Clear"]) {
		if(_tableView.numberOfRows < 1) return FALSE;
		
		for(QCOperation * op in _workOperations) {
			if(op.isFinished && !op.isCancelled) return TRUE;
		}
		
		return FALSE;
	}
	
	if([[theItem itemIdentifier] isEqualToString:@"EmptyQueue"]) {
		if(_tableView.numberOfRows < 1) return FALSE;
	}
	
	return TRUE;
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
	[_workOperationsLock lock];
	NSInteger count = _workOperations.count;
	[_workOperationsLock unlock];
	return count;
}

- (NSView *) tableView:(NSTableView *) tableView viewForTableColumn:(NSTableColumn *) tableColumn row:(NSInteger) row {
	QCTableCellView * cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
	[_workOperationsLock lock];
	cell.operation = [_workOperations objectAtIndex:row];
	[_workOperationsLock unlock];
	[cell.operation invalidate];
	return cell;
}

- (NSDragOperation) tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
	NSPasteboard * pboard = [info draggingPasteboard];
	NSDragOperation sourceDragMask = [info draggingSourceOperationMask];
	if([[pboard types] containsObject:NSFilenamesPboardType]) {
		if(sourceDragMask & NSDragOperationLink) {
			return NSDragOperationLink;
		} else if (sourceDragMask & NSDragOperationCopy) {
			return NSDragOperationCopy;
		}
	}
	return NSDragOperationNone;
}

- (void) tableViewSelectionDidChange:(NSNotification *) notification {
	NSIndexSet * indexes = [_tableView selectedRowIndexes];
	
	//no selection, update combo boxes back to what they were with no selections
	/*
	if(_selectedOperations && indexes.count < 1) {
		[_targetFormat selectItemAtIndex:_noSelectionLastTypeIndex];
		NSMutableDictionary * info = [_formats objectForKey:[_targetFormat selectedItem].title];
		
		[_containerFormat removeAllItems];
		[_containerFormat addItemsWithTitles:[info objectForKey:@"extensions"]];
		[_containerFormat selectItemAtIndex:_noSelectionLastContainerIndex];
		if(_noSelectionLastContainerIndex > 0) [_containerFormat setEnabled:TRUE];
		
		[_dataFormat removeAllItems];
		[_dataFormat addItemsWithTitles:[info objectForKey:@"dataFormats"]];
		[_dataFormat selectItemAtIndex:_noSelectionLastDataFormatIndex];
		if(_noSelectionLastDataFormatIndex > 0) [_dataFormat setEnabled:TRUE];
	}
	*/
	
	//1 item selected, update UI.
	if(indexes.count == 1) {
		NSInteger selectedIndex = [indexes firstIndex];
		QCOperation * operation = [_workOperations objectAtIndex:selectedIndex];
		[_targetFormat selectItemWithTitle:[[operation conversionInfo] objectForKey:@"description"]];
		
		[_containerFormat removeAllItems];
		[_containerFormat addItemsWithTitles:[[operation conversionInfo] objectForKey:@"extensions"]];
		[_containerFormat selectItemWithTitle:[operation conversionExtension]];
		
		[_dataFormat removeAllItems];
		[_dataFormat addItemsWithTitles:[[operation conversionInfo] objectForKey:@"dataFormats"]];
		[_dataFormat selectItemWithTitle:[operation conversionDataFormatLabel]];
		
		if([operation conversionOutputDirectory] && [operation conversionOutputDirectory].length > 0) {
			[_outputDir setStringValue:[operation conversionOutputDirectory]];
			[_outputSameDir setState:0];
			[_outputDir setEnabled:TRUE];
			[_outputChooseDir setEnabled:TRUE];
			[_revealOutputDir setEnabled:TRUE];
		} else {
			[_outputSameDir setState:1];
			[_outputDir setEnabled:FALSE];
			[_outputChooseDir setEnabled:FALSE];
			[_revealOutputDir setEnabled:FALSE];
		}
	}
	
	//update last NON SELECTION indexes
	/*
	if(!_selectedOperations || _selectedOperations.count < 1) {
		_noSelectionLastContainerIndex = [_containerFormat indexOfSelectedItem];
		_noSelectionLastDataFormatIndex = [_dataFormat indexOfSelectedItem];
		_noSelectionLastTypeIndex = [_targetFormat indexOfSelectedItem];
	}
	*/
	
	//updated selected oprations
	if(_selectedOperations) [_selectedOperations release];
	_selectedOperations = [[_workOperations objectsAtIndexes:indexes] retain];
}

- (BOOL) tableView:(NSTableView *) tableView acceptDrop:(id<NSDraggingInfo>) info row:(NSInteger) row dropOperation:(NSTableViewDropOperation) dropOperation {
	NSPasteboard * pboard = [info draggingPasteboard];
	if([[pboard types] containsObject:NSFilenamesPboardType]) {
		[self addFiles:[pboard propertyListForType:NSFilenamesPboardType]];
		return YES;
    }
    return NO;
}

- (void) dealloc {
    [super dealloc];
}

@end
