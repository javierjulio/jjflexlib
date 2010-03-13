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
package com.javierjulio.flexlib.containers
{
	import com.javierjulio.flexlib.controls.SuperTabBar;
	import com.javierjulio.flexlib.controls.tabBarClasses.SuperTab;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flexlib.controls.ScrollableArrowMenu;
	import flexlib.events.SuperTabEvent;
	import flexlib.events.TabReorderEvent;
	import flexlib.skins.TabPopUpButtonSkin;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.containers.Box;
	import mx.containers.BoxDirection;
	import mx.containers.Canvas;
	import mx.containers.TabNavigator;
	import mx.containers.ViewStack;
	import mx.controls.Menu;
	import mx.controls.PopUpButton;
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.ScrollPolicy;
	import mx.effects.Tween;
	import mx.events.ChildExistenceChangedEvent;
	import mx.events.IndexChangedEvent;
	import mx.events.MenuEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	[IconFile("SuperTabNavigator.png")]
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Fired when the close button of a tab is clicked. To stop the default action, which will remove the 
	 * child from the collection of children, call event.preventDefault() in your listener.
	 */
	[Event(name="tabClose", type="flexlib.events.SuperTabEvent")]
	
	/**
	 * Fired when a tab is dropped onto the SuperTabBar, which re-orders the tabs and updates the
	 * list of tabs.
	 */
	[Event(name="tabsReordered", type="flexlib.events.TabReorderEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 *  Name of CSS style declaration that specifies style for button used to control the horizontal
	 *  scrolling of the tabs. This button appears on the right-most side of the tab bar.
	 *  
	 *  @default undefined
	 */
	[Style(name="leftButtonStyleName", type="String", inherit="no")]
	
	/**
	 *  Name of CSS style declaration that specifies style for the Button that appears
	 *  on the right side of the tab bar.
	 *  
	 *  @default undefined
	 */
	[Style(name="popupButtonStyleName", type="String", inherit="no")]
	
	/**
	 *  Name of CSS style declaration that specifies style for button used to control the horizontal
	 *  scrolling of the tabs. This button appears on the left-most side of the tab bar.
	 *  
	 *  @default undefined
	 */
	[Style(name="rightButtonStyleName", type="String", inherit="no")]
	
	/**
	 *  The SuperTabNavigator is an extension of the TabNavigator navigation
	 *  container.
	 * 
	 *  <p>The SuperTabNavigator functions exactly like the TabNavigator, but
	 *  adds some functionality. Added functionality includes:</p>
	 *	<ul>
	 * 		<li>Draggable, re-orderable tabs</li>
	 * 		<li>Closable tabs</li>
	 * 		<li>Scrolling tab bar if too many tabs are open</li>
	 * 		<li>Drop-down list of tabs</li>
	 * 	</ul>
	 * 
	 * 	<p>These features make the SuperTabNavigator function much more like the 
	 *  tabs in Firefox.</p>
	 *  
	 *  @mxml
	 *
	 *  <p>The <code>&lt;mx:SuperTabNavigator&gt;</code> tag inherits all of the
	 *  tag attributes of the TabNavigator,
	 *  and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;mx:SuperTabNavigator
	 *    <b>Styles</b>
	 *    popupButtonStyleName="<i>Value of the</i> <code>popupButtonStyleName</code> <i>property</i>"
	 * 	  leftButtonStyleName="<i>Value of the</i> <code>leftButtonStyleName</code> <i>property</i>"
	 * 	  rightButtonStyleName="<i>Value of the</i> <code>rightButtonStyleName</code> <i>property</i>"
	 *    
	 *    <b>Properties</b>
	 * 	  popUpButtonPolicy="on|auto|off"
	 *    startScrollingEvent="MouseEvent.MOUSE_DOWN|MouseEvent.MOUSE_OVER"
	 * 	  stopScrollingEvent="MouseEvent.MOUSE_UP|MouseEvent.MOUSE_OUT"
	 *    scrollSpeed="100"
	 *    dragEnabled="true|false"
	 *    dropEnabled="true|false"
	 *    minTabWidth="60"
	 * 
	 *    &gt;
	 *      ...
	 *      <i>child tags</i>
	 *      ...
	 *  &lt;/mx:SuperTabNavigator&gt;
	 *  </pre>
	 *
	 *  @see mx.containers.TabNavigator
	 *  @see flexlib.controls.SuperTabBar
	 */
	public class SuperTabNavigator extends TabNavigator
	{
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
		
		/**
		 * Static variable indicating the Button will be shown if there is more
		 * than one tab in the SuperTabNavigator.
		 * Used to set popUpButtonPolicy.
		 */
		public static var POPUPPOLICY_AUTO:String = "auto";
		
		/**
		 * Static variable indicating the Button will always be shown to the
		 * right of the tab bar, no matter how many tabs are open. 
		 * Used to set popUpButtonPolicy.
		 */
		public static var POPUPPOLICY_ON:String = "on";
		
		/**
		 * Static variable indicating the Button will never be shown to the
		 * right of the tab bar. 
		 * Used to set popUpButtonPolicy.
		 */
		public static var POPUPPOLICY_OFF:String = "off";
		
	    [Embed (source="/assets/swfs/flexLibAssets.swf", symbol="left_arrow")]
	    private static var DEFAULT_LEFT_BUTTON:Class;
	    
	    [Embed (source="/assets/swfs/flexLibAssets.swf", symbol="right_arrow")]
	    private static var DEFAULT_RIGHT_BUTTON:Class;
		
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
			// SUPER TAB NAVIGATOR default styles
			
			var superTabNavigator:CSSStyleDeclaration = StyleManager.getStyleDeclaration("SuperTabNavigator");
			
			if (!superTabNavigator) 
			{
				superTabNavigator = new CSSStyleDeclaration();
				superTabNavigator.defaultFactory = function():void 
				{
					this.buttonWidth = 20;
					this.leftButtonStyleName = "leftButton";
					this.popupButtonStyleName = "popupButton";
					this.rightButtonStyleName = "rightButton";
				}
				
				StyleManager.setStyleDeclaration("SuperTabNavigator", superTabNavigator, false);
			}
			
			// POP UP BUTTON default styles
			
			var popupButtonStyleName:String = superTabNavigator.getStyle("popupButtonStyleName");
			var popUpButton:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + popupButtonStyleName);
			
			if (!popUpButton) 
			{
				popUpButton = new CSSStyleDeclaration();
				popUpButton.defaultFactory = function():void 
				{
					this.disabledSkin = TabPopUpButtonSkin;
					this.popUpDownSkin = TabPopUpButtonSkin;
					this.popUpOverSkin = TabPopUpButtonSkin;
					this.upSkin = TabPopUpButtonSkin;
				}
				
				StyleManager.setStyleDeclaration("." + popupButtonStyleName, popUpButton, false);
			}
			
			// LEFT ARROW BUTTON default styles (for tab scrolling)
			
			var leftButtonStyleName:String = superTabNavigator.getStyle("leftButtonStyleName");
			var leftButton:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + leftButtonStyleName);
			
			if (!leftButton) 
			{
				leftButton = new CSSStyleDeclaration();
				leftButton.defaultFactory = function():void 
				{
					this.cornerRadius = 0;
					this.fillAlphas = [1,1,1,1];
					this.icon = DEFAULT_LEFT_BUTTON;
				}
				
				StyleManager.setStyleDeclaration("." + leftButtonStyleName, leftButton, false);
			}
			
			// RIGHT ARROW BUTTON default styles (for tab scrolling)
			
			var rightButtonStyleName:String = superTabNavigator.getStyle("rightButtonStyleName");
			var rightButton:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + rightButtonStyleName);
			
			if (!rightButton) 
			{
				rightButton = new CSSStyleDeclaration();
				rightButton.defaultFactory = function():void 
				{
					this.cornerRadius = 0;
					this.fillAlphas = [1,1,1,1];
					this.icon = DEFAULT_RIGHT_BUTTON;
				}
				
				StyleManager.setStyleDeclaration("." + rightButtonStyleName, rightButton, false);
			}
			
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * The Canvas component that will hold the TabBar. This is used
		 * so we get access to the scrolling functionality of a container. To do
		 * the scrolling we're going to use the horizontalScrollPosition of the 
		 * Canvas.
		 */
		protected var canvas:ButtonScrollingCanvas;
		
		/**
		 * @private
		 */
		private var forcedTabWidth:Number = -1;
		
		/**
		 * The Box component that we are going to use to hold the scrolling canvas. 
		 * Using Box so that if extended the direction can be changed from 
		 * horizontal to vertical and vice versa. The default is horizontal.
		 */
		protected var holder:Box;
		
		/**
		 * Storage for the Menu instance that will list all the tabs that can't 
		 * be displayed in the TabBar. Used by the PopUpButton instance.
		 */
		protected var menu:Menu;
		
		/**
		 * @private
		 */
		private var originalTabWidthStyle:Number = -1;
		
		/**
		 * Storage for the PopUpButton instance that will contain a menu of any 
		 * other tabs that can't fit in the TabBar display.
		 */
		protected var popupButton:PopUpButton;
		
		/**
		 * @private
		 */
		private var stopIndexChangeEvent:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function SuperTabNavigator():void 
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  allowTabSqueezing
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the allowTabSqueezing property.
		 */
		private var _allowTabSqueezing:Boolean = true;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		
		/**
		 * Boolean indicating if tab width should be adjusted to try to squeeze all 
		 * tabs so we don't need scrolling. If true, tabs will be squeezed until they 
		 * reach the <code>minTabWidth</code> value, at which point they scroll. If 
		 * false, tabs will never be resized smaller than their default widths.
		 * 
		 * @default true
		 */
		public function get allowTabSqueezing():Boolean 
		{
			return _allowTabSqueezing;
		}
		
		/**
		 * @private
		 */
		public function set allowTabSqueezing(value:Boolean):void 
		{
			_allowTabSqueezing = value;
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  closePolicy
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the closePolicy property.
		 */
		private var _closePolicy:String = SuperTab.CLOSE_ROLLOVER;
		
		/**
		 * @private
		 */
		private var closePolicyChanged:Boolean = false;
		
		/**
		 * The close policy for the tabs.
		 * 
		 * @default SuperTab.CLOSE_ROLLOVER
		 * 
		 * @see flexlib.controls.SuperTabBar
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
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  dragEnabled
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the dragEnabled property.
		 */
		private var _dragEnabled:Boolean = true;
		
		/**
		 * @private
		 */
		private var dragEnabledChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		
		/**
		 * Boolean indicating whether or not this SuperTabNavigator allows
		 * tabs to be dragged from the tab bar.
		 * 
		 * <p>If both dragEnabled and dropEnabled are true then the 
		 * SuperTabNavigator allows reordering of tabs by drag and drop.</p>
		 *  
		 * @default true
		 */
		public function get dragEnabled():Boolean 
		{
			return _dragEnabled;
		}
		
		/**
		 * @private
		 */
		public function set dragEnabled(value:Boolean):void 
		{
			if (_dragEnabled == value) 
				return;
			
			_dragEnabled = value;
			dragEnabledChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  dropEnabled
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the dropEnabled property.
		 */
		private var _dropEnabled:Boolean = true;
		
		/**
		 * @private
		 */
		private var dropEnabledChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		
		/**
		 * Boolean indicating whether or not this SuperTabNavigator allows
		 * tabs to be dropped in the tab bar.
		 * 
		 * @default true
		 */
		public function get dropEnabled():Boolean 
		{
			return _dropEnabled;
		}
		
		/**
		 * @private
		 */
		public function set dropEnabled(value:Boolean):void 
		{
			if (_dropEnabled == value) 
				return;
			
			_dropEnabled = value;
			dropEnabledChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  editableTabLabels
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the editableTabLabels property.
		 */
		private var _editableTabLabels:Boolean = false;
		
		/**
		 * @private
		 */
		private var editableTabLabelsChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * Boolean indicating if tab labels can be edited. If true, the user can 
		 * double click on a tab label and edit the label.
		 * 
		 * @default false
		 */
		public function get editableTabLabels():Boolean 
		{
			return _editableTabLabels;
		}
		
		/**
		 * @private
		 */
		public function set editableTabLabels(value:Boolean):void 
		{
			if (_editableTabLabels == value) 
				return;
			
			_editableTabLabels = value;
			editableTabLabelsChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  minTabWidth
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the minTabWidth property.
		 */
		private var _minTabWidth:Number = 60;
		
		/**
		 * The minimum tab width allowed to display tabs.
		 * 
		 * <p>If tabs cannot fit at their default size, then they are shrunk until 
		 * they reach minTabWidth. If they still cannot fit then they remain at 
		 * minTabWidth and the SuperTabBar scrolls the tabs.</p>
		 *
		 * @default 60
		 */
		public function get minTabWidth():Number 
		{
			return _minTabWidth;
		}
		
		/**
		 * @private
		 */
		public function set minTabWidth(value:Number):void 
		{
			if (_minTabWidth == value) 
				return;
			
			_minTabWidth = value;
			
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  popUpButtonPolicy
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the popUpButtonPolicy property.
		 */
		private var _popUpButtonPolicy:String = "";
		
		/**
		 * @private
		 */
		private var popUpButtonPolicyChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="auto,on,off", defaultValue="")]
		
		/**
		 * Either POPUPPOLICY_AUTO, POPUPOLICY_ON, or POPUPPOLICY_OFF.
		 * <p>Indicates how the Button to the right of the tabs should 
		 * be shown. AUTO means the button will be shown if there is more than 
		 * one tab. ON means it will always be shown, and OFF means it will never 
		 * be shown.</p>
		 * 
		 * @default ""
		 */
		public function get popUpButtonPolicy():String 
		{
			return _popUpButtonPolicy;
		}
		
		/**
		 * @private
		 */
		public function set popUpButtonPolicy(value:String):void 
		{
			if (_popUpButtonPolicy == value) 
				return;
			
			_popUpButtonPolicy = value;
			popUpButtonPolicyChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  scrollSpeed
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the scrollSpeed property.
		 */
		private var _scrollSpeed:Number = 100;
		
		/**
		 * @private
		 */
		private var scrollSpeedChanged:Boolean = false;
		
		/**
		 * The delay in milliseconds between scrolling the tabs. The smaller the 
		 * number the faster the scrolling speed.
		 * 
		 * @default 100
		 */
		public function get scrollSpeed():Number 
		{
			return _scrollSpeed;
		}
		
		/**
		 * @private
		 */
		public function set scrollSpeed(value:Number):void 
		{
			if (_scrollSpeed == value) 
				return;
			
			_scrollSpeed = value;
			scrollSpeedChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  startScrollingEvent
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the startScrollingEvent property.
		 */
		private var _startScrollingEvent:String = MouseEvent.MOUSE_DOWN;
		
		/**
		 * @private
		 */
		private var startScrollingEventChanged:Boolean = false;
		
		/**
		 * The event that should start scrolling in the canvas.
		 * 
		 * @default MouseEvent.MOUSE_DOWN
		 */
		public function get startScrollingEvent():String 
		{
			return _startScrollingEvent;
		}
		
		/**
		 * @private
		 */
		public function set startScrollingEvent(value:String):void 
		{
			if (_startScrollingEvent == value) 
				return;
			
			_startScrollingEvent = value;
			startScrollingEventChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  stopScrollingEvent
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the stopScrollingEvent property.
		 */
		private var _stopScrollingEvent:String = MouseEvent.MOUSE_UP;
		
		/**
		 * @private
		 */
		private var stopScrollingEventChanged:Boolean = false;
		
		/**
		 * The event that should end scrolling in the canvas.
		 * 
		 * @default MouseEvent.MOUSE_UP
		 */
		public function get stopScrollingEvent():String 
		{
			return _stopScrollingEvent;
		}
		
		/**
		 * @private
		 */
		public function set stopScrollingEvent(value:String):void 
		{
			if (_stopScrollingEvent == value) 
				return;
			
			_stopScrollingEvent = value;
			stopScrollingEventChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  tabBarHeight
		//----------------------------------
		
	    /**
	     * Height of the tab.
	     */
	    protected function get tabBarHeight():Number 
	    {
	        var tabHeight:Number = getStyle("tabHeight");
			
	        if (isNaN(tabHeight)) 
	            tabHeight = tabBar.getExplicitOrMeasuredHeight();
			
	        return tabHeight - 1;
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
	    	if (!tabBar) 
	    	{
	    		// we're using our custom SuperTabBar class instead of TabBar
				tabBar = createTabBar();
				tabBar.name = "tabBar";
				tabBar.focusEnabled = false;
				tabBar.styleName = this;
				SuperTabBar(tabBar).dragEnabled = _dragEnabled;
				SuperTabBar(tabBar).dropEnabled = _dropEnabled;
				SuperTabBar(tabBar).editableTabLabels = _editableTabLabels;
				SuperTabBar(tabBar).closePolicy = _closePolicy;
				
				tabBar.setStyle("borderStyle", "none");
				tabBar.setStyle("paddingTop", 0);
				tabBar.setStyle("paddingBottom", 0);
				
				//this is a bit of a hack. We don't want tabBar to inherit the left, right, top, or bottom
				//styles from SuperTabNavigator. So we disable the use of left, right, top, or bottom on SuperTabBar
				//if it's used in SuperTabNavigator
				//fixes issue 29: http://code.google.com/p/flexlib/issues/detail?id=29
				tabBar.setStyle("left", NaN);
				tabBar.setStyle("right", NaN);
				tabBar.setStyle("top", NaN);
				tabBar.setStyle("bottom", NaN);
				tabBar.setStyle("horizontalCenter", NaN);
				
				SuperTabBar(tabBar).addEventListener(SuperTabEvent.TAB_CLOSE, tabBar_tabCloseHandler);
			}
			
			// We need to create our tabBar above BEFORE calling createChildren
			// because otherwise it would get created in the super class.
			// Once we create it then the super class will skip it. It still hasn't
			// been added as a child however (this gets done below).
	        super.createChildren();
	        
	        if (!holder) 
	        {
	        	// Why not just use HBox? Because in the future we might want
	        	// to use a VBox for vertical tabs. This lets a subclass simply
	        	// change the direction.
	        	holder = new Box();
	        	holder.direction = BoxDirection.HORIZONTAL;
	        	holder.horizontalScrollPolicy = "off";
	        	
	        	holder.setStyle("horizontalGap", 0);
	        	holder.setStyle("borderStyle", "none");
	        	holder.setStyle("paddingTop", 0);
				holder.setStyle("paddingBottom", 0);
	        	
	        	rawChildren.addChild(holder);
	        }
			
			if (!canvas) 
			{
				canvas = new ButtonScrollingCanvas();
				canvas.startScrollingEvent = _startScrollingEvent;
				canvas.stopScrollingEvent = _stopScrollingEvent;
				canvas.scrollSpeed = _scrollSpeed;
				canvas.styleName = this;
				
				canvas.setStyle("borderStyle", "none");
				canvas.setStyle("backgroundAlpha", 0);
				canvas.setStyle("paddingTop", 0);
				canvas.setStyle("paddingBottom", 0);
				
				// So we can see our child heirarchy: 
				// holder (Box) -> canvas (ButtonScrollingCanvas) -> tabBar (SuperTabBar)
				canvas.addChild(tabBar);
				holder.addChild(canvas);
			}
			
	        // We create the menu once. This doesn't get shown until we click
	        // the Button. But it can get created here so we don't have
	        // to create it every time.
	        if (!menu) 
	        {
	        	menu = new ScrollableArrowMenu();
	        	menu.setStyle("textAlign", "left");
	        	
	        	// If we wanted to change the scroll policy for the scrolling menu we
	        	// could modify the following two lines. For example, turning 
	        	// verticalScrollPolicy to OFF will remove the side scrollbars and leave
	        	// just the arrow buttons on top and bottom.
	        	menu.verticalScrollPolicy = ScrollPolicy.AUTO;
	        	ScrollableArrowMenu(menu).arrowScrollPolicy = ScrollPolicy.AUTO;
	        	
	        	menu.addEventListener(MenuEvent.ITEM_CLICK, menu_itemClickHandler);
	        }
	        
	        if (!popupButton) 
	        {
	        	popupButton = new PopUpButton();
	        	popupButton.popUp = menu;
	        	popupButton.width = 18;
	        	popupButton.styleName = getStyle("popupButtonStyleName");
	        	
	        	// So now holder has 2 children: canvas and popupButton
	        	holder.addChild(popupButton);
	        }
	        
	        // any tabs that are added, removed or updated we need to handle globally
	        tabBar.addEventListener(ChildExistenceChangedEvent.CHILD_ADD, tabBar_tabsChangedHandler);
	        tabBar.addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, tabBar_tabsChangedHandler);
	        SuperTabBar(tabBar).addEventListener(SuperTabEvent.TAB_UPDATED, tabBar_tabsChangedHandler);
	        
	        // custom event that gets fired from SuperTabBar if the tabs are dragged and reordered
	        tabBar.addEventListener(SuperTabBar.TABS_REORDERED, tabBar_tabsReorderedHandler);
			
			addEventListener(IndexChangedEvent.CHANGE, indexChangeHandler);
	        addEventListener(IndexChangedEvent.CHILD_INDEX_CHANGE, childIndexChangeHandler);
	    }
		
		/**
		 * @private
		 */
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			if (closePolicyChanged) 
			{
				SuperTabBar(tabBar).closePolicy = _closePolicy;
				
				closePolicyChanged = false;
			}
			
			if (dragEnabledChanged) 
			{
				SuperTabBar(tabBar).dragEnabled = _dragEnabled;
				
				dragEnabledChanged = false;
			}
			
			if (dropEnabledChanged) 
			{
				SuperTabBar(tabBar).dropEnabled = _dropEnabled;
				
				dropEnabledChanged = false;
			}
			
			if (editableTabLabelsChanged) 
			{
				SuperTabBar(tabBar).editableTabLabels = _editableTabLabels;
				
				editableTabLabelsChanged = false;
			}
			
			if (popUpButtonPolicyChanged) 
			{
				// are we supposed to be showing the popup button?
				if (_popUpButtonPolicy == SuperTabNavigator.POPUPPOLICY_AUTO) 
				{
					popupButton.includeInLayout = popupButton.visible = (numChildren > 1);
				} 
				else if (_popUpButtonPolicy == SuperTabNavigator.POPUPPOLICY_ON) 
				{
					popupButton.includeInLayout = popupButton.visible = true;
				} 
				else if (_popUpButtonPolicy == SuperTabNavigator.POPUPPOLICY_OFF) 
				{
					popupButton.includeInLayout = popupButton.visible = false;
				}
				
				popUpButtonPolicyChanged = false;
			}
			
			if (scrollSpeedChanged) 
			{
				canvas.scrollSpeed = _scrollSpeed;
				
				scrollSpeedChanged = false;
			}
			
			if (startScrollingEventChanged) 
			{
				canvas.startScrollingEvent = _startScrollingEvent;
				
				startScrollingEventChanged = false;
			}
			
			if (stopScrollingEventChanged) 
			{
				canvas.stopScrollingEvent = _stopScrollingEvent;
				
				stopScrollingEventChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void 
		{
			super.styleChanged(styleProp);
			
			if (styleProp == "tabWidth" && forcedTabWidth == -1) 
			{
				originalTabWidthStyle = getStyle(styleProp);
			}
		}
		
		/**
		 * @private
		 */
	    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
	    {
	        // we need to calculate the tab widths first, so we call super.updateDisplayList later
	        var vm:EdgeMetrics = viewMetrics;
	        var w:Number = unscaledWidth - vm.left - vm.right;
			
	        var th:Number = tabBarHeight + 1;
	        
	        // tabBarSpace is used to try to figure out how much space we 
	        // need for the tabs, to figure out if we need to scroll them
	        var tabBarSpace:Number = w;
	        if (popupButton.includeInLayout) 
	        {
				tabBarSpace -= popupButton.width;
			}
			
			var tempWidth:Number = tabBar.getStyle("tabWidth");
			tabBar.clearStyle("tabWidth");
			tabBar.setStyle("tabWidth", NaN);
			tabBar.validateNow();
			
			var pw:Number = Math.max(tabBar.getExplicitOrMeasuredWidth(), tabBarSpace);
	        //tabBar.setStyle("tabWidth", tempWidth);
	        
	        var tabBarWidth:Number = tabBar.measuredWidth;
	        
	        holder.move(0, 1);
	        holder.setActualSize(unscaledWidth, th);
			
           	var canvasWidth:Number = unscaledWidth;
			
			if (popupButton.includeInLayout) 
			{
				canvasWidth -= popupButton.width;
			}
			
			canvas.width = canvasWidth;
			canvas.height = th;
			canvas.explicitButtonHeight = th - 1;
			canvas.verticalScrollPolicy = ScrollPolicy.OFF;
			
			if (pw <= canvasWidth) 
			{
				canvas.horizontalScrollPosition = 0;
			}
			
			popupButton.height = th - 1;
			
			//now we're good to go with the tab widths, so this should be OK
			//if we called this first we would see some flickering of the tabs 
			//as they are resized quickly. No good.
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			//OK, so one problem: in the call to super.updateDisplayList() the width of tabBar gets reset.
			//that's crap, because we need to set it to what we set it to, damnit. But we need to call super.updateDisplayList
			//or the component won't get drawn right at all. And we can't call super.super.updateDisplayList, so we
			//have to reset the width of tabBar after our call to updateDisplayList
			
			if (tabBarWidth >= canvasWidth && _allowTabSqueezing) 
			{
				var measuredTabBarWidth:Number = tabBar.numChildren * _minTabWidth + (tabBar.numChildren-1) * getStyle("horizontalGap");
				tabBar.width = Math.max(canvasWidth, measuredTabBarWidth);
			} 
			
			/* we only care about horizontalAlign if we're not taking up too
			   much space already */
			if (tabBarWidth < canvasWidth) 
			{
				switch (getStyle("horizontalAlign")) 
				{
			        case "left":
			            tabBar.move(0, tabBar.y);
			            break;
			        
			        case "right":
			            tabBar.move(unscaledWidth - tabBar.width, tabBar.y);
			            break;
			        
			        case "center":
			            tabBar.move((unscaledWidth - tabBar.width) / 2, tabBar.y);
			            break;
		        }
			}
	    }
	    
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * For extensibility, if you want to use a custom extended version of 
		 * SuperTabBar, you can do so by overriding the <code>createTabBar</code> 
		 * method and returning an instance of any class that extends
		 * <code>SuperTabBar</code>.
		 */
		protected function createTabBar():SuperTabBar 
		{
			return new SuperTabBar();
		}
		
		/**
		 * @private
		 * Check to make sure that the currently selected tab is visible. This means
		 * that we might have to scroll the canvas component so the tab comes into view
		 */
		private function ensureTabIsVisible():void 
		{
			var tab:DisplayObject = tabBar.getChildAt(selectedIndex);
			var newHorizontalPosition:Number;
			
			if (tab.x + tab.width > canvas.horizontalScrollPosition + canvas.width) 
			{
				newHorizontalPosition = tab.x  - canvas.width + tab.width + canvas.getStyle("buttonWidth");	
			} 
			else if (canvas.horizontalScrollPosition > tab.x) 
			{
				newHorizontalPosition = tab.x - canvas.getStyle("buttonWidth");
			} 
			else 
			{
				newHorizontalPosition = canvas.horizontalScrollPosition;
			}
			
			if (newHorizontalPosition) 
			{
				// We tween the motion so it looks super sweet
				var tween:Tween = new Tween(this, canvas.horizontalScrollPosition, newHorizontalPosition, 500, -1, tween_updateHandler, tween_endHandler);
				
				// Alternatively if we didn't want to use the tweening we could just set the
				// horizontalScrollPosition right away (this is what I first did)
				//canvas.horizontalScrollPosition = newHorizontalPosition;
			}
		}
		
		/**
		 * Sets the desired close policy for a specific tab.
		 * 
		 * @param index The index position of the tab.
		 * @param value The new close policy value.
		 */
		public function setClosePolicyForTab(index:int, value:String):void 
		{
			SuperTabBar(tabBar).setClosePolicyForTab(index, value);
		}
		
	    /**
	     * Goes through all the tabs and makes sure that the drop-down
	     * list is correct. This should get called every time tabs are added, removed,
	     * or re-ordered. This is a public method so other SuperTabNavigators can call 
	     * this method on each other if we're dragging tabs from one SuperTabNavigator
	     * to another.
	     */
	    public function reorderTabList():void 
	    {
	    	var popupMenuDP:ArrayCollection = new ArrayCollection();
			
			for (var i:int = 0; i < numChildren; i++) 
			{
				var child:Container = Container(getChildAt(i));
				
				var item:Object = new Object();
				// setting the type to an empty string bypasses a bug in MenuItemRenderer (or in 
				// DefaultDataDescriptor, depending on how you look at it). Try commenting out the
				// line and check out the menu items.
				item.type = "";
				item.label = (child.label != "") ? child.label : "Untitled Tab";
				item.icon = child.icon;
				
				popupMenuDP.addItem(item);
			}
			
			menu.iconField = "icon";
			menu.dataProvider = popupMenuDP;
			
			//we re-assign the menu to the popup button each time just to be safe to
			//ensure that the PopUpBUtton hasn't set its popUp to null, which it has a 
			//tendency to do (I think only since Flex 3)
			//fixes issue #71: http://code.google.com/p/flexlib/issues/detail?id=71
			popupButton.popUp = menu;
	    }
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
	    private function childIndexChangeHandler(event:IndexChangedEvent):void 
	    {
	    	if (stopIndexChangeEvent) 
	    	{
	    		stopIndexChangeEvent = false;
	    		event.stopImmediatePropagation();
	    	}
	    }
		
		/**
		 * @private
		 * The tabs can be changed any number of ways (via drop-down menu, via AS, etc)
		 * so this listener function will make sure that the tab that gets selected is 
		 * visible.
		 */
		private function indexChangeHandler(event:IndexChangedEvent):void 
		{
			callLater(ensureTabIsVisible);
		}
		
		/**
		 * @private
		 * This is the event handler for when the user clicks the drop-down menu.
		 * If we're selecting a new tab then we'll dispatch an IndexChangedEvent, which
		 * will trigger the call to ensureTabIsVisible(). If we are not switching tabs
		 * though, then the event wouldn't get dispatched, so we have to call ensureTabIsVisible
		 */
		private function menu_itemClickHandler(event:MenuEvent):void 
		{
			if (selectedIndex == event.index) 
			{
				ensureTabIsVisible();
			}
			
			selectedIndex = event.index;
		}
		
		/**
		 * @private
		 */
	    private function tabBar_tabCloseHandler(event:SuperTabEvent):void 
	    {
	    	var clone:Event = event.clone();
	    	dispatchEvent(clone);
	    	
	    	if (clone.isDefaultPrevented()) 
	    	{
	    		event.preventDefault();
	    	}
	    }
	    
		/**
		 * @private
		 * When a tab is added or removed we need to reorder the tab list.
		 */
		private function tabBar_tabsChangedHandler(event:Event):void 
		{
			callLater(reorderTabList);
		}
	    
	    /**
	     * @private
	     */
	    private function tabBar_tabsReorderedHandler(event:TabReorderEvent):void 
	    {
	    	var clone:Event = event.clone();
	    	dispatchEvent(clone);
	    	
	    	if (clone.isDefaultPrevented()) 
	    	{
	    		return;
	    	}
	    	
	    	// The relatedObject of our custom event is the SuperTabBar component
	    	// where the tab originated. This is so we can properly move tabs from
	    	// one navigator to another.
	    	var sourceBar:SuperTabBar = event.relatedObject as SuperTabBar;
	    	var droppedTab:SuperTab = (sourceBar.getChildAt(event.oldIndex) as SuperTab);
	    	
	    	// The oldIndex property of the event specifies the index of the tab
	    	// in the original navigator. Note that the tab might not be a child of
	    	// this current tab navigator that we're in (ie sourceNav might not == this).
	    	var child:Object;
	    	var curDataProvider:Object = sourceBar.dataProvider;
	    	
	    	var lastClosePolicy:String = sourceBar.getClosePolicyForTab(event.oldIndex);
			var lastStyleName:Object = droppedTab.styleName;
	    	
	    	if (sourceBar != tabBar) 
	    	{
		    	if (curDataProvider is IList) 
		    	{
		    		child = IList(curDataProvider).getItemAt(event.oldIndex);
					curDataProvider.removeItemAt(event.oldIndex);
					
					var newChild:Canvas = new Canvas();
					
					if (child.hasOwnProperty("label")) 
					{
						newChild.label = child.label;
					}
					else 
					{
						newChild.label = child.toString();
					}
					
					if (child.hasOwnProperty("icon")) 
					{
						newChild.icon = child.icon;
					}
					
					child = newChild;
				} 
				else if (curDataProvider is ViewStack)
				{
					child = ViewStack(curDataProvider).getChildAt(event.oldIndex);
					curDataProvider.removeChildAt(event.oldIndex); 
				}
				
				if (child is DisplayObject) 
				{
		    		// We add the tab to ourself at the new index position
		    		addChildAt(DisplayObject(child), event.newIndex);
		    	}
		    	
		    	setClosePolicyForTab(event.newIndex, lastClosePolicy);
		    	droppedTab = getTabAt(event.newIndex) as SuperTab;
	    		
	    		droppedTab.styleName = lastStyleName;
	    	}
	    	else 
	    	{
	    		//If we're simply moving a tab within the same SuperTabNavigator
	    		//then we'll just use the setChildIndex method. There's a sneaky thing
	    		//though, maybe a bug, which dispatches the wrong indexes in the
	    		//IndexChangeEvent. So we dispatch our own event with the correct indexes,
	    		//and we catch the event that gets dispatched with setChildIndex and stop
	    		//it from propogating. I don't know why there's a problem with the
	    		//setChildAt method dispatching an event with an incorrect oldIndex, but
	    		//god it was hard to figure this one out. 
	    		if (event.oldIndex < event.newIndex) 
	    		{
	    			event.newIndex--;
	    		}
	    		
	    		var devent:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.CHILD_INDEX_CHANGE);
				devent.oldIndex = event.oldIndex;
				devent.newIndex = event.newIndex;
				devent.relatedObject = getChildAt(event.newIndex);
        		
        		dispatchEvent(devent);
	    		
	    		stopIndexChangeEvent = true;
	    		setChildIndex(getChildAt(event.oldIndex), event.newIndex);
	    	}
			
			// Calling validateNow before calling selectedIndex makes sure we 
		    // don't get a little display bug that tends to creep up
		    validateNow();
			
			// If we just dropped a tab then we want to select it,
		    // that just seems like the intuitive thing to do
	    	selectedIndex = event.newIndex;
	    	
	    	// Now update the drop-down menu to show the newly ordered tabs
	    	reorderTabList();
	    }
		
		/**
		 * @private
		 */
		private function tween_updateHandler(val:Object):void 
		{
			canvas.horizontalScrollPosition = Number(val);
		}
		
		/**
		 * @private
		 */
		private function tween_endHandler(val:Object):void 
		{
		   canvas.horizontalScrollPosition = Number(val);
		}
	}
}