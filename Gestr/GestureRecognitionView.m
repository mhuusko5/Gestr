#import "GestureRecognitionView.h"

@interface GestureRecognitionView ()

@property NSMutableDictionary *touchPaths;
@property NSMutableDictionary *gestureStrokes;
@property NSMutableArray *orderedStrokeIds;

@property NSTimer *startInputTimer;
@property NSTimer *noInputTimer;
@property NSTimer *detectInputTimer;
@property NSTimer *checkPartialGestureTimer;

@property int mouseStrokeIndex;
@property BOOL quickdrawMode;

@property NSDate *lastMultitouchRedraw;
@property NSNumber *initialMultitouchDeviceId;

@end

@implementation GestureRecognitionView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];

	_touchPaths = [NSMutableDictionary dictionary];
	_gestureStrokes = [NSMutableDictionary dictionary];
	_orderedStrokeIds = [NSMutableArray array];

	_lastMultitouchRedraw = [NSDate date];

	return self;
}

- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType {
	if (!_recognitionController.appController.gestureSetupController.setupModel.multitouchOption && _detectingInput) {
		[self resetInputTimers];

		NSPoint drawPoint = [self convertPoint:[event locationInWindow] fromView:nil];

		if ([mouseType isEqualToString:@"down"]) {
			_mouseStrokeIndex++;
		}

		NSNumber *identity = @(_mouseStrokeIndex);

		if (!_gestureStrokes[identity]) {
			[_orderedStrokeIds addObject:identity];
			_gestureStrokes[identity] = [[GestureStroke alloc] init];
		}

		GesturePoint *detectorPoint =
            [[GesturePoint alloc] initWithX:(drawPoint.x / self.frame.size.width) * GUBoundingBoxSize andY:(drawPoint.y / self.frame.size.height) * GUBoundingBoxSize andStrokeId:[identity intValue]];

		[_gestureStrokes[identity] addPoint:detectorPoint];

		if ([mouseType isEqualToString:@"down"]) {
			NSBezierPath *tempPath = [NSBezierPath bezierPath];
			[tempPath setLineWidth:self.frame.size.width / 95];
			[tempPath setLineCapStyle:NSRoundLineCapStyle];
			[tempPath setLineJoinStyle:NSRoundLineJoinStyle];
			[tempPath moveToPoint:drawPoint];

			_touchPaths[identity] = tempPath;
		}
		else if ([mouseType isEqualToString:@"drag"]) {
			NSBezierPath *tempPath = _touchPaths[identity];
			[tempPath lineToPoint:drawPoint];
		}
		else if ([mouseType isEqualToString:@"up"]) {
			if (_mouseStrokeIndex < 3) {
				if (!_detectInputTimer) {
					_detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)_recognitionController.appController.gestureSetupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
				}
			}
			else {
				[self finishDetectingGesture];
				return;
			}

			NSBezierPath *tempPath = _touchPaths[identity];
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

- (void)dealWithMultitouchEvent:(MultitouchEvent *)event {
	if (_recognitionController.appController.gestureSetupController.setupModel.multitouchOption && _detectingInput) {
		if (!_initialMultitouchDeviceId) {
			_initialMultitouchDeviceId = event.deviceIdentifier;
		}

		if ([event.deviceIdentifier isEqualToNumber:_initialMultitouchDeviceId]) {
			[self resetInputTimers];

			if (!_detectInputTimer && event.touches.count == 0) {
				_detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)_recognitionController.appController.gestureSetupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
			}
			else {
				int shouldDrawLimit = _recognitionController.appController.gestureSetupController.setupModel.fullscreenOption ? 32 : 16;
				BOOL shouldDraw = ([_lastMultitouchRedraw timeIntervalSinceNow] * -1000.0 > shouldDrawLimit);

				if (_quickdrawMode && event.touches.count == 3) {
					MultitouchTouch *touch1 = event.touches[0];
					MultitouchTouch *touch2 = event.touches[1];
					MultitouchTouch *touch3 = event.touches[2];
					MultitouchTouch *middleTouch;
					if ((touch1.x > touch2.x && touch1.x < touch3.x) || (touch1.x > touch3.x && touch1.x < touch2.x)) {
						middleTouch = touch1;
					}
					else if ((touch2.x > touch1.x && touch2.x < touch3.x) || (touch2.x > touch3.x && touch2.x < touch1.x)) {
						middleTouch = touch2;
					}
					else {
						middleTouch = touch3;
					}

					NSMutableArray *rearrangedTouches = [event.touches mutableCopy];
					[rearrangedTouches removeObject:middleTouch];
					[rearrangedTouches insertObject:middleTouch atIndex:0];

					event.touches = rearrangedTouches;
				}

				for (MultitouchTouch *touch in event.touches) {
					float combinedTouchVelocity = fabs(touch.velX) + fabs(touch.velY);
					if (touch.state == MTTouchStateTouching && combinedTouchVelocity > 0.06) {
						NSPoint drawPoint = NSMakePoint(touch.x, touch.y);

						NSNumber *identity = touch.identifier;

						if (!_gestureStrokes[identity]) {
							if (_orderedStrokeIds.count < (_quickdrawMode ? 1 : 3)) {
								[_orderedStrokeIds addObject:identity];
								_gestureStrokes[identity] = [[GestureStroke alloc] init];
							}
							else {
								continue;
							}
						}

						GesturePoint *detectorPoint = [[GesturePoint alloc] initWithX:drawPoint.x * GUBoundingBoxSize andY:drawPoint.y * GUBoundingBoxSize andStrokeId:[identity intValue]];

						[_gestureStrokes[identity] addPoint:detectorPoint];

						drawPoint.x *= self.frame.size.width;
						drawPoint.y *= self.frame.size.height;

						NSBezierPath *tempPath;
						if ((tempPath = _touchPaths[identity])) {
							[tempPath lineToPoint:drawPoint];
						}
						else {
							tempPath = [NSBezierPath bezierPath];
							[tempPath setLineWidth:self.frame.size.width / 95];
							[tempPath setLineCapStyle:NSRoundLineCapStyle];
							[tempPath setLineJoinStyle:NSRoundLineJoinStyle];
							[tempPath moveToPoint:drawPoint];

							_touchPaths[identity] = tempPath;
						}
					}
				}

				if (shouldDraw) {
					[self setNeedsDisplay:YES];
					_lastMultitouchRedraw = [NSDate date];
				}
			}
		}
		else if (!_detectInputTimer) {
			_detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)_recognitionController.appController.gestureSetupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
		}
	}
}

