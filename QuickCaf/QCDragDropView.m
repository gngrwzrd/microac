
#import "QCDragDropView.h"

@implementation QCDragDropView
@synthesize droppedFiles = _droppedFiles;

- (id) initWithFrame:(NSRect) frameRect {
	if(!(self = [super initWithFrame:frameRect])) return nil;
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
	return self;
}

- (NSDragOperation) draggingEntered:(id <NSDraggingInfo>) sender {
	NSPasteboard * pboard = [sender draggingPasteboard];
	NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
	if([[pboard types] containsObject:NSFilenamesPboardType]) {
		if(sourceDragMask & NSDragOperationLink) {
			return NSDragOperationLink;
		} else if (sourceDragMask & NSDragOperationCopy) {
			return NSDragOperationCopy;
		}
	}
	return NSDragOperationNone;
}

- (BOOL) performDragOperation:(id <NSDraggingInfo>) sender {
	NSPasteboard * pboard = [sender draggingPasteboard];
	if([[pboard types] containsObject:NSFilenamesPboardType]) {
		_droppedFiles = [[pboard propertyListForType:NSFilenamesPboardType] retain];
		NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
		[nfc postNotificationName:QCDragDropViewDroppedFiles object:self];
		return YES;
    }
    return NO;
}

@end
