/*
Copyright (c) 2007 FlexLib Contributors.  See:
    http://code.google.com/p/flexlib/wiki/ProjectContributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
package com.javierjulio.flexlib.controls.tabBarClasses
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	
	import flexlib.events.SuperTabEvent;
	
	import mx.controls.Button;
	import mx.controls.tabBarClasses.Tab;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Fired when the the label of this tab is updated by the user double clicking and editing the 
	 * tab label. Only possible if dougbleClickToEdit is true.
	 */
	[Event(name="tabUpdated", type="flexlib.events.SuperTabEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * top|middle|bottom - Used when calculating the position of the 
	 * close button
	 */
	[Style(name="verticalAlign", type="String", inherit="no")]
	
	//--------------------------------------
	//  Skins
	//--------------------------------------
	
	/**
	 *  The class that is used for the indicator
	 */
	[Style(name="dropIndicatorSkin", type="String", inherit="no")]
	
	/**
	 * The close button default skin.
	 * Name of the class to use as the default skin for the background and border.
	 */
	[Style(name="closeSkin", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 * Name of the class to use as the skin for the background and border
	 * when the button is not selected and the mouse is not over the control.
	 */
	[Style(name="closeUpSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border 
	 * when the button is not selected and the mouse is over the control.
	 */
	[Style(name="closeOverSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border 
	 * when the button is not selected and the mouse button is down.
	 */
	[Style(name="closeDownSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border 
	 * when the button is not selected and is disabled.
	 */
	[Style(name="closeDisabledSkin", type="Class", inherit="no")]
	
	/**
	 * 
	 * 
	 * List of changes in comparison to FlexLib's SuperTab for consistency 
	 * with the Flex framework:
	 * 
	 * <ul>
	 * <li>Renamed <code>editableLabel</code> property to <code>editable</code></li>
	 * <li>Renamed <code>indicatorClass</code> style to <code>dropIndicatorSkin</code></li>
	 * <li>Renamed <code>showIndicator</code> property to <code>showDropIndicator</code></li>
	 * <li>Renamed <code>showIndicatorAt</code> method to <code>showDropIndicatorAt</code></li>
	 * <li>Renamed <code>doubleClickToEdit</code> property to <code>doubleClickEditable</code></li>
	 * <li>Adding double click event handler only when <code>doubleClickEditable</code> is true 
	 * otherwise the handler is removed and <code>doubleClickEnabled</code> is set to false.</li>
	 * <li>Moved indicator and close skins from SuperTabNavigator to SuperTab</li>
	 * <li></li>
	 * <li></li>
	 * </ul>
	 */
	public class SuperTab extends Tab 
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 */
		public static const CLOSE_TAB_EVENT:String = "closeTab";
		
		/**
		 * Static variables indicating the policy to show the close button.
		 * 
		 * CLOSE_ALWAYS means the close button is always shown
		 * CLOSE_SELECTED means the close button is only shown on the currently selected tab
		 * CLOSE_ROLLOVER means the close button is show if the mouse rolls over a tab
		 * CLOSE_NEVER means the close button is never show.
		 */
		public static const CLOSE_ALWAYS:String = "close_always";
		public static const CLOSE_SELECTED:String = "close_selected";
		public static const CLOSE_ROLLOVER:String = "close_rollover";
		public static const CLOSE_NEVER:String = "close_never";
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Trigger when static instance is created to set default styles.
		 */
		private static var classConstructed:Boolean = constructClass();
		
		[Embed (source="/assets/swfs/flexLibAssets.swf", symbol="indicator")]
		private static var DEFAULT_DROP_INDICATOR:Class;
		
		[Embed (source="/assets/swfs/flexLibAssets.swf", symbol="firefox_close_up")]
		private static var DEFAULT_CLOSE_UP:Class;
		
		[Embed (source="/assets/swfs/flexLibAssets.swf", symbol="firefox_close_over")]
		private static var DEFAULT_CLOSE_OVER:Class;
		
		[Embed (source="/assets/swfs/flexLibAssets.swf", symbol="firefox_close_down")]
		private static var DEFAULT_CLOSE_DOWN:Class;
		
		[Embed (source="/assets/swfs/flexLibAssets.swf", symbol="firefox_close_disabled")]
		private static var DEFAULT_CLOSE_DISABLED:Class;
		
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
			if (!StyleManager.getStyleDeclaration("SuperTab")) 
			{
				var superTab:CSSStyleDeclaration = new CSSStyleDeclaration();
				superTab.defaultFactory = function():void 
				{
					this.closeDisabledSkin = DEFAULT_CLOSE_DISABLED;
					this.closeDownSkin = DEFAULT_CLOSE_DOWN;
					this.closeOverSkin = DEFAULT_CLOSE_OVER;
					this.closeUpSkin = DEFAULT_CLOSE_UP;
	   				this.dropIndicatorSkin = DEFAULT_DROP_INDICATOR;	
					this.textAlign = "left";
				}
				
				StyleManager.setStyleDeclaration("SuperTab", superTab, false);
			}
			
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Storage for Button instance that appears within the tab that when 
		 * clicked closes the tab.
		 */
		protected var closeButton:Button;
		
		/**
		 * @private
		 * Storage for the drop indicator object to appear within the tab when 
		 * another tab is being dragged and dropped before or after.
		 */
		private var dropIndicator:DisplayObject;
		
		/**
		 * @private
		 * Storage for the offset at the x coordinate that the drop indicator is 
		 * displayed at.
		 */
		private var dropIndicatorOffset:Number = 0;
		
		/**
		 * @private
		 * Tracks the rollover state.
		 */
		private var rolledOver:Boolean = false;
		
		/**
		 * @private
		 * Tracks when the rolledOver property changes.
		 */
		private var rolledOverChanged:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function SuperTab():void 
		{
			super();
			
			// enable mouseChildren so our closeButton can receive mouse events
			mouseChildren = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  enabled
		//----------------------------------
		
		/**
		 * @private
		 */
		private var enabledChanged:Boolean = false;
		
		/**
		 * @private
		 */
		override public function set enabled(value:Boolean):void 
		{
			if (value == enabled) 
				return;
			
			super.enabled = value;
			enabledChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  selected
		//----------------------------------
		
		/**
		 * @private
		 */
		override public function set selected(value:Boolean):void 
		{
			super.selected = value;
			
			callLater(invalidateSize);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  closePolicy
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the closePolicy property.
		 */
		private var _closePolicy:String = CLOSE_ROLLOVER;
		
		/**
		 * @private
		 */
		private var closePolicyChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="close_always,close_selected,close_rollover,close_never", defaultValue="close_rollover")]
		
		/**
		 * A string representing when to show the close button for the tab.
		 * Possible values include: SuperTab.CLOSE_ALWAYS, SuperTab.CLOSE_SELECTED,
		 * SuperTab.CLOSE_ROLLOVER, SuperTab.CLOSE_NEVER
		 * 
		 * @default SuperTab.CLOSE_ROLLOVER
		 */
		public function get closePolicy():String 
		{
			return _closePolicy;
		}
		
		/**
		 * @private
		 */
		public function set closePolicy(value:String):void 
		{
			if (_closePolicy == value) 
				return;
			
			_closePolicy = value;
			closePolicyChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  closeStyleFilters
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the closeStyleFilters property.
		 */
		private static var _closeStyleFilters:Object = 
		{
			"closeUpSkin" : "closeUpSkin",
			"closeOverSkin" : "closeOverSkin",
			"closeDownSkin" : "closeDownSkin",
			"closeDisabledSkin" : "closeDisabledSkin",
			"closeSkin" : "closeSkin",
			"repeatDelay" : "repeatDelay",
			"repeatInterval" : "repeatInterval"
		}
		
		/**
		 * The set of styles to pass from the SuperTab to the close button.
		 * 
		 * @see mx.styles.StyleProxy
		 */
		protected function get closeStyleFilters():Object 
		{
			return _closeStyleFilters;
		}
		
		//----------------------------------
		//  doubleClickEditable
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the doubleClickEditable property.
		 */
		private var _doubleClickEditable:Boolean = false;
		
		/**
		 * @private
		 */
		private var doubleClickEditableChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * Boolean indicating if a double click on the tab will allow the editing 
		 * of the tab label.
		 * 
		 * @default false
		 */
		public function get doubleClickEditable():Boolean 
		{
			return _doubleClickEditable;
		}
		
		/**
		 * @private
		 */
		public function set doubleClickEditable(value:Boolean):void 
		{
			if (_doubleClickEditable == value) 
				return;
			
			_doubleClickEditable = value;
			doubleClickEditableChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  editable
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the editable property.
		 */
		private var _editable:Boolean = false;
		
		/**
		 * @private
		 */
		private var editableChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * Whether the tab can have its label changed by user interaction. If 
		 * <code>true</code> then by clicking on the tab's label it will become 
		 * an editable text field. If <code>doubleClickEditable</code> is true 
		 * then its required to double click to turn on label editing.
		 * 
		 * @default false
		 */
		public function get editable():Boolean 
		{
			return _editable;
		}
		
		/**
		 * @private
		 */
		public function set editable(value:Boolean):void 
		{
			if (_editable == value) 
				return;
			
			_editable = value;
			editableChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  showDropIndicator
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the showDropIndicator property.
		 */
		private var _showDropIndicator:Boolean = false;
		
		/**
		 * @private
		 */
		private var showDropIndicatorChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * Determines whether the drop indicator arrow is displayed.
		 * 
		 * @default false
		 */
		public function get showDropIndicator():Boolean 
		{
			return _showDropIndicator;
		}
		
		/**
		 * @private
		 */
		public function set showDropIndicator(value:Boolean):void 
		{
			if (_showDropIndicator == value) 
				return;
			
			_showDropIndicator = value;
			showDropIndicatorChanged = true;
			
			invalidateProperties();
			invalidateDisplayList();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: UIComponent
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void 
		{
			super.createChildren();
			
			var dropIndicatorClass:Class = getStyle("dropIndicatorSkin") as Class;
			
			if (!dropIndicator && dropIndicatorClass != null) 
			{
				dropIndicator = DisplayObject(new dropIndicatorClass());
				dropIndicator.visible = false;
				addChild(dropIndicator);
			}
			
			if (!closeButton) 
			{
				closeButton = new Button();
				closeButton.enabled = false;
				closeButton.visible = false;
				closeButton.styleName = new StyleProxy(this, closeStyleFilters);
				closeButton.upSkinName = "closeUpSkin";
				closeButton.overSkinName = "closeOverSkin";
				closeButton.downSkinName = "closeDownSkin";
				closeButton.disabledSkinName = "closeDisabledSkin";
				closeButton.skinName = "closeSkin";
				closeButton.upIconName = "";
				closeButton.overIconName = "";
				closeButton.downIconName = "";
				closeButton.disabledIconName = "";
				closeButton.setStyle("paddingBottom", 0);
				closeButton.setStyle("paddingLeft", 0);
				closeButton.setStyle("paddingTop", 0);
				closeButton.setStyle("paddingRight", 0);
				
				// We have to listen for the click event so we know to close the tab
				closeButton.addEventListener(MouseEvent.MOUSE_UP, closeButton_clickHandler, false, 0, true);
				closeButton.addEventListener(MouseEvent.MOUSE_DOWN, cancelEvent, false, 0, true);
				closeButton.addEventListener(MouseEvent.CLICK, cancelEvent, false, 0, true);
				
				addChild(closeButton);
			}
			
			if (textField) 
			{
				textField.addEventListener(Event.CHANGE, textField_changeHandler);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			if (showDropIndicatorChanged) 
			{
				dropIndicator.visible = _showDropIndicator;
				
				showDropIndicatorChanged = false;
			}
			
			if (enabledChanged) 
			{
				closeButton.enabled = enabled;
				
				enabledChanged = false;
			}
			
			// Depending on the closePolicy we might be showing the closeButton
			// and it may or may not be enabled.
			if (closePolicyChanged || rolledOverChanged) 
			{
				if (_closePolicy == SuperTab.CLOSE_SELECTED) 
				{
					if (selected) 
					{
						closeButton.visible = true;
						closeButton.enabled = true;
					}
				} 
				else 
				{
					if (!rolledOver) 
					{
						if (_closePolicy == SuperTab.CLOSE_ALWAYS) 
						{
							closeButton.visible = true;
							closeButton.enabled = false;
						}
						else if (_closePolicy == SuperTab.CLOSE_ROLLOVER || _closePolicy == SuperTab.CLOSE_NEVER) 
						{
							closeButton.visible = false;
							closeButton.enabled = false;
						}
					} 
					else 
					{
						if (_closePolicy != SuperTab.CLOSE_NEVER) 
						{
							closeButton.visible = true;
							closeButton.enabled = enabled;
						}
					}
				}
				
				closePolicyChanged = false;
				rolledOverChanged = false;
			}
			
			if (doubleClickEditableChanged) 
			{
				// enable double clicked for supporting editable labels
				if (_doubleClickEditable) 
				{
					doubleClickEnabled = true;
					addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
				} 
				else 
				{
					doubleClickEnabled = false;
					removeEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
				}
				
				doubleClickEditableChanged = false;
			}
			
			if (editableChanged) 
			{
				textField.type = (_editable && enabled) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
				textField.selectable = _editable;
				
				if (_editable) 
				{
					addEventListener(MouseEvent.MOUSE_DOWN, cancelEvent, false, 10);
					
					textField.addEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
					textField.addEventListener(KeyboardEvent.KEY_DOWN, textField_keyDownHandler);
					
					// undo truncation for editing and redo selection for the new text length
					textField.text = label;
					textField.setSelection(0, textField.length-1);
				} 
				else 
				{
					removeEventListener(MouseEvent.MOUSE_DOWN, cancelEvent);
					
					textField.removeEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
					textField.removeEventListener(KeyboardEvent.KEY_DOWN, textField_keyDownHandler);
					
					textField.setSelection(0, 0);
					
					textField.invalidateDisplayList();
				}
				
				editableChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void 
		{
			super.measure();
			
			if (_closePolicy == SuperTab.CLOSE_ALWAYS || _closePolicy == SuperTab.CLOSE_ROLLOVER) 
			{
				measuredMinWidth += closeButton.measuredWidth;
				measuredWidth += closeButton.measuredWidth;
			} 
			else if (_closePolicy == SuperTab.CLOSE_SELECTED && selected) 
			{
				measuredMinWidth += closeButton.measuredWidth;
				measuredWidth += closeButton.measuredWidth;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// We need to make sure that the closeButton and the indicator are
			// above all other display items for this button. Otherwise the button
			// skin or icon or text are placed over the closeButton and indicator.
			// That's no good because then we can't get clicks and it looks funky.
			setChildIndex(closeButton, numChildren - 2);
			
			if (dropIndicator) 
			{
				setChildIndex(dropIndicator, numChildren - 1);
				
				dropIndicator.x = dropIndicatorOffset - (dropIndicator.width / 2);
				dropIndicator.y = 0;
			}
			
			if (closeButton.visible) 
			{
				// Resize the text if we're showing the close icon, so the
				// close icon won't overlap the text. This means the text may
				// have to truncate using the "..." differently.
				//textField.width = closeButton.x - textField.x;
				//textField.truncateToFit();
				
				closeButton.setActualSize(closeButton.measuredWidth, closeButton.measuredWidth);
				
				// we'll use vertical alignment to determine where to place the close button
				var verticalAlign:String = getStyle("verticalAlign") as String;
				var closeX:Number = unscaledWidth - closeButton.measuredWidth - getStyle("paddingRight");
				var closeY:Number = 0;
				
				// align the close button at the top of the label text field
				if (verticalAlign == "top") 
				{
					closeY = textField.x;
				} 
				else // default is to middle align
				{
					closeY = (unscaledHeight - closeButton.height) / 2
				}
				
				closeButton.move(closeX, closeY);
				
				setChildIndex(closeButton, numChildren - 1);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Shows the indicator at the desired x position.
		 * 
		 * @param x The desired x position.
		 */
		public function showDropIndicatorAt(x:Number):void 
		{
			dropIndicatorOffset = x;
			showDropIndicator = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden event handlers: Button
		//
		//--------------------------------------------------------------------------
		
		/**
		 * We keep track of the rolled over state internally so we can set the
		 * closeButton to enabled or disabled depending on the state.
		 */
		override protected function rollOverHandler(event:MouseEvent):void 
		{
			if (!enabled) 
			{
				event.stopImmediatePropagation();
				event.stopPropagation();
				return;
			}
			
			rolledOver = true;
			rolledOverChanged = true;
			invalidateProperties();
			
			super.rollOverHandler(event);
		}
		
		/**
		 * When the user rolls off the tab we mark the change in the rolled over 
		 * state.
		 */
		override protected function rollOutHandler(event:MouseEvent):void 
		{
			rolledOver = false;
			rolledOverChanged = true;
			invalidateProperties();
			
			super.rollOutHandler(event);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function cancelEvent(event:Event):void 
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
		}
		
		/**
		 * @private
		 * When the user clicks the close button an event named CLOSE_TAB_EVENT is 
		 * dispatched. This doesn't actually remove the tab. The SuperTabNavigator 
		 * or SuperTabBar will remove the child container. So all we need to do is 
		 * announce that a CLOSE_TAB_EVENT has happened, and we leave it up to the 
		 * component that is managing multiple tabs to remove it.
		 */
		private function closeButton_clickHandler(event:MouseEvent):void 
		{
			if (enabled) 
			{
				dispatchEvent(new Event(CLOSE_TAB_EVENT));
			}
			
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		/**
		 * @private
		 */
		private function doubleClickHandler(event:MouseEvent):void 
		{
			if (_doubleClickEditable && enabled) 
				editable = true;
		}
		
		/**
		 * @private
		 */
		private function textField_changeHandler(event:Event):void 
		{
			if (label != textField.text) 
				label = textField.text;
			
			event.stopImmediatePropagation();
		}
		
		/**
		 * @private
		 */
		private function textField_focusOutHandler(event:Event):void 
		{
			// commit the changes and turn off editing
			label = textField.text;
			editable = false;
			
			dispatchEvent(new SuperTabEvent(SuperTabEvent.TAB_UPDATED, -1));
		}
		
		/**
		 * @private
		 */
		private function textField_keyDownHandler(event:KeyboardEvent):void 
		{
			if (event.keyCode == Keyboard.ENTER) 
			{
				event.stopImmediatePropagation();
				event.stopPropagation();
				
				editable = false;
				
				dispatchEvent(new SuperTabEvent(SuperTabEvent.TAB_UPDATED, -1));
			}
		}
	}
}