- (void)startMultitouchInput {
	[[MultitouchManager sharedMultitouchManager] addMultitouchListenerWithTarget:self callback:@selector(dealWithMultitouchEvent:) andThread:nil];
}

- (void)startDetectingGesture:(BOOL)quick {
	[self resetAll];

	_mouseStrokeIndex = 0;

	_quickdrawMode = quick;

	_initialMultitouchDeviceId = nil;

	_checkPartialGestureTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkPartialGesture) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:_checkPartialGestureTimer forMode:NSEventTrackingRunLoopMode];

	_noInputTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(finishDetectingGestureIgnore) userInfo:nil repeats:NO];

	[self becomeFirstResponder];

	if (_recognitionController.appController.gestureSetupController.setupModel.multitouchOption) {
		[NSApp activateIgnoringOtherApps:YES];
		CGAssociateMouseAndMouseCursorPosition(NO);

		if (quick) {
			[self startMultitouchInput];
		}
		else {
			_startInputTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(startMultitouchInput) userInfo:nil repeats:NO];
		}
	}

	_detectingInput = YES;
}

- (void)finishDetectingGesture {
	[self finishDetectingGesture:NO];
}

- (void)finishDetectingGestureIgnore {
	[self finishDetectingGesture:YES];
}

- (void)finishDetectingGesture:(BOOL)ignore {
	_detectingInput = NO;

	if (_recognitionController.appController.gestureSetupController.setupModel.multitouchOption) {
		[[MultitouchManager sharedMultitouchManager] removeMultitouchListenersWithTarget:self andCallback:@selector(dealWithMultitouchEvent:)];
		CGAssociateMouseAndMouseCursorPosition(YES);
	}

	NSMutableArray *orderedStrokes = [NSMutableArray array];
	if (!ignore) {
		for (int i = 0; i < _orderedStrokeIds.count; i++) {
			[orderedStrokes addObject:_gestureStrokes[_orderedStrokeIds[i]]];
		}
	}

	[self resetAll];

	[_recognitionController recognizeGestureWithStrokes:orderedStrokes];
}

- (void)checkPartialGesture {
	if (_orderedStrokeIds.count > 0) {
		[self performSelectorInBackground:@selector(checkPartialGestureOnNewThread) withObject:nil];
	}
}

- (void)checkPartialGestureOnNewThread {
	NSMutableArray *partialOrderedStrokeIds = [_orderedStrokeIds copy];
	NSMutableDictionary *partialGestureStrokes = [_gestureStrokes copy];

	NSMutableArray *partialOrderedStrokes = [NSMutableArray array];
	for (int i = 0; i < partialOrderedStrokeIds.count; i++) {
		[partialOrderedStrokes addObject:partialGestureStrokes[partialOrderedStrokeIds[i]]];
	}

	[_recognitionController checkPartialGestureWithStrokes:partialOrderedStrokes];
}

- (void)resetInputTimers {
	if (_startInputTimer) {
		[_startInputTimer invalidate];
		_startInputTimer = nil;
	}

	if (_noInputTimer) {
		[_noInputTimer invalidate];
		_noInputTimer = nil;
	}

	if (_detectInputTimer) {
		[_detectInputTimer invalidate];
		_detectInputTimer = nil;
	}
}

- (void)resetAll {
	[self resetInputTimers];

	if (_checkPartialGestureTimer) {
		[_checkPartialGestureTimer invalidate];
		_checkPartialGestureTimer = nil;
	}

	_gestureStrokes = [NSMutableDictionary dictionary];
	_orderedStrokeIds = [NSMutableArray array];
	_touchPaths = [NSMutableDictionary dictionary];

	_lastMultitouchRedraw = [NSDate date];

	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)canBecomeKeyView {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
	if (_detectingInput) {
		for (NSBezierPath *path in[_touchPaths allValues]) {
			[[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.36] setStroke];
			path.lineWidth *= 1.5;
			[path stroke];

			[myGreenColor setStroke];
			path.lineWidth /= 1.5;
			[path stroke];
		}
	}
}

@end
