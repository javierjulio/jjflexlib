package com.javierjulio.flexlib.events
{
	import flash.events.Event;
	
	public class UploadInputEvent extends Event
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
		
		public static const REMOVING_UPLOAD:String = "removingUpload";
		public static const UPLOAD_CANCELED:String = "uploadCanceled";
		public static const UPLOAD_COMPLETED:String = "uploadCompleted";
		public static const UPLOAD_FAILED:String = "uploadFailed";
		public static const UPLOAD_REMOVED:String = "uploadRemoved";
		public static const UPLOAD_SELECTED:String = "uploadselected";
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 * 
		 * @param type The event type; indicates the action that caused the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
		 */
		public function UploadInputEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override public function clone():Event 
		{
			return new UploadInputEvent(type, bubbles, cancelable);
		}
	}
}