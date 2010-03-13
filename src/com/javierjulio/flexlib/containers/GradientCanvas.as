package com.javierjulio.flexlib.containers
{
	import com.javierjulio.flexlib.skins.GradientBorder;
	
	import flash.display.GradientType;
	
	import mx.containers.Canvas;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	//--------------------------------------
	//  Styles
	//--------------------------------------

	/**
	 * Alpha values used for the background gradient fill of the container.
	 * This is a 1 - 1 relationship with fillColors and fillRatios.
	 * 
	 * @default [1,1]
	 */
	[Style(name="fillAlphas", type="Array", arrayType="Number", inherit="no")]

	/**
	 * Colors used to tint the background gradient of the container.
	 * Pass the same color for both values for a "flat" looking control.
	 * This is a 1 - 1 relationship with fillAlphas and fillRatios.
	 * 
	 * @default [0xFFFFFF,0xCCCCCC]
	 */
	[Style(name="fillColors", type="Array", arrayType="uint", format="Color", inherit="no")]

	/**
	 * The ratios for the location of each background gradient fill of the container. 
	 * This is a 1 - 1 relationship with fillAlphas and fillColors.
	 * 
	 * @default [0,255]
	 */
	[Style(name="fillRatios", type="Array", arrayType="uint", format="Color", inherit="no")]

	/**
	 * The focal point ratio for the background gradient fill of the container.
	 * 
	 * @default 0
	 */
	[Style(name="focalPointRatio", type="Number", inherit="no")]

	/**
	 * The gradient angle for the background gradient fill of the container.
	 * 
	 * @default 90
	 */
	[Style(name="gradientAngle", type="Number", inherit="no")]

	/**
	 * The gradient type of linear or radial for the background gradient fill of the container.
	 * 
	 * @default GradientType.LINEAR
	 */
	[Style(name="gradientType", type="String", inherit="no")]

	/**
	 *  Flag to enable rounding for the bottom two corners of the container.
	 *  Does not affect the upper two corners, which are normally round. 
	 *  To configure the upper corners to be square, 
	 *  set <code>cornerRadius</code> to 0.
	 *
	 *  @default true
	 */
	[Style(name="roundedBottomCorners", type="Boolean", inherit="no")]

	/**
	 * The GradientCanvas inherits everything from its superclass Canvas but adds 
	 * new style properties.
	 * 
	 * @mxml
	 * 
	 * <p>The <code>&lt;containers:GradientCanvas&gt;</code> tag inherits all of the tag 
	 * attributes of its superclass and adds the following tag attributes:</p>
	 *  
	 * <pre>
	 * &lt;containers:GradientCanvas
	 *  <strong>Styles</strong>
	 *  fillAlphas="[0xFFFFFF, 0xCCCCCC]"
	 *  fillColors="[1, 1]"
	 *  fillRatios="[0, 255]"
	 *  focalPointRatio="0"
	 *  gradientAngle="90"
	 *  gradientType="linear|radial"
	 *  roundedBottomCorners="false|true"
	 *  &gt;
	 *     ...
	 *     <i>child tags</i>
	 *     ...
	 * &lt;/containers:GradientCanvas&gt;
	 * </pre>
	 * 
	 * @see com.javierjulio.flexlib.containers.GradientHBox
	 * @see com.javierjulio.flexlib.containers.GradientVBox
	 */
	public class GradientCanvas extends Canvas 
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Logger for this class.
		 */
		private static const LOGGER:ILogger = Log.getLogger("com.javierjulio.flexlib.containers.GradientCanvas");
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Trigger to run style defaults when static instance is created.
		 */
		private static var classConstructed:Boolean = constructClass();
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function constructClass():Boolean 
		{
			if (!StyleManager.getStyleDeclaration("GradientCanvas")) 
			{
				// if there is no CSS definition for GradientCanvas we set our default values
				var styles:CSSStyleDeclaration = new CSSStyleDeclaration();
				styles.defaultFactory = function():void 
				{
					this.borderSkin = GradientBorder;
					this.fillAlphas = [1, 1];
					this.fillColors = [0xFFFFFF, 0xCCCCCC];
					this.fillRatios = [0,255];
					this.focalPointRatio = 0;
					this.gradientAngle = 90;
					this.gradientType = GradientType.LINEAR;
					this.roundedBottomCorners = true;
				}
				StyleManager.setStyleDeclaration("GradientCanvas", styles, false);
			}
			return true;
		}

		//--------------------------------------------------------------------------
	    //
	    //  Constructor
	    //
	    //--------------------------------------------------------------------------

	    /**
	     *  Constructor.
	     */
		public function GradientCanvas()
		{
			super();
			
			setStyle("borderSkin", GradientBorder);
		}
	}
}