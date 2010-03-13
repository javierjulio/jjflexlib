package com.javierjulio.flexlib.controls.utilityClasses
{
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;
	
	import mx.core.EdgeMetrics;
	import mx.core.IFlexDisplayObject;
	import mx.core.IRectangularBorder;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.styles.ISimpleStyleClient;
	
	public class BorderLayout
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * The border associated with this border layout.
		 */
		protected var border:IFlexDisplayObject;
		
		//--------------------------------------------------------------------------
	    //
	    //  Constructor
	    //
	    //--------------------------------------------------------------------------
		
	    /**
	     * Constructor.
	     */
		public function BorderLayout()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  borderMetrics
		//----------------------------------
		
		/**
		 * Returns an EdgeMetrics object that has four properties:
		 * <code>left</code>, <code>top</code>, <code>right</code>,
		 * and <code>bottom</code>. The value of each property is equal to the 
		 * thickness of one side of the border, expressed in pixels.
		 * 
		 * <p>Unlike <code>viewMetrics</code>, this property is not
		 * overriden by subclasses of Container.</p>
		 */
		public function get borderMetrics():EdgeMetrics 
		{
			return (border && border is IRectangularBorder) 
					? IRectangularBorder(border).borderMetrics 
					: EdgeMetrics.EMPTY;
		}
		
		//----------------------------------
		//  borderMetricsAndPadding
		//----------------------------------
		
		/**
		 * @private
		 * Cached value containing the border metrics plus the object's padding.
		 */
		private var _borderMetricsAndPadding:EdgeMetrics;
		
		/**
		 * Returns an object that has four properties: <code>left</code>,
		 * <code>top</code>, <code>right</code>, and <code>bottom</code>.
		 * The value of each property is equal to the thickness of the chrome
		 * (visual elements) around the edge of the container plus the thickness 
		 * of the object's padding. The chrome includes the border thickness.
		 */
		public function get borderMetricsAndPadding():EdgeMetrics
		{
			if (!_borderMetricsAndPadding) 
				_borderMetricsAndPadding = new EdgeMetrics();
			
			var o:EdgeMetrics = _borderMetricsAndPadding;
			var bm:EdgeMetrics = borderMetrics;
			
			o.left = bm.left + target.getStyle("paddingLeft");
			o.right = bm.right + target.getStyle("paddingRight");
			o.top = bm.top + target.getStyle("paddingTop");
			o.bottom = bm.bottom + target.getStyle("paddingBottom");
			
			return o;
		}
		
		//----------------------------------
		//  target
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the target property.
		 */
		protected var _target:UIComponent;
		
		/**
		 * The component associated with this border layout.
		 */
		public function get target():UIComponent 
		{
			return _target;
		}
		
		/**
		 * @private
		 */
		public function set target(value:UIComponent):void 
		{
			_target = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Creates the component's border skin if it does not already exist.
		 */
		protected function createBorder():void 
		{
			if (!border && isBorderNeeded()) 
			{
				var borderClass:Class = _target.getStyle("borderSkin");
				
				if (borderClass != null) 
				{
					border = new borderClass();
					border.name = "border";
					
					if (border is IUIComponent) 
						IUIComponent(border).enabled = _target.enabled;
					
					if (border is ISimpleStyleClient) 
						ISimpleStyleClient(border).styleName = _target;
					
					// add the border behind all the children
					_target.addChildAt(DisplayObject(border), 0);
					
					_target.invalidateDisplayList();
				}
			}
		}
		
		/**
		 * @private
		 */
		public function createChildren():void 
		{
			createBorder();
		}
		
		/**
		 * @private
		 */
		private function isBorderNeeded():Boolean 
		{
			// if the borderSkin is a custom class, always assume border is needed
			var c:Class = _target.getStyle("borderSkin");
			
			// lookup the HaloBorder class by name to avoid a linkage dependency
			// Note: this code assumes HaloBorder is the default border skin. If 
			// this is changed in defaults.css, it must also be changed here
			try 
			{
				if (c != getDefinitionByName("mx.skins.halo::HaloBorder")) 
					return true;
			} 
			catch (error:Error) 
			{
				return true;
			}
			
			var v:Object = _target.getStyle("borderStyle");
			if (v) 
			{
				// if borderStyle is "none", then only create a border if the mouseShield style is true
				// (meaning that there is a mouse event listener on this view), we don't create a border
				// if our parent's mouseShieldChildren style is true
				if ((v != "none") || (v == "none" && _target.getStyle("mouseShield"))) 
				{
					return true;
				}
			}
			
			v = _target.getStyle("backgroundColor");
			if (v !== null && v !== "") 
				return true;
			
			v = _target.getStyle("backgroundImage");
			return v != null && v != "";
		}
		
		/**
		 * @private
		 */
		public function measure():void 
		{
		}
		
		/**
		 * @private
		 */
		public function styleChanged(styleProp:String):void 
		{
			var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
			
			// replace the borderSkin if changed
			if (allStyles || styleProp == "borderSkin") 
			{
				if (border) 
				{
					_target.removeChild(DisplayObject(border));
					border = null;
					createBorder();
				}
			}
			
			// create a border object, if none previously existed and one is needed now
			if (allStyles || 
				styleProp == "borderStyle" || 
				styleProp == "backgroundColor" || 
				styleProp == "backgroundImage" || 
				styleProp == "mouseShield" || 
				styleProp == "mouseShieldChildren") 
			{
				createBorder();
			}
		}
		
		/**
		 * @private
		 */
		public function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			if (border) 
			{
				border.move(0, 0);
				border.setActualSize(unscaledWidth, unscaledHeight);
			}
		}
	}
}