
#import <Cocoa/Cocoa.h>

#define QCDragDropViewDroppedFiles @"QCDragDropViewDroppedFiles"

@interface QCDragDropView : NSView <NSDraggingDestination> {
	NSArray * _droppedFiles;
}

@property (nonatomic,readonly) NSArray * droppedFiles;

@end
