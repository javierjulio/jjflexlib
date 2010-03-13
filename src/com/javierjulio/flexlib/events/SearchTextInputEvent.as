package com.javierjulio.flexlib.events
{
	import flash.events.Event;
	
	/**
	 *  The SearchTextInputEvent class represents event objects specific to any 
	 *  SearchTextInput.
	 *
	 *  @see com.javierjulio.flexlib.controls.SearchTextInputEvent
	 */
	public class SearchTextInputEvent extends Event
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
		
	    /**
	     *  The <code>SearchTextInputEvent.ICON_CLICK</code> constant defines the value of the 
	     *  <code>type</code> property of the event object for a <code>iconClick</code> event.
	     * 
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event. For example, if you use 
	     *       <code>mySearchTextInput.addEventListener()</code> to register an event 
	     * 		 mySearchTextInput, is the value of the <code>currentTarget</code>.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
	     *  </table>
	     *
	     *  @eventType iconClick
	     */
	    public static const ICON_CLICK:String = "iconClick";
		
	    //--------------------------------------------------------------------------
	    //
	    //  Constructor
	    //
	    //--------------------------------------------------------------------------
		
	    /**
	     *  Constructor.
	     *
	     *  @param type The event type; indicates the action that caused the event.
	     *
	     *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
	     *
	     *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
	     */
		public function SearchTextInputEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
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
	     *  @private
	     */
	    override public function clone():Event
	    {
	        return new SearchTextInputEvent(type, bubbles, cancelable);
	    }
	}
}