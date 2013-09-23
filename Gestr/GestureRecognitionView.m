#import "GestureRecognitionView.h"

@implementation GestureRecognitionView

@synthesize recognitionController, detectingInput;

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
    
	touchPaths = [[NSMutableDictionary alloc] init];
	gestureStrokes = [NSMutableDictionary dictionary];
	orderedStrokeIds = [NSMutableArray array];
    
	return self;
}

- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType {
	if (!recognitionController.appController.gestureSetupController.useMultitouchTrackpad && detectingInput) {
		NSPoint drawPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        
		[recognitionController.appController.gestureSetupController.drawNowText setAlphaValue:0.0];
        
		if ([mouseType isEqualToString:@"down"]) {
			mouseStrokeIndex++;
		}
        
		NSNumber *identity = [NSNumber numberWithInt:mouseStrokeIndex];
        
		if (![gestureStrokes objectForKey:identity]) {
			[orderedStrokeIds addObject:identity];
			[gestureStrokes setObject:[[GestureStroke alloc] init] forKey:identity];
		}
        
		GesturePoint *detectorPoint = [[GesturePoint alloc] initWithX:(drawPoint.x / self.frame.size.width) * boundingBoxSize andY:(drawPoint.y / self.frame.size.height) * boundingBoxSize andStroke:[identity intValue]];
        
		[[gestureStrokes objectForKey:identity] addPoint:detectorPoint];
        
		if (shouldDetectTimer) {
			[shouldDetectTimer invalidate];
			shouldDetectTimer = nil;
		}
        
		if ([mouseType isEqualToString:@"down"]) {
			NSBezierPath *tempPath = [NSBezierPath bezierPath];
			[tempPath setLineWidth:self.frame.size.width / 95];
			[tempPath setLineCapStyle:NSRoundLineCapStyle];
			[tempPath setLineJoinStyle:NSRoundLineJoinStyle];
			[tempPath moveToPoint:drawPoint];
            
			[touchPaths setObject:tempPath forKey:identity];
		}
		else if ([mouseType isEqualToString:@"drag"]) {
			NSBezierPath *tempPath = [touchPaths objectForKey:identity];
			[tempPath lineToPoint:drawPoint];
		}
		else if ([mouseType isEqualToString:@"up"]) {
			if (!shouldDetectTimer) {
				shouldDetectTimer = [NSTimer scheduledTimerWithTimeInterval:((float)recognitionController.appController.gestureSetupController.readingDelayNumber) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
			}
            
			NSBezierPath *tempPath = [touchPaths objectForKey:identity];
			[tempPath lineToPoint:drawPoint];
		}
        
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	[self dealWithMouseEvent:theEvent ofType:@"down"];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	[self dealWithMouseEvent:theEvent ofType:@"drag"];
}

- (void)mouseUp:(NSEvent *)theEvent {
	[self dealWithMouseEvent:theEvent ofType:@"up"];
}

- (void)startDetectingGesture {
	[self resetAll];
    
	detectingInput = YES;
    
	mouseStrokeIndex = 0;
    
	checkPartialGestureTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(checkPartialGesture) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:checkPartialGestureTimer forMode:NSEventTrackingRunLoopMode];
    
	[self becomeFirstResponder];
}

- (void)checkPartialGesture {
	NSMutableArray *partialOrderedStrokeIds = [orderedStrokeIds copy];
	NSMutableDictionary *partialGestureStrokes = [gestureStrokes copy];
    
	if ([partialOrderedStrokeIds count] > 0) {
		NSMutableArray *partialOrderedStrokes = [NSMutableArray array];
		for (int i = 0; i < [partialOrderedStrokeIds count]; i++) {
			[partialOrderedStrokes addObject:[partialGestureStrokes objectForKey:[partialOrderedStrokeIds objectAtIndex:i]]];
		}
        
		[recognitionController checkPartialGestureWithStrokes:[partialOrderedStrokes copy]];
	}
}

- (void)finishDetectingGesture {
	[self finishDetectingGesture:NO];
}

- (void)finishDetectingGesture:(BOOL)ignore {
	detectingInput = NO;
    
	NSMutableArray *orderedStrokes = [NSMutableArray array];
	if (!ignore) {
		for (int i = 0; i < [orderedStrokeIds count]; i++) {
			[orderedStrokes addObject:[gestureStrokes objectForKey:[orderedStrokeIds objectAtIndex:i]]];
		}
	}
    
	[NSThread detachNewThreadSelector:@selector(recognizeGestureWithStrokes:) toTarget:recognitionController withObject:[orderedStrokes copy]];
    
	[self resetAll];
}

- (void)resetAll {
	if (checkPartialGestureTimer) {
		[checkPartialGestureTimer invalidate];
		checkPartialGestureTimer = nil;
	}
    
	if (shouldDetectTimer) {
		[shouldDetectTimer invalidate];
		shouldDetectTimer = nil;
	}
    
	gestureStrokes = [NSMutableDictionary dictionary];
	orderedStrokeIds = [NSMutableArray array];
	[touchPaths removeAllObjects];
    
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)canBecomeKeyView {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
	if (detectingInput) {
		[[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.35] setStroke];
		for (NSBezierPath *path in[touchPaths allValues]) {
			NSBezierPath *whitePath = [path copy];
			[whitePath setLineWidth:[path lineWidth] * 1.4];
			[whitePath stroke];
		}
        
		[myGreenColor setStroke];
		for (NSBezierPath *path in[touchPaths allValues]) {
			[path stroke];
		}
	}
}

@end
