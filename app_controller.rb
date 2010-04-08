# app_controller.rb
# Span
#
# Created by Piet Jaspers on 07/04/10.
# Copyright 2010 10to1. All rights reserved.

class MyAppController < NSObject

	
	def openPreferencesWindow(sender)
		MyPreferencesController.init
	end

end
