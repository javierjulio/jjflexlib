package com.javierjulio.flexlib.containers
{
	import com.javierjulio.flexlib.events.WindowEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.core.EdgeMetrics;
	import mx.core.FlexVersion;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when the user double clicks the title bar portion of the TitleWindow
	 * to collapse the window content (if collapsing is enabled).
	 *
	 * @eventType com.javierjulio.flexlib.events.WindowEvent.COLLAPSE
	 */
	[Event(name="collapse", type="com.javierjulio.flexlib.events.WindowEvent")]
	
	/**
	 * Dispatched when the user resizes the window by clicking and holding the resize 
	 * button in the bottom right corner.
	 * 
	 * @eventType com.javierjulio.flexlib.events.WindowEvent.RESIZE
	 */
	[Event(name="resize", type="com.javierjulio.flexlib.events.WindowEvent")]
	
	/**
	 * Dispatched when the user expands the window content by double clicking on the
	 * title bar portion of the TitleWindow (if collapsing is enabled).
	 *
	 * @eventType com.javierjulio.flexlib.events.WindowEvent.RESTORE
	 */
	[Event(name="restore", type="com.javierjulio.flexlib.events.WindowEvent")]
	
	public class CanvasWindow extends TitleWindow
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Internal flag that indicates the component has been resized so we can 
		 * reposition the resizeHandler when updating the display list.
		 */
		private var resized:Boolean = false;
		
		/**
		 * Storage for the button that when interacted with allows resizing.
		 */
		protected var resizeHandler:Button;
		
		/**
		 * Storage for tracking the original point coordinates after resizing.
		 */
		protected var originalPoint:Point = new Point();
		
		/**
		 * Storage for the original title needed when truncating.
		 */
		protected var originalTitle:String;
		
		/**
		 * Storage for the height before it has been collapsed or resized.
		 */
		protected var originalHeight:Number;
		
		/**
		 * Storage for the width before it has been collapsed or resized.
		 */
		protected var originalWidth:Number;
		
		/**
		 * Storage for the x coordinate before window has been dragged and moved 
		 * elsewhere or resized via the resize button.
		 */
		protected var originalX:Number;
		
		/**
		 * Storage for the y coordinate before window has been dragged and moved 
		 * elsewhere or resized via the resize button.
		 */
		protected var originalY:Number;
		
		//--------------------------------------------------------------------------
	    //
	    //  Constructor
	    //
	    //--------------------------------------------------------------------------
		
	    /**
	     * Constructor.
	     */
		public function CanvasWindow()
		{
			super();
			
			addEventListener(KeyboardEvent.KEY_DOWN, closeHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		
		//----------------------------------
		//  closeEnabled
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the closeEnabled property.
		 */
		private var _closeEnabled:Boolean = false;
		
		/**
		 * @private
		 */
		private var closeEnabledChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * If <code>true</code>, the component sets the showCloseButton property of a TitleWindow
		 * to true and automatically applies a handler to the close event and removes the 
		 * window when clicked. Note this is just a short hand so you don't have to write the 
		 * handler if all you want is for the window to be removed.
		 * 
		 * @default false
		 */
		public function get closeEnabled():Boolean 
		{
			return _closeEnabled;
		}
		
		/**
		 *  @private
		 */
		public function set closeEnabled(value:Boolean):void 
		{
			if (_closeEnabled == value) 
				return;
			
			_closeEnabled = value;
			closeEnabledChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  collapsed
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the collapsed property.
		 */
		private var _collapsed:Boolean = false;
		
		/**
		 * A flag that indicates if this window is in a collapsed state.
		 */
		public function get collapsed():Boolean 
		{
			return _collapsed;
		}
		
		//----------------------------------
		//  collapsible
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the collapsible property.
		 */
		private var _collapsible:Boolean = false;
		
		/**
		 * @private
		 */
		private var collapsibleChanged:Boolean = false;
		
    	[Inspectable(category="General", enumeration="true,false", defaultValue="false")]

		/**
		 * If <code>true</code>, the component sets the doubleClickEnabled property of the 
		 * window and adds a handler that will collapse or restore the window while 
		 * respecting its original height when restoring.
		 * 
		 * @default false
		 */
		public function get collapsible():Boolean 
		{
			return _collapsible;
		}
		
		/**
		 * @private
		 */
		public function set collapsible(value:Boolean):void 
		{
			if (_collapsible == value) 
				return;
			
			_collapsible = value;
			collapsibleChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  draggable
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the draggable property.
		 */
		private var _draggable:Boolean = false;
		
		/**
		 * @private
		 */
		private var draggableChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * If <code>true</code>, the component enables dragging of the window when 
		 * clicking and holding the title bar portion of the window.
		 * 
		 * @default false
		 */
		public function get draggable():Boolean 
		{
			return _draggable;
		}
		
		/**
		 * @private
		 */
		public function set draggable(value:Boolean):void 
		{
			if (_draggable == value) 
				return;
			
			_draggable = value;
			draggableChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  resizable
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the resizable property.
		 */
		private var _resizable:Boolean = false;
		
		/**
		 * @private
		 */
		private var resizableChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * If <code>true</code>, the component enables resizing of the window when 
		 * clicking and holding the resize button (skinnable) at the bottom right hand 
		 * corner of the window.
		 * 
		 * @default false
		 */
		public function get resizable():Boolean 
		{
			return _resizable;
		}
		
		/**
		 * @private
		 */
		public function set resizable(value:Boolean):void 
		{
			if (_resizable == value) 
				return;
			
			_resizable = value;
			resizableChanged = true;
			
			invalidateProperties();
			/*
			// make sure we have a minimum width and height if resizing is enabled
			if (value) 
			{
				minHeight = 125;
				minWidth = 100;
			}*/
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
			
			resizeHandler = new Button();
			resizeHandler.width = 12;
			resizeHandler.height = 12;
			resizeHandler.styleName = "resizeHandler";
			resizeHandler.focusEnabled = false;
			resizeHandler.addEventListener(MouseEvent.MOUSE_DOWN, resizeButton_mouseDownHandler, false, 0, true);
			rawChildren.addChild(resizeHandler);
			
			// keep track of these values from their original state
			originalTitle = title;
			originalHeight = height;
			originalWidth = width;
			originalX = x;
			originalY = y;
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			if (closeEnabledChanged) 
			{
				if (_closeEnabled) 
					addEventListener(CloseEvent.CLOSE, closeHandler, false, 0, true);
				else 
					removeEventListener(CloseEvent.CLOSE, closeHandler);
				
				showCloseButton = _closeEnabled;
				
				closeEnabledChanged = false;
			}
			
			if (collapsibleChanged) 
			{
				if (_collapsible) 
				{
					// collapsing is triggered by double clicking the titleBar
					titleBar.doubleClickEnabled = true;
					titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, titleBar_doubleClickHandler, false, 0, true);
				} 
				else 
				{
					titleBar.doubleClickEnabled = false;
					titleBar.removeEventListener(MouseEvent.DOUBLE_CLICK, titleBar_doubleClickHandler);
				}
				
				collapsibleChanged = false;
			}
			
			if (draggableChanged) 
			{
				if (_draggable) 
				{
					// to truncate the title in the titleBar we need to wait for all its children to be created
					titleBar.addEventListener(FlexEvent.CREATION_COMPLETE, titleBar_creationCompleteHandler, false, 0, true);
					titleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBar_mouseDownHandler, false, 0, true);
				} 
				else 
				{
					titleBar.removeEventListener(MouseEvent.MOUSE_DOWN, titleBar_mouseDownHandler);
				}
				
				draggableChanged = false;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: UIComponent
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.layoutChrome(unscaledWidth, unscaledHeight);
			
			// Special case for the default borderSkin to inset the chrome content
			// by the borderThickness when borderStyle is "solid", "inset" or "outset". 
			// We use getQualifiedClassName to avoid bringing in a dependency on 
			// mx.skins.halo.PanelSkin. 
			var em:EdgeMetrics = EdgeMetrics.EMPTY;
			var bt:Number = getStyle("borderThickness"); 
			if (getQualifiedClassName(border) == "mx.skins.halo::PanelSkin" &&
				getStyle("borderStyle") != "default" && bt) 
			{
				em = new EdgeMetrics(bt, bt, bt, bt);
			}
			
			// Remove the borderThickness from the border metrics,
			// since the header and control bar overlap any solid border.
			var bm:EdgeMetrics = FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0 
									? borderMetrics 
									: em;
			
			var x:Number = bm.left;
			var y:Number = bm.top;
			
			/* 
			// as long as the window is not collapsed readjust the y position accordingly
			if (!_collapsed) 
				resizeHandler.y = height - resizeHandler.height;
			
			resizeHandler.x = width - resizeHandler.width;
			 */
			
			// resizing is turned on so display the handler and position it
			if (_resizable) 
			{
				resizeHandler.includeInLayout = resizeHandler.visible = true;
				
				resizeHandler.move(unscaledWidth - resizeHandler.getExplicitOrMeasuredWidth() - bm.right, 
								unscaledHeight - resizeHandler.getExplicitOrMeasuredHeight() - bm.bottom);
			} 
			else 
			{
				// otherwise we have to hide the handler
				resizeHandler.includeInLayout = resizeHandler.visible = false;
			}
		}
		
	    //--------------------------------------------------------------------------
	    //
	    //  Methods
	    //
	    //--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Truncates title text so that it fits within the viewable portion of the 
		 * title bar. Note that their is a fixed amount deducted from the width of
		 * 40 pixels so that the "..." appears just before the close button.
		 */
		private function truncateTitleToFit(truncationIndicator:String = null):Boolean 
		{
			var truncate:Boolean = false;
			
			titleTextField.text = originalTitle;
			truncate = titleTextField.truncateToFit();
			
			// if text is to long and should be truncated
			if (truncate) 
			{
				/*
				var newWidth:Number = this.titleTextField.width;
	            for (var i:uint = 1; i < this.titleBar.numChildren; i++) {
	            	var _com:DisplayObject = this.titleBar.getChildAt(i) as DisplayObject;
	            	if (_com != this.titleTextField) {
	            		newWidth = newWidth - _com.width;
	            	}
	            }
				*/
				// then reset the original title and truncate it with the indicator
				titleTextField.text = originalTitle;
				titleTextField.toolTip = originalTitle;
				titleTextField.width = titleBar.width - 40;
				titleTextField.truncateToFit(truncationIndicator);
			}

			return truncate;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Handles close event if closeEnabled is set to <code>true</code> by closing 
		 * and removing the window. Note that the closeEnabled is just a short hand 
		 * so you don't have to write this handler if all you want is for the window 
		 * to be removed from its parent. If this is not the desired functionality 
		 * then listen and handle the CloseEvent.CLOSE.
		 */
		private function closeHandler(event:Event):void 
		{
			if (event is CloseEvent || 
				(event is KeyboardEvent && KeyboardEvent(event).keyCode == Keyboard.ESCAPE)) 
			{
				// if we aren't a popup then this was added as a child, remove it
				if (!isPopUp && parent) 
					parent.removeChild(this);
				else 
					PopUpManager.removePopUp(this);
			}
		}
		
		/**
		 * @private
		 * Handles user selecting a window so if that window is hiding behind other 
		 * windows it is brought up in front of all others and given focus. This 
		 * only occurs if this window is not used as a popUp. Use the 
		 * <code>PopUpManager.bringToFront(window)</code> method.
		 */
		private function mouseDownHandler(event:MouseEvent):void 
		{
			if (!isPopUp && parent && parent is DisplayObjectContainer) 
			{
				var numSiblings:int = parent.numChildren;
				
				// when a window that is interacted with (clicked on) and that window is 
				// behind another, we need to bring it above all others
				if (numSiblings > 0) 
					parent.setChildIndex(this, numSiblings - 1);
				
				setFocus();
			}
		}
		
		/**
		 * @private
		 * Handles user clicking and holding on the resize button.
		 */
        private function resizeButton_mouseDownHandler(event:MouseEvent):void 
        {
            systemManager.addEventListener(MouseEvent.MOUSE_MOVE, resizeButton_mouseMoveHandler);
            systemManager.addEventListener(MouseEvent.MOUSE_UP, resizeButton_mouseUpHandler);
			
            originalPoint.x = mouseX;
            originalPoint.y = mouseY;
            originalPoint = localToGlobal(originalPoint);
        }
		
		/**
		 * @private
		 * Handles user resizing the TitleWindow by moving their mouse while 
		 * clicking and holding the resize button.
		 */
		private function resizeButton_mouseMoveHandler(event:MouseEvent):void 
		{
			var xPlus:Number = event.stageX - originalPoint.x;            
			var yPlus:Number = event.stageY - originalPoint.y;
			
			// adjust width and height as user resizes window, respect minimum width/height specified
			if (originalWidth + xPlus >= minWidth) 
			{
			    width = originalWidth + xPlus;
			}
			if (!_collapsed && originalHeight + yPlus >= minHeight) 
			{
			    height = originalHeight + yPlus;
			}
			
			resized = true;
			invalidateDisplayList();
			
			dispatchEvent(new WindowEvent(WindowEvent.RESIZE));
        }
		
		/**
		 * @private
		 * Handles user letting go of the resize button and tracking the original 
		 * height (only if collapsed), x and y coordinates of the TitleWindow.
		 */
        private function resizeButton_mouseUpHandler(event:MouseEvent):void 
        {
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, resizeButton_mouseMoveHandler);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, resizeButton_mouseUpHandler);
			
			// don't reset originalHeight if resizing collapsed window
			// when window is collapsed can only resize horizontally
			if (!_collapsed) 
				originalHeight = height;
			
			originalWidth = width;
			originalX = x;
			originalY = y;
			
			truncateTitleToFit();
        }
		
		/**
		 * @private
		 * Handles creation complete event on the titleBar component of the TitleWindow 
		 * and truncates the title text within a resizable window.
		 */
		private function titleBar_creationCompleteHandler(event:FlexEvent):void 
		{
			titleBar.removeEventListener(FlexEvent.CREATION_COMPLETE, titleBar_creationCompleteHandler);
			
			truncateTitleToFit();
		}
		
		/**
		 * @private
		 * Handles user double-click on the header area. If the window is currently in 
		 * a collapsed state the window is set back to its original height before it was 
		 * collapsed otherwise if collapsed only the title bar is visible.
		 */
		private function titleBar_doubleClickHandler(event:MouseEvent):void 
		{
			if (!_collapsed) 
			{
				height = getHeaderHeight();
				_collapsed = true;
				dispatchEvent(new WindowEvent(WindowEvent.COLLAPSE));
			} 
			else 
			{
				height = originalHeight;
				_collapsed = false;
				dispatchEvent(new WindowEvent(WindowEvent.RESTORE));
			}
			
			resizeHandler.y = height - resizeHandler.height - 1;
			resizeHandler.x = width - resizeHandler.width - 1;
		}
		
		/**
		 * @private
		 * Handles user mousing down on the title bar so we can track mouse movements to 
		 * enable dragging of the window.
		 */
		private function titleBar_mouseDownHandler(event:MouseEvent):void 
		{
			// we could just set the isPopUp property to true to trigger dragging 
			// but just not right since that might cause issues if later the 
			// component is used as an actual popup so instead what we'll do 
			// is start dragging manually if we aren't a popup since we only 
			// add this handler if the CanvasWindow is draggable
			if (enabled && !isPopUp) 
				startDragging(event);
		}
		
		/**
		 * @private
		 * Handles user releasing their click-hold on the title bar to stop dragging.
		 */
		private function titleBar_mouseUpHandler(event:MouseEvent):void 
		{
			stopDragging();
			
			originalX = x;
			originalY = y;
		}
	}
}