# PJDockProgressIndicator.rb
# Highly modeled after Uli Kusterer's: UKDockProgressIndicator
# go http://www.zathras.de/angelweb/sourcecode.htm
#
# Created by Piet Jaspers on 19/04/10.
# Copyright 2010 10to1. All rights reserved.

class PJDockProgressIndicator < NSObject
	attr_accessor :minValue, :maxValue, :current, :progress

def setNeedsDisplay(bool)
	# Call through to associated view if user wants us to.
    #@progress.setNeedsDisplay bool		
end

def display
	# Call through to associated view if user wants us to.
	progress.display					
end

def current=(current)
	@current=current
    self.updateDockTile

end

def setHidden(bool)
	# Call through to associated view if user wants us to.
    progress.setHidden bool
	if BOOL	then
	NSApp.setApplicationIconImage NSImage.imageNamed "NSApplicationIcon"
			end		
end



# -----------------------------------------------------------------------------
#	updateDockTile:
#		Main drawing bottleneck. This takes our min, max and current values and
#		draws them onto the dock tile. If the MiniProgressGradient.png image is
#		present, this stretches that image to draw the progress bar.
#
#		If no image is present this falls back on the knob color.
# -----------------------------------------------------------------------------

def updateDockTile
    dockIcon = NSImage.alloc.initWithSize(NSMakeSize(128,128))
	dockIcon.lockFocus

	img = NSMakeRect(0, 0, 128, 128)
      	
	# Create a grayscale context for the mask

	colorspace = CGColorSpaceCreateDeviceGray()
	maskContext = CGBitmapContextCreate(nil,dockIcon.size.width,dockIcon.size.height,8,dockIcon.size.width,colorspace,0)
	CGColorSpaceRelease(colorspace)
	
	# Switch to the context for drawing
	maskGraphicsContext = NSGraphicsContext.graphicsContextWithGraphicsPort(maskContext, :flipped => false)
	NSGraphicsContext.saveGraphicsState
	NSGraphicsContext.setCurrentContext maskGraphicsContext
	
	white_image = NSImage.imageNamed("white") 
	white_image.drawInRect(img, :fromRect => NSZeroRect, :operation => NSCompositeCopy,:fraction => 1.0)
	
    # Switch back to the window's context
	NSGraphicsContext.restoreGraphicsState
	
	# Create an image mask from what we've drawn so far
	alphaMask = CGBitmapContextCreateImage(maskContext)
	
	# Draw a white background in the window
	windowContext = NSGraphicsContext.currentContext.graphicsPort

    # Draw the image, clipped by the mask
	CGContextSaveGState(windowContext)
	CGContextClipToMask(windowContext, NSRectToCGRect(img), alphaMask)	
	fillRect = CGRectMake(0, 0, img.size.width, (img.size.height/10) * (@current * 10))

	NSColor.yellowColor.setFill
	CGContextFillRect(windowContext, fillRect)
	CGContextRestoreGState(windowContext)
	CGImageRelease(alphaMask)

	# Now draw the top layer
	# //[[NSImage imageNamed:@"blanco"] drawInRect:img fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	# //[[NSImage imageNamed:@"blanco"] drawInRect:img fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0];
	NSImage.imageNamed("blanco").drawInRect(img, :fromRect => NSZeroRect, :operation => NSCompositeSourceOver, :fraction => 1.0)


	dockIcon.unlockFocus
    
    NSApp.setApplicationIconImage dockIcon
end

end


