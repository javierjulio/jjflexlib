package com.javierjulio.flexlib.controls
{
	import com.javierjulio.flexlib.controls.utilityClasses.BorderLayout;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Label;
	import mx.core.EdgeMetrics;
	import mx.core.IFlexDisplayObject;
	import mx.core.mx_internal;
	import mx.core.UITextField;
	import mx.skins.halo.HaloBorder;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 *  Alpha level of the color defined by the <code>backgroundColor</code>
	 *  property, of the image or SWF file defined by the <code>backgroundImage</code>
	 *  style.
	 *  Valid values range from 0.0 to 1.0. For most controls, the default value is 1.0, 
	 *  but for ToolTip controls, the default value is 0.95 and for Alert controls, the default value is 0.9.
	 *  
	 *  @default 1.0
	 */
	[Style(name="backgroundAlpha", type="Number", inherit="no")]
	
	/**
	 *  Background color of a component.
	 *  You can have both a <code>backgroundColor</code> and a
	 *  <code>backgroundImage</code> set.
	 *  Some components do not have a background.
	 *  The DataGrid control ignores this style.
	 *  The default value is <code>undefined</code>, which means it is not set.
	 *  If both this style and the <code>backgroundImage</code> style
	 *  are <code>undefined</code>, the component has a transparent background.
	 *
	 *  <p>For the Application container, this style specifies the background color
	 *  while the application loads, and a background gradient while it is running. 
	 *  Flex calculates the gradient pattern between a color slightly darker than 
	 *  the specified color, and a color slightly lighter than the specified color.</p>
	 * 
	 *  <p>The default skins of most Flex controls are partially transparent. As a result, the background color of 
	 *  a container partially "bleeds through" to controls that are in that container. You can avoid this by setting the 
	 *  alpha values of the control's <code>fillAlphas</code> property to 1, as the following example shows:
	 *  <pre>
	 *  &lt;mx:<i>Container</i> backgroundColor="0x66CC66"/&gt;
	 *      &lt;mx:<i>ControlName</i> ... fillAlphas="[1,1]"/&gt;
	 *  &lt;/mx:<i>Container</i>&gt;</pre>
	 *  </p>
	 */
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	
	/**
	 *  Background color of the component when it is disabled.
	 *  The global default value is <code>undefined</code>.
	 *  The default value for List controls is <code>0xDDDDDD</code> (light gray).
	 *  If a container is disabled, the background is dimmed, and the degree of
	 *  dimming is controlled by the <code>disabledOverlayAlpha</code> style.
	 */
	[Style(name="backgroundDisabledColor", type="uint", format="Color", inherit="yes")]
	
	/**
	 *  Background image of a component.  This can be an absolute or relative
	 *  URL or class.  You can either have both a <code>backgroundColor</code> and a
	 *  <code>backgroundImage</code> set at the same time. The background image is displayed
	 *  on top of the background color.
	 *  The default value is <code>undefined</code>, meaning "not set".
	 *  If this style and the <code>backgroundColor</code> style are undefined,
	 *  the component has a transparent background.
	 * 
	 *  <p>The default skins of most Flex controls are partially transparent. As a result, the background image of 
	 *  a container partially "bleeds through" to controls that are in that container. You can avoid this by setting the 
	 *  alpha values of the control's <code>fillAlphas</code> property to 1, as the following example shows:
	 *  <pre>
	 *  &lt;mx:<i>Container</i> backgroundColor="0x66CC66"/&gt;
	 *      &lt;mx:<i>ControlName</i> ... fillAlphas="[1,1]"/&gt;
	 *  &lt;/mx:<i>Container</i>&gt;</pre>
	 *  </p>
	 */
	[Style(name="backgroundImage", type="Object", format="File", inherit="no")]
	
	/**
	 *  Scales the image specified by <code>backgroundImage</code>
	 *  to different percentage sizes.
	 *  A value of <code>"100%"</code> stretches the image
	 *  to fit the entire component.
	 *  To specify a percentage value, you must include the percent sign (%).
	 *  The default for the Application container is <code>100%</code>.
	 *  The default value for all other containers is <code>auto</code>, which maintains
	 *  the original size of the image.
	 */
	[Style(name="backgroundSize", type="String", inherit="no")]
	
	/**
	 *  Color of the border.
	 *  The default value depends on the component class;
	 *  if not overridden for the class, the default value is <code>0xB7BABC</code>.
	 */
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	
	/**
	 *  Bounding box sides.
	 *  A space-delimited String that specifies the sides of the border to show.
	 *  The String can contain <code>"left"</code>, <code>"top"</code>,
	 *  <code>"right"</code>, and <code>"bottom"</code> in any order.
	 *  The default value is <code>"left top right bottom"</code>,
	 *  which shows all four sides.
	 *
	 *  This style is only used when borderStyle is <code>"solid"</code>.
	 */
	[Style(name="borderSides", type="String", inherit="no")]
	
	/**
	 *  The border skin class of the component. 
	 *  The mx.skins.halo.HaloBorder class is the default value for all components 
	 *  that do not explicitly set their own default. 
	 *  The Panel container has a default value of mx.skins.halo.PanelSkin.
	 *  To determine the default value for a component, see the default.css file.
	 *
	 *  @default mx.skins.halo.HaloBorder
	 */
	[Style(name="borderSkin", type="Class", inherit="no")]
	
	/**
	 *  Bounding box style.
	 *  The possible values are <code>"none"</code>, <code>"solid"</code>,
	 *  <code>"inset"</code>, and <code>"outset"</code>.
	 *  The default value depends on the component class;
	 *  if not overridden for the class, the default value is <code>"inset"</code>.
	 *  The default value for most Containers is <code>"none"</code>.
	 *  
	 *  @default "none"
	 */
	[Style(name="borderStyle", type="String", enumeration="inset,outset,solid,none", inherit="no")]
	
	/**
	 *  Bounding box thickness.
	 *  Only used when <code>borderStyle</code> is set to <code>"solid"</code>.
	 *
	 *  @default 1
	 */
	[Style(name="borderThickness", type="Number", format="Length", inherit="no")]
	
	/**
	 *  Radius of component corners.
	 *  The default value depends on the component class;
	 *  if not overriden for the class, the default value is 0.
	 *  The default value for ApplicationControlBar is 5.
	 */
	[Style(name="cornerRadius", type="Number", format="Length", inherit="no")]
	
	/**
	 *  Boolean property that specifies whether the component has a visible
	 *  drop shadow.
	 *  This style is used with <code>borderStyle="solid"</code>.
	 *  The default value is <code>false</code>.
	 *
	 *  <p><b>Note:</b> For drop shadows to appear on containers, set
	 *  <code>backgroundColor</code> or <code>backgroundImage</code> properties.
	 *  Otherwise, the shadow appears behind the container because
	 *  the default background of a container is transparent.</p>
	 */
	[Style(name="dropShadowEnabled", type="Boolean", inherit="no")]
	
	/**
	 *  Color of the drop shadow.
	 *
	 *  @default 0x000000
	 */
	[Style(name="dropShadowColor", type="uint", format="Color", inherit="yes")]
	
	/**
	 *  Gap between the label and icon.
	 * 
	 *  @default 8
	 */
	[Style(name="horizontalGap", type="Number", format="Length", inherit="no")]
	
	/**
	 * Name of the class to use as the default icon. 
	 * Setting any other icon style overrides this setting.
	 * 
	 * @default null
	 */
	[Style(name="icon", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 *  Flag to enable rounding for the bottom two corners of the container.
	 *  Does not affect the upper two corners, which are normally round. 
	 *  To configure the upper corners to be square, 
	 *  set <code>cornerRadius</code> to 0.
	 *
	 *  @default false
	 */
	[Style(name="roundedBottomCorners", type="Boolean", inherit="no")]
	
	/**
	 *  Direction of the drop shadow.
	 *  Possible values are <code>"left"</code>, <code>"center"</code>,
	 *  and <code>"right"</code>.
	 *
	 *  @default "center"
	 */
	[Style(name="shadowDirection", type="String", enumeration="left,center,right", inherit="no")]
	
	/**
	 *  Distance of the drop shadow.
	 *  If the property is set to a negative value, the shadow appears above the component.
	 *
	 *  @default 2
	 */
	[Style(name="shadowDistance", type="Number", format="Length", inherit="no")]
	
	public class LabelHeader extends Label
	{
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Trigger when static instance is created to set default borderStyle.
		 */
		private static var classConstructed:Boolean = constructClass();
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Triggered to run when static instance is created so default styles are 
		 * set.
		 */
		private static function constructClass():Boolean 
		{
			if (!StyleManager.getStyleDeclaration("LabelHeader"))
			{
				// there is no CSS definition for LabelHeader so set default values
				var styles:CSSStyleDeclaration = new CSSStyleDeclaration();
				styles.defaultFactory = function():void 
				{
					this.borderSkin = HaloBorder;
					this.borderStyle = "none";
				}
				StyleManager.setStyleDeclaration("LabelHeader", styles, false);
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function LabelHeader()
		{
			super();
			
			borderLayout.target = this;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Storage for the BorderLayout instance that handles the creation and 
		 * supprt of the HaloBorder skin.
		 */
		protected var borderLayout:BorderLayout = new BorderLayout();
		
		/**
		 * Storage for the icon display instance.
		 */
		protected var currentIcon:IFlexDisplayObject;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void 
		{
			// create our border as a normal child since this component is a 
			// UIComponent and not a Container so we have no rawChildren support
			borderLayout.createChildren();
			
			super.createChildren();
			
			var newIconClass:Class = getStyle("icon") as Class;
			
			if (!currentIcon && newIconClass != null) 
			{
				currentIcon = new newIconClass();
				addChild(currentIcon as DisplayObject);
			}
		}
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void 
		{
			// since we are doing the same border creation as done in Container I noticed 
			// first it did border related stuff before calling parent, so we'll do the same
			borderLayout.styleChanged(styleProp);
			
			super.styleChanged(styleProp);
			
			if (styleProp == "styleName" || styleProp == "icon") 
			{
				if (currentIcon) 
				{
					removeChild(currentIcon as DisplayObject);
					currentIcon = null;
					invalidateDisplayList();
				}
				
				var newIconClass:Class = getStyle("icon") as Class;
				
				if (!currentIcon && newIconClass != null) 
				{
					currentIcon = new newIconClass();
					addChild(currentIcon as DisplayObject);
					invalidateDisplayList();
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void 
		{
			super.measure();
			
			var vm:EdgeMetrics = borderLayout.borderMetrics;
			var horizontalGap:Number = getStyle("horizontalGap");
			var iconWidthWithGap:Number = currentIcon ? currentIcon.width + horizontalGap : 0;
			var iconHeight:Number = currentIcon ? currentIcon.height : 0;
			
			// since the calculation in the parent class is sufficient we just need 
			// to further add the icon width, horizontalGap, and the left and right 
			// borders and padding, if no icon is present, the horizontalGap is 
			// ignored and we only add the borders and padding
			measuredMinWidth += iconWidthWithGap + vm.left + vm.right;
			measuredWidth += iconWidthWithGap + vm.left + vm.right;
			
			// in case the icon is larger in height than the text plus the borders 
			// and padding, adjust the height and choose whichever is largest
			measuredMinHeight = Math.max(measuredMinHeight + vm.top + vm.bottom, (iconHeight + vm.top + vm.bottom));
			measuredHeight = Math.max(measuredHeight + vm.top + vm.bottom, (iconHeight + vm.top + vm.bottom));
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// size and position the border appropriately
			borderLayout.layoutChrome(unscaledWidth, unscaledHeight);
			
			var horizontalGap:Number = getStyle("horizontalGap");
			
			var bm:EdgeMetrics = borderLayout.borderMetricsAndPadding;
			
			var textWidth:Number = unscaledWidth - bm.left - bm.right;
			var textHeight:Number = unscaledHeight - bm.top - bm.bottom;
			
			var x:Number = bm.left;
			var y:Number = bm.top;
			
			if (currentIcon) 
			{
				// position the icon to the top left corner
				currentIcon.setActualSize(currentIcon.measuredWidth, currentIcon.measuredHeight);
				currentIcon.move(x, (unscaledHeight - currentIcon.height) / 2);//y + UITextField.TEXT_HEIGHT_PADDING);
				
				//since we have an icon the TextField will be resized and repositioned
				textWidth -= currentIcon.width + horizontalGap;
				x += currentIcon.width + horizontalGap;
			}
			
			// position the textField after the icon (if one exists)
			textField.setActualSize(textWidth, textHeight);
			textField.move(x, y);
		}
	}
}