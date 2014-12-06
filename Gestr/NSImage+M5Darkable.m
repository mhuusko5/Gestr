//
//  NSImage+M5Darkable.m
//  Mathew Huusko V
//
//  Created by Mathew Huusko V on 12/6/14.
//  Copyright (c) 2014 Mathew Huusko V. All rights reserved.
//

#import "NSImage+M5Darkable.h"

#import <objc/runtime.h>
#import <Quartz/Quartz.h>

@implementation NSImage (M5Darkable)

const void* M5_darkableKey = &M5_darkableKey;

- (void)setM5_darkable:(BOOL)M5_darkable {
    objc_setAssociatedObject(self, M5_darkableKey, @(M5_darkable), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)M5_darkable {
    return [objc_getAssociatedObject(self, M5_darkableKey) boolValue];
}

const void* InvertedSelfKey = &InvertedSelfKey;

- (NSImage *)M5_invertedSelf {
	NSImage *invertedSelf = objc_getAssociatedObject(self, InvertedSelfKey);
    
    if (!invertedSelf) {
        CIImage *normalCiImage = [[CIImage alloc] initWithData:[self TIFFRepresentation]];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
        [filter setDefaults];
        [filter setValue:normalCiImage forKey:@"inputImage"];
        
        CIImage *invertedCiImage = [filter valueForKey:@"outputImage"];
        [invertedCiImage drawAtPoint:NSZeroPoint fromRect:NSRectFromCGRect([invertedCiImage extent]) operation:NSCompositeSourceOver fraction:1.0];
        
        NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:invertedCiImage];
        
        invertedSelf = [[NSImage alloc] initWithSize:rep.size];
        [invertedSelf addRepresentation:rep];
        
        objc_setAssociatedObject(self, InvertedSelfKey, invertedSelf, OBJC_ASSOCIATION_RETAIN);
    }

	return invertedSelf;
}

static BOOL darkModeState = NO;

+ (void)RM_updateDarkModeState {
	NSDictionary *globalPersistentDomain = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
	@try {
		NSString *interfaceStyle = [globalPersistentDomain valueForKey:@"AppleInterfaceStyle"];
		darkModeState = [interfaceStyle isEqualToString:@"Dark"];
	} @catch (NSException *exception) {
		darkModeState = NO;
	}
}

+ (void)M5_initialize {
	[self M5_initialize];

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"AppleInterfaceThemeChangedNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
	    [self RM_updateDarkModeState];
	}];

	[self RM_updateDarkModeState];
}

- (void)M5_drawInRect:(NSRect)dstSpacePortionRect fromRect:(NSRect)srcSpacePortionRect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary *)hints {
	if (!darkModeState || !self.M5_darkable) {
		return [self M5_drawInRect:dstSpacePortionRect fromRect:srcSpacePortionRect operation:op fraction:requestedAlpha respectFlipped:respectContextIsFlipped hints:hints];
	}

	return [self.M5_invertedSelf M5_drawInRect:dstSpacePortionRect fromRect:srcSpacePortionRect operation:op fraction:requestedAlpha respectFlipped:respectContextIsFlipped hints:hints];
}

+ (void)load {
	method_exchangeImplementations(class_getClassMethod(self, @selector(initialize)), class_getClassMethod(self, @selector(M5_initialize)));

	method_exchangeImplementations(class_getInstanceMethod(self, @selector(drawInRect:fromRect:operation:fraction:respectFlipped:hints:)), class_getInstanceMethod(self, @selector(M5_drawInRect:fromRect:operation:fraction:respectFlipped:hints:)));
}

@end
