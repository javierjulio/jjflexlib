package com.javierjulio.flexlib.controls
{
	import mx.core.UIComponent;
	import mx.skins.halo.BusyCursor;
	
	/**
	 * The ProgressClock makes it easy to display the busy cursor as a container 
	 * so it can easily be positioned. Much how you would place a ProgressBar in 
	 * MXML you can now do the same with the busyCursor using this ProgressClock 
	 * component. To "disable" it simply hide it (setting visible and/or 
	 * includeInLayout) to false.
	 * 
	 * <p>The ProgressClock control has the following default sizing characteristics:</p>
	 *     <table class="innertable">
	 *        <tr>
	 *           <th>Characteristic</th>
	 *           <th>Description</th>
	 *        </tr>
	 *        <tr>
	 *           <td>Default size</td>
	 *           <td>width: 16 pixels; height: 16 pixels</td>
	 *        </tr>
	 *        <tr>
	 *           <td>Minimum size</td>
	 *           <td>0 pixels</td>
	 *        </tr>
	 *        <tr>
	 *           <td>Maximum size</td>
	 *           <td>10000 by 10000 pixels</td>
	 *        </tr>
	 *     </table>
	 */
	public class ProgressClock extends UIComponent 
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  The default value for the <code>measuredWidth</code> property.
		 *
		 *  @default 16
		 */
		public static const DEFAULT_MEASURED_WIDTH:Number = 16;
		
		/**
		 *  The default value for the <code>measuredMinWidth</code> property.
		 *
		 *  @default 16
		 */
		public static const DEFAULT_MEASURED_MIN_WIDTH:Number = 16;
		
		/**
		 *  The default value for the <code>measuredHeight</code> property.
		 *
		 *  @default 16
		 */
		public static const DEFAULT_MEASURED_HEIGHT:Number = 16;
		
		/**
		 *  The default value for the <code>measuredMinHeight</code> property.
		 *
		 *  @default 16
		 */
		public static const DEFAULT_MEASURED_MIN_HEIGHT:Number = 16;
		
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
		
		/**
		 * Storage for the BusyCursor instance.
		 */
		protected var busyCursor:BusyCursor;
		
		//--------------------------------------------------------------------------
	    //
	    //  Constructor
	    //
	    //--------------------------------------------------------------------------
		
	    /**
	     *  Constructor.
	     */
		public function ProgressClock():void 
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Create the busy cursor instance and add it to the display list.
		 */
		override protected function createChildren():void 
		{
			super.createChildren();
			
			if (!busyCursor) 
			{
				busyCursor = new BusyCursor();
				addChild(busyCursor);
			}
		}
		
		/**
		 * @private
		 * Applies default width and height of 16.
		 */
		override protected function measure():void 
		{
			super.measure();
			
			measuredMinWidth = DEFAULT_MEASURED_MIN_WIDTH;
			measuredWidth = DEFAULT_MEASURED_WIDTH;
			
			measuredMinHeight = DEFAULT_MEASURED_MIN_HEIGHT;
			measuredHeight = DEFAULT_MEASURED_HEIGHT;
		}
		
		/**
		 * @private
		 * Respond to size changes by setting the position and size of the busy 
		 * cursor.
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (busyCursor) 
			{
				busyCursor.width = unscaledWidth;
				busyCursor.height = unscaledHeight;
				busyCursor.x = unscaledWidth / 2;
				busyCursor.y = unscaledHeight / 2;
			}
		}
	}
}