package com.javierjulio.flexlib.events
{
	import flash.events.Event;
	
	/**
	 * The WindowEvent class represents event objects specific to any type of 
	 * custom window Flex component. In this case created as a generic event but 
	 * used with CanvasWindow.
	 * 
	 * @see com.javierjulio.flexlib.containers.CanvasWindow
	 */
	public class WindowEvent extends Event
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
		
	    /**
	     *  The <code>WindowEvent.COLLAPSE</code> constant defines the value of the 
	     *  <code>type</code> property of the event object for a <code>collapse</code> event.
	     * 
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event. For example, if you use 
	     *       <code>myObject.addEventListener()</code> to register an event 
	     * 		 myObject, is the value of the <code>currentTarget</code>.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
	     *  </table>
	     *
	     *  @eventType collapse
	     */
	    public static const COLLAPSE:String = "collapse";
		
	    /**
	     *  The <code>WindowEvent.RESIZE</code> constant defines the value of the 
	     *  <code>type</code> property of the event object for a <code>resize</code> event.
	     * 
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event. For example, if you use 
	     *       <code>myObject.addEventListener()</code> to register an event 
	     * 		 myObject, is the value of the <code>currentTarget</code>.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
	     *  </table>
	     *
	     *  @eventType resize
	     */
	    public static const RESIZE:String = "resize";
		
	    /**
	     *  The <code>WindowEvent.RESTORE</code> constant defines the value of the 
	     *  <code>type</code> property of the event object for a <code>restore</code> event.
	     * 
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event. For example, if you use 
	     *       <code>myObject.addEventListener()</code> to register an event 
	     * 		 myObject, is the value of the <code>currentTarget</code>.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
	     *  </table>
	     *
	     *  @eventType collapse
	     */
	    public static const RESTORE:String = "restore";
		
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
		public function WindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
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
	        return new WindowEvent(type, bubbles, cancelable);
	    }
	}
}