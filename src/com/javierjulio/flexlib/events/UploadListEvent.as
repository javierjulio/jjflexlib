package com.javierjulio.flexlib.events
{
	import flash.events.Event;
	
	/**
	 *  The UploadListEvent class represents event objects specific to any 
	 *  UploadList.
	 *
	 *  @see com.javierjulio.flexlib.controls.UploadList
	 */
	public class UploadListEvent extends Event
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
		
		public static const UPLOADS_COMPLETED:String = "uploadsCompleted";
		
		public static const CHANGE:String = "change";
		
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
		public function UploadListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
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
			return new UploadListEvent(type, bubbles, cancelable);
		}
	}
}