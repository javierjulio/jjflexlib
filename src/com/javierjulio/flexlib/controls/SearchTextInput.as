package com.javierjulio.flexlib.controls
{
	import com.javierjulio.flexlib.events.SearchTextInputEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import flexlib.controls.PromptingTextInput;
	
	import mx.controls.Button;
	import mx.core.EdgeMetrics;
	import mx.core.IFlexDisplayObject;
	import mx.core.IRectangularBorder;
	import mx.core.mx_internal;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when the user clicks on the search icon.
	 * 
	 * @eventType com.javierjulio.flexlib.events.SearchTextInputEvent
	 */
	[Event(name="iconClick", type="com.javierjulio.flexlib.events.SearchTextInputEvent")]
	
	//--------------------------------------
	//  Skins
	//--------------------------------------
	
	/**
	 * The clear button default skin.
	 * Name of the class to use as the default skin for the background and border.
	 *
	 * @default /assets/images/searchTextInput_clearButton.png
	 */
	[Style(name="clearSkin", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 * Name of the class to use as the skin for the background and border
	 * when the button is not selected and the mouse is not over the control.
	 *
	 * @default /assets/images/searchTextInput_clearButton.png
	 */
	[Style(name="clearUpSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border 
	 * when the button is not selected and the mouse is over the control.
	 * 
	 * @default /assets/images/searchTextInput_clearButton.png
	 */
	[Style(name="clearOverSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border 
	 * when the button is not selected and the mouse button is down.
	 *
	 * @default /assets/images/searchTextInput_clearButton.png
	 */
	[Style(name="clearDownSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border 
	 * when the button is not selected and is disabled.
	 *
	 * @default /assets/images/searchTextInput_clearButton.png
	 */
	[Style(name="clearDisabledSkin", type="Class", inherit="no")]
	
	/**
	 *  Gap between the icon, the text field and the clear button.
	 * 
	 *  @default 2
	 */
	[Style(name="horizontalGap", type="Number", format="Length", inherit="no")]
	
	/**
	 * Name of the class to use as the default icon. 
	 * Setting any other icon style overrides this setting.
	 * 
	 * @default /assets/images/searchTextInput_search.png
	 */
	[Style(name="icon", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 * The SearchTextInput extends the flexLib's PromptingTextInput class to provide 
	 * a component that appears like common search text input's like those seen on 
	 * Mac or Windows. By default a magnifying glass appears as the default icon on 
	 * the left side while an X (close button) appears on the right.
	 * 
	 * @mxml
	 *
	 * <p>The <code>&lt;SearchTextInput&gt;</code> tag inherits all of the tag
	 * attributes of its superclass (PromptingTextInput) and adds the following 
	 * tag attributes:</p>
	 *
	 * <pre>
	 * &lt;ResizableTextArea
	 *   <strong>Styles</strong>
	 *   clearDisabledSkin="clearSkin"
	 *   clearDownSkin="clearSkin"
	 *   clearOverSkin="clearSkin"
	 *   clearUpSkin="clearSkin"
	 *   horizontalGap="2"
	 * 	 icon=""
	 * 
	 *   <strong>Events</strong>
	 *   iconClick=""
	 * /&gt;
	 * </pre>
	 * 
	 * @see mx.controls.TextArea
	 */
	public class SearchTextInput extends PromptingTextInput
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const LOGGER:ILogger = Log.getLogger("com.javierjulio.flexlib.controls.SearchTextInput");
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Trigger when static instance is created.
		 */
		private static var classConstructed:Boolean = constructClass();
		
		/**
		 * @private
		 * Storage for the default clear button skin.
		 */
		[Embed(source="/assets/images/searchTextInput_clearButton.png")]
		private static var defaultClearButtonSkin:Class;
		
		/**
		 * @private
		 * Storage for the default icon skin.
		 */
		[Embed(source="/assets/images/searchTextInput_search.png")]
		private static var defaultSearchIconSkin:Class;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Triggered to run when static instance is created so default styles are set.
		 */
		private static function constructClass():Boolean 
		{
			if (!StyleManager.getStyleDeclaration("SearchTextInput"))
			{
				// there is no CSS definition for SearchTextInput so set default values
				var styles:CSSStyleDeclaration = new CSSStyleDeclaration();
				styles.defaultFactory = function():void 
				{
					this.clearSkin = defaultClearButtonSkin;
					this.horizontalGap = 2;
					this.icon = defaultSearchIconSkin;
				}
				StyleManager.setStyleDeclaration("SearchTextInput", styles, false);
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Internal storage for the clear button.
		 */
		protected var clearButton:Button;
		
		/**
		 * Internal storage for the search icon.
		 */
		protected var searchIcon:IFlexDisplayObject;
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function SearchTextInput() 
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  clearStyleFilters
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the clearStyleFilters property.
		 */
		private static var _clearStyleFilters:Object = 
		{
			"clearUpSkin" : "clearUpSkin",
			"clearOverSkin" : "clearOverSkin",
			"clearDownSkin" : "clearDownSkin",
			"clearDisabledSkin" : "clearDisabledSkin",
			"clearSkin" : "clearSkin",
			"repeatDelay" : "repeatDelay",
			"repeatInterval" : "repeatInterval"
		}
		
		/**
		 * The set of styles to pass from the TextInput to the clear search button.
		 * 
		 * @see mx.styles.StyleProxy
		 */
		protected function get clearStyleFilters():Object
		{
			return _clearStyleFilters;
		}
		
		//----------------------------------
		//  enabled
		//----------------------------------
		
		/**
		 * @private
		 */
		private var enabledChanged:Boolean = false;
		
		/**
		 * @private
		 * Disable searchIcon and clearButton when we're disabled.
		 */
		override public function set enabled(value:Boolean):void 
		{
			if (value == enabled) 
				return;
			
			// no need to call invalidateProperties as by setting 
			// the parent value it handles that for us already
			super.enabled = value;
			enabledChanged = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			// TODO: consider show type properties, showIcon, showCloseButton, 
			
			if (enabledChanged) 
			{
				// TODO: need to disable searchIcon, must find better component to use ... button?
				clearButton.enabled = enabled;
				
				enabledChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void 
		{
			super.createChildren();
			
			var newIconClass:Class = Class(getStyle("icon"));
			
			if (!searchIcon && newIconClass != null) 
			{
				searchIcon = new newIconClass();
				searchIcon.addEventListener(MouseEvent.CLICK, searchIcon_clickHandler, false, 0, true);
				addChild(searchIcon as DisplayObject);
			}
			
			if (!clearButton) 
			{
				clearButton = new Button();
				clearButton.enabled = enabled;
				clearButton.focusEnabled = false;
				clearButton.styleName = new StyleProxy(this, clearStyleFilters);
				clearButton.upSkinName = "clearUpSkin";
				clearButton.overSkinName = "clearOverSkin";
				clearButton.downSkinName = "clearDownSkin";
				clearButton.disabledSkinName = "clearDisabledSkin";
				clearButton.skinName = "clearSkin";
				clearButton.visible = false;
				clearButton.addEventListener(MouseEvent.CLICK, clearButton_clickHandler, false, 0, true);
				addChild(clearButton);
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var bm:EdgeMetrics;
			
			if (border) 
			{
				border.setActualSize(unscaledWidth, unscaledHeight);
				bm = border is IRectangularBorder ? 
							IRectangularBorder(border).borderMetrics : EdgeMetrics.EMPTY;
			}
			else 
				bm = EdgeMetrics.EMPTY;
			
			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			var paddingTop:Number = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			var leftEdge:Number = bm.left + bm.right + paddingLeft;
			var rightEdge:Number = bm.left + bm.right + paddingRight;
			var edgePad:Number = bm.left + bm.right;
			var heightPad:Number = bm.top + bm.bottom + 1 + paddingTop + paddingBottom;
			
			// position the search icon to the left
			searchIcon.setActualSize(searchIcon.measuredWidth, searchIcon.measuredHeight);
			searchIcon.move(leftEdge, (unscaledHeight - searchIcon.height) / 2);
			
			// the textField now gets aligned inbetween the icon and clear button
			// since we position the icon and clear button from the edges, we can 
			// apply the horizontalGap to the edges of the textField and we're done
			var widthPad:Number = getStyle("horizontalGap");
			textField.setActualSize(Math.max(0, unscaledWidth - leftEdge - rightEdge - (widthPad * 2) - searchIcon.measuredWidth - clearButton.measuredWidth), 
									Math.max(0, unscaledHeight - heightPad));
			textField.x = searchIcon.measuredWidth + edgePad + (widthPad * 2);
			
			// position the clear button to the right
			clearButton.setActualSize(clearButton.measuredWidth, clearButton.measuredHeight);
			clearButton.move(unscaledWidth - clearButton.measuredWidth - rightEdge, (unscaledHeight - clearButton.height) / 2);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Helper to toggle the visibility of the clear search button. If no text 
		 * has been inputted then the clear button is hidden, otherwise its visible.
		 */
		protected function toggleClearButtonDisplay():void 
		{
			if (text.length > 0) 
				clearButton.visible = true;
			else 
				clearButton.visible = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden event handlers: PromptingTextInput
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Overrides the PromptingTextInput's Event.CHANGE handler so we can toggle 
		 * the display of the clear search button.
		 */
		override protected function handleChange(event:Event):void 
		{
			super.handleChange(event);
			
			toggleClearButtonDisplay();
		}
		
		/**
		 * Overrides the PromptingTextInput's FocusEvent.FOCUS_IN handler so we 
		 * can toggle the display of the clear search button.
		 */
		override protected function handleFocusIn(event:FocusEvent):void 
		{
			super.handleFocusIn(event);
			
			toggleClearButtonDisplay();
		}
		
		/**
		 * Overrides the PromptingTextInput's FocusEvent.FOCUS_OUT handler so we 
		 * can toggle the display of the clear search button.
		 */
		override protected function handleFocusOut(event:FocusEvent):void 
		{
			super.handleFocusOut(event);
			
			toggleClearButtonDisplay();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Handles a click event on the clear button to clear out the search text 
		 * and then hides the clear button.
		 */
		protected function clearButton_clickHandler(event:MouseEvent):void 
		{
			if (text.length > 0) 
			{
				text = "";
				
				// with no text no need for the clear button to appear
				clearButton.visible = false;
				
				// since the user initiates a real text change, except instead of 
				// deleting text, they hit the clear button which in turn we reset 
				// the text property but we want to maintain the same behavior as 
				// if they used the delete key, manually dispatch the change event
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * Dispatches an iconClick event when the user clicks on the search icon.
		 */
		protected function searchIcon_clickHandler(event:MouseEvent):void 
		{
			dispatchEvent(new SearchTextInputEvent(SearchTextInputEvent.ICON_CLICK));
		}
	}
}