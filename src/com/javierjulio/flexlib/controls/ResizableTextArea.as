package com.javierjulio.flexlib.controls
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.core.EdgeMetrics;
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
	 * Dispatched before and while the TextArea 
	 * is resized. This event is cancelable.
	 * 
	 * @eventType resizing
	 */
	[Event(name="resizing", type="flash.events.Event")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * The gripper button default skin.
	 *
	 * @default resizable_gripper.png
	 */
	[Style(name="gripperButtonSkin", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 * The extra space around the gripper. The total area of the gripper
	 * plus the padding around the edges is the hit area for the gripper resizing.
	 *
	 * @default 3
	 */
	[Style(name="gripperPadding", type="Number", format="Length", inherit="no")]
	
	/**
	 * Style declaration for the skin of the gripper.
	 *
	 * @default "gripperSkin"
	 */
	[Style(name="gripperStyleName", type="String", inherit="no")]
	
	/**
	 * The ResizableTextArea is a standard TextArea but adds a gripper to the bottom 
	 * right hand corner of the control. When moused down you can drag to resize the 
	 * TextArea (just like HTML TextArea's in Safari). This class follows the same 
	 * API as the Window class in AIR (same properties and styles).
	 * 
	 * @mxml
	 *
	 * <p>The <code>&lt;ResizableTextArea&gt;</code> tag inherits all of the tag
	 * attributes of its superclass (TextArea) and adds the following tag attributes:</p>
	 *
	 * <pre>
	 * &lt;ResizableTextArea
	 *   <strong>Styles</strong>
	 *   gripperPadding="3"
	 *   gripperStyleName="gripperSkin"
	 * 
	 *   <strong>Events</strong>
	 *   resizing="<i>No default</i>"
	 * /&gt;
	 * </pre>
	 * 
	 * @see mx.controls.TextArea
	 */
	public class ResizableTextArea extends TextArea
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const LOGGER:ILogger = Log.getLogger("com.javierjulio.flexlib.controls.ResizableTextArea");
		
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
		 */
		[Embed(source="/assets/images/resize_gripper.png")] 
		private static var gripperButtonSkin:Class;
		
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
			if (!StyleManager.getStyleDeclaration("ResizableTextArea"))
			{
				// there is no CSS definition for ResizableTextArea so set default values
				var styles:CSSStyleDeclaration = new CSSStyleDeclaration();
				styles.defaultFactory = function():void 
				{
					this.gripperButtonSkin = gripperButtonSkin;
					this.gripperPadding = 3;
					this.gripperStyleName = "gripperSkin";
				}
				StyleManager.setStyleDeclaration("ResizableTextArea", styles, false);
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Internal storage for the Gripper button.
		 */
		protected var gripper:Button;
		
		/**
		 * The gripper's hit area which is a little large than the gripper itself.
		 */
		protected var gripperHit:Sprite;
		
		/**
		 * Internal storage for the TextArea height before it is being resized.
		 */
		protected var startHeight:Number;
		
		/**
		 * Internal storage for tracking the point coordinates before resizing.
		 */
		protected var startPosition:Point;
		
		/**
		 * Internal storage for the TextArea width before it is being resized.
		 */
		protected var startWidth:Number;
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ResizableTextArea() 
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  gripperButtonStyleFilters
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the gripperButtonStyleFilters property.
		 */
		private static var _gripperButtonStyleFilters:Object = 
		{
			"gripperButtonSkin" : "gripperButtonSkin",
			"gripperStyleName" : "gripperStyleName",
			"repeatDelay" : "repeatDelay",
			"repeatInterval" : "repeatInterval"
		}
		
		/**
		 * The set of styles to pass from the TextArea to the resizable gripper button.
		 * 
		 * @see mx.styles.StyleProxy
		 */
		protected function get gripperButtonStyleFilters():Object
		{
			return _gripperButtonStyleFilters;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  showGripper
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the showGripper property.
		 */
		private var _showGripper:Boolean = true;
		
		/**
		 * @private
		 */
		private var showGripperChanged:Boolean = true;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		
		/**
		 * If <code>true</code>, the gripper is visible.
		 * 
		 * @default true
		 */
		public function get showGripper():Boolean 
		{
			return _showGripper;
		}
		
		/**
		 * @private
		 */
		public function set showGripper(value:Boolean):void 
		{
			if (_showGripper == value) 
				return;
			
			_showGripper = value;
			showGripperChanged = true;
			
			invalidateProperties();
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  resizeDirection
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the resizeDirection property.
		 */
		private var _resizeDirection:String = "both";
		
		[Inspectable(category="General", enumeration="both,horizontal,vertical", defaultValue="both")]
		
		/**
		 * If <code>horizontal</code>, the TextArea is only resized horizontally. 
		 * If <code>vertical</code>, the TextArea is only resized vertically. Otherwise 
		 * the default value <code>both</code> allows the TextArea to be resized in 
		 * any direction.
		 */
		public function get resizeDirection():String 
		{
			return _resizeDirection;
		}
		
		/**
		 * @private
		 */
		public function set resizeDirection(value:String):void 
		{
			_resizeDirection = value;
		}
		
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
			super.createChildren();
			
			if (!gripper) 
			{
				gripper = new Button();
				gripper.enabled = enabled;
				gripper.focusEnabled = false;
				gripper.styleName = new StyleProxy(this, gripperButtonStyleFilters);
				gripper.skinName = "gripperButtonSkin";	// set the default gripper skin name
				addChild(gripper);
				
				gripperHit = new Sprite();
				gripperHit.addEventListener(MouseEvent.MOUSE_DOWN, gripperHit_mouseDownHandler, false, 0, true);
				addChild(gripperHit);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			if (showGripperChanged) 
			{
				if (gripper) 
				{
					gripper.includeInLayout = _showGripper;
					gripper.visible = _showGripper;
					gripperHit.visible = _showGripper;
				}
				
				showGripperChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// we use viewMetrics since it accounts for both borders and scrollbars
			var vm:EdgeMetrics = viewMetrics;
			vm.left += getStyle("paddingLeft");
			vm.top += getStyle("paddingTop");
			vm.right += getStyle("paddingRight");
			vm.bottom += getStyle("paddingBottom");
			
			if (gripper) 
			{
				var gripperPadding:Number = getStyle("gripperPadding");
				
				// size the gripper, and position it at the bottom right hand corner
				gripper.setActualSize(gripper.measuredWidth, gripper.measuredHeight);
				gripper.move(unscaledWidth - gripper.measuredWidth - gripperPadding, 
							unscaledHeight - gripper.measuredHeight - gripperPadding);
				
				// make our hit area sprite transparent and a little larger by 
				// using the specified gripper padding
				gripperHit.graphics.beginFill(0xffffff, .0001);
				gripperHit.graphics.drawRect(0, 0, 
					gripper.width + (2 * gripperPadding), 
					gripper.height + (2 * gripperPadding));
				
				// position the invisible hit area just above the actual gripper
				gripperHit.x = gripper.x - gripperPadding;
				gripperHit.y = gripper.y - gripperPadding;
				
				// we have a visible verticalScrollBar so we need to make some 
				// height adjustments so the bar doesn't overlap the gripper
				if (verticalScrollBar && verticalScrollBar.visible) 
				{
					// a gripper is set to be displayed so adjust scroll bar height, 
					// we don't need to account if gripper is turned off because 
					// the default behavior is what we want in that case
					if (showGripper) 
					{
						verticalScrollBar.setActualSize(verticalScrollBar.minWidth, 
							unscaledHeight - (gripper.height + (2 * gripperPadding)) - vm.top - vm.bottom);
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void 
		{
			super.styleChanged(styleProp);
			
			if (styleProp == null || styleProp == "gripperPadding") 
			{
				invalidateDisplayList();
				invalidateSize();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Helper that returns a local point from a MouseEvent.
		 * 
		 * @return Point the local point from the provided MouseEvent.
		 */
		protected function getMousePosition(event:MouseEvent):Point 
		{
			var point:Point = new Point(event.stageX, event.stageY);
			point = globalToLocal(point);
			return point;
		}
		
		/**
		 * Handles the MOUSE_DOWN event on the gripper hit area so we can setup 
		 * the necessary handlers and track starting position related data.
		 */
		protected function gripperHit_mouseDownHandler(event:MouseEvent):void 
		{
			startHeight = height;
			startWidth = width;
			startPosition = getMousePosition(event);
			
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
			systemManager.stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
		}
		
		/**
		 * Handles the MOUSE_LEAVE event so we can stop resizing in case the user 
		 * drags their cursor off the stage. If we didn't, when the cursor returned 
		 * to the stage it would still resize despite the user mousing up.
		 */
		protected function stage_mouseLeaveHandler(event:Event):void 
		{
			stopResizing();
		}
		
		/**
		 * Helper to stop resizing by removing necessary systemManager event handlers.
		 */
		protected function stopResizing():void 
		{
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
			systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseLeaveHandler, true);
		}
		
		/**
		 * Handles the MOUSE_MOVE event so as the user moves their cursor (while mouse 
		 * down) we can resize both the width and height of the textarea.
		 */
		protected function systemManager_mouseMoveHandler(event:MouseEvent):void 
		{
			var resizeEvent:Event = new Event("resizing", false, true);
			dispatchEvent(resizeEvent);
			
			// event is canceled so stop resizing
			if (resizeEvent.isDefaultPrevented()) 
			{
				stopResizing(); // removes resize enabling handlers
				return;
			}
			
			var newMousePosition:Point = getMousePosition(event);
			var newX:Number = newMousePosition.x - startPosition.x;
			var newY:Number = newMousePosition.y - startPosition.y;
			
			if (resizeDirection == 'horizontal' || resizeDirection == 'both') 
			{
				// adjust width as user resizes window, respect max/min width specified
				if (startWidth + newX <= maxWidth && startWidth + newX >= minWidth) 
					width = startWidth + newX;
				else if (startWidth + newY >= maxWidth) 
					width = maxWidth;
				else if (startWidth + newY <= minWidth) 
					width = minWidth;
			}
			
			if (resizeDirection == 'vertical' || resizeDirection == 'both') 
			{
				// adjust height as user resizes window, respect max/min height specified
				if (startHeight + newY <= maxHeight && startHeight + newY >= minHeight) 
					height = startHeight + newY;
				else if (startHeight + newY >= maxHeight) 
					height = maxHeight;
				else if (startHeight + newY <= minHeight) 
					height = minHeight;
			}
		}
		
		/**
		 * Handles the MOUSE_UP event so we can stop resizing since the user has 
		 * let go of the gripper handle.
		 */
		protected function systemManager_mouseUpHandler(event:MouseEvent):void 
		{
			stopResizing();
		}
	}
}