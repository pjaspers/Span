# preferences_controller.rb
# Span
#
# Created by Piet Jaspers on 07/04/10.
# Copyright 2010 10to1. All rights reserved.

class MyPreferencesController < NSWindowController
  attr_accessor :url_field, :secret_field
	
  Defaults = {
    'SpicUrl' => 'url',
    'SpicSecret' => 'sec'
  }
  NSUserDefaults.standardUserDefaults.registerDefaults Defaults

  def init
    initWithWindowNibName('Preferences')
    defaults = NSUserDefaults.standardUserDefaults
	self
  end
	
	def save_button_clicked(sender)
		NSUserDefaults.standardUserDefaults.setObject @url_field.stringValue, forKey:'SpicUrl'
		NSUserDefaults.standardUserDefaults.setObject @secret_field.stringValue, forKey:'SpicSecret'
	end
  def self.sharedPreferenceController
    @instance ||= alloc.init
  end

  def windowDidLoad
      defaults = NSUserDefaults.standardUserDefaults
	@url_field.setStringValue(defaults.stringForKey('SpicUrl'))
    @secret_field.setStringValue(defaults.stringForKey('SpicSecret'))
  end
  
	def windowWillClose(note)
		NSUserDefaults.standardUserDefaults.setObject @url_field.stringValue, forKey:'SpicUrl'
		NSUserDefaults.standardUserDefaults.setObject @secret_field.stringValue, forKey:'SpicSecret'
	end


end

