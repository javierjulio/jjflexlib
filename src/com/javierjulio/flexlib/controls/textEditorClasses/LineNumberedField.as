package com.javierjulio.flexlib.controls.textEditorClasses
{
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	
	import mx.core.FlexVersion;
	import mx.core.UITextField;
	
	public class LineNumberedField extends UITextField
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function LineNumberedField()
		{
			super();
			
			autoSize = TextFieldAutoSize.NONE;
			background = true;
			backgroundColor = 0xf4f4f4;
			border = false;
			ignorePadding = false;
			multiline = true;
			selectable = false;
			tabEnabled = false;
			type = TextFieldType.DYNAMIC;
			useRichTextClipboard = true;
			wordWrap = false;
			
			addEventListener(Event.CHANGE, changeHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Returns the number of visible rows.
		 */
		public function get visibleRows():Number 
		{
			return bottomScrollV - scrollV + 1;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On change we want to prevent this event from bubbling.
		 */
		private function changeHandler(event:Event):void 
		{
			event.stopImmediatePropagation();
		}
	}
}