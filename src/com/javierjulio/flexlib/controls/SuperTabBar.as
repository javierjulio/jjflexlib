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

package com.javierjulio.flexlib.controls {

	import com.javierjulio.flexlib.containers.SuperTabNavigator;
	import com.javierjulio.flexlib.controls.tabBarClasses.SuperTab;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flexlib.events.SuperTabEvent;
	import flexlib.events.TabReorderEvent;
	
	import mx.collections.IList;
	import mx.containers.ViewStack;
	import mx.controls.Button;
	import mx.controls.TabBar;
	import mx.core.ClassFactory;
	import mx.core.DragSource;
	import mx.core.IFlexDisplayObject;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Fired when a tab is dropped onto this SuperTabBar, which re-orders the tabs and updates the
	 * list of tabs.
	 */
	[Event(name="tabsReordered", type="flexlib.events.TabReorderEvent")]
	
	/**
	 * Fired when the close button of a tab is clicked. To stop the default action, which will remove the 
	 * child from the collection of children, call event.preventDefault() in your listener.
	 */
	[Event(name="tabClose", type="flexlib.events.SuperTabEvent")]
	
	/**
	 * Fired when the the label or icon of a child is updated and the tab gets updated to reflect
	 * the new icon or label. SuperTabNavigator listens for this to refresh the PopUpMenuButton data provider.
	 */
	[Event(name="tabUpdated", type="flexlib.events.SuperTabEvent")]
	
	[IconFile("SuperTabBar.png")]
	
	/**
	 *  The SuperTabBar control extends the TabBar control and adds drag and drop functionality
	 *  and closable tabs.
	 * 
	 *  <p>The SuperTabBar is used by the SuperTabNavigator component, or it can be used on its
	 *  own to independentaly control a ViewStack. SuperTabBar does not control scrolling of tabs.
	 *  Scrolling of tabs in the SuperTabNavigator is done by wrapping the SuperTabBar in a scrollable
	 *  canvas component.</p>
	 *
	 *  @mxml
	 *
	 *  <p>The <code>&lt;flexlib:SuperTabBar&gt;</code> tag inherits all of the tag attributes
	 *  of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;flexlib:SuperTabBar
	 *    <b>Properties</b>
	 *    closePolicy="SuperTab.CLOSE_ROLLOVER|SuperTab.CLOSE_ALWAYS|SuperTab.CLOSE_SELECTED|SuperTab.CLOSE_NEVER"
	 *    dragEnabled="true"
	 *    dropEnabled="true"
	 * 
	 *    <b>Events</b>
	 *    tabsReorderEvent="<i>No default</i>"
	 *    &gt;
	 *    ...
	 *       <i>child tags</i>
	 *    ...
	 *  &lt;/flexlib:SuperTabBar&gt;
	 *  </pre>
	 *
	 *  @see flexlib.containers.SuperTabNavigator
	 * 	@see mx.controls.TabBar
	 */
	public class SuperTabBar extends TabBar 
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Event that is dispatched when the tabs are re-ordered in the SuperTabBar.
		 */
		public static const TABS_REORDERED:String = "tabsReordered";
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function SuperTabBar() 
		{
			super();
			
			// we make sure that when we make new tabs they will be SuperTabs
			navItemFactory = new ClassFactory(getTabClass());
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
		private var _closePolicy:String = SuperTab.CLOSE_ROLLOVER;
		
		/**
		 * @private
		 */
		private var closePolicyChanged:Boolean = false;
		
		/**
		 * The policy for when to show the close button for each tab.
		 * <p>This is a proxy property that sets each SuperTab's closePolicy setting to
		 * whatever is set here.</p>
		 * 
		 * @default SuperTab.CLOSE_ROLLOVER
		 * 
		 * @see flexlib.controls.tabClasses.SuperTab
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
		private var _dragEnabled:Boolean = false;
		
		/**
		 * @private
		 */
		private var dragEnabledChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * Boolean indicating if this SuperTabBar allows its tabs to be dragged.
		 * 
		 * <p>If both dragEnabled and dropEnabled are true then the 
		 * SuperTabBar allows tabs to be reordered with drag and drop.</p>
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
		private var _dropEnabled:Boolean = false;
		
		/**
		 * @private
		 */
		private var dropEnabledChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		
		/**
		 * Boolean indicating if this SuperTabBar allows its tabs to be dropped 
		 * onto it.
		 * 
		 * <p>If both dragEnabled and dropEnabled are true then the 
		 * SuperTabBar allows tabs to be reordered with drag and drop.</p>
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
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: UIComponent
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			// since any property that changes we need to update all of our 
			// children we'll optimize those chnages by just doing 1 loop
			if (closePolicyChanged || dragEnabledChanged || dropEnabledChanged 
				|| editableTabLabelsChanged || enabledChanged) 
			{
				var n:int = numChildren;
		        for (var i:int = 0; i < n; i++) 
		        {
		            var child:SuperTab = SuperTab(getChildAt(i));
		            
		            if (closePolicyChanged) 
		            	child.closePolicy = _closePolicy;
		            
		            if (dragEnabledChanged) 
		            {
		            	if (_dragEnabled) 
		            		addDragListeners(child);
		            	else 
		            		removeDragListeners(child);
		            }
		            
		            if (dropEnabledChanged) 
		            {
		            	if (_dropEnabled) 
		            		addDropListeners(child);
		            	else 
		            		removeDropListeners(child);
		            }
		            
					if (editableTabLabelsChanged) 
						child.doubleClickEditable = _editableTabLabels;
					
					if (enabledChanged) 
						child.enabled = enabled;
		        }
		        
		        closePolicyChanged = false;
		        dragEnabledChanged = false;
		        dropEnabledChanged = false;
		        editableTabLabelsChanged = false;
		        enabledChanged = false;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: TabBar
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function createNavItem(label:String, icon:Class=null):IFlexDisplayObject 
		{								
			var tab:SuperTab = super.createNavItem(label, icon) as SuperTab;
			
			tab.closePolicy = _closePolicy;
			tab.doubleClickEditable = _editableTabLabels;
			
			if (_dragEnabled) 
				addDragListeners(tab);
			
			if (_dropEnabled) 
				addDropListeners(tab);
			
			// We need to listen for the close event fired from each tab.
			tab.addEventListener(SuperTab.CLOSE_TAB_EVENT, tab_tabCloseHandler, false, 0, true);
			tab.addEventListener(SuperTabEvent.TAB_UPDATED, tab_tabUpdatedHandler);
			
			return tab;
		}
		
		/**
		 * @private
		 */
		override protected function updateNavItemIcon(index:int, icon:Class):void 
		{
			super.updateNavItemIcon(index, icon);
			
			dispatchEvent(new SuperTabEvent(SuperTabEvent.TAB_UPDATED, index));
		}
		
		/**
		 * @private
		 */
		override protected function updateNavItemLabel(index:int, label:String):void 
		{
			super.updateNavItemLabel(index, label);
			
			//fix for issue #77: http://code.google.com/p/flexlib/issues/detail?id=77
			if (dataProvider is SuperTabNavigator) 
			{
				SuperTabNavigator(dataProvider).invalidateDisplayList();
			}
			
			dispatchEvent(new SuperTabEvent(SuperTabEvent.TAB_UPDATED, index));
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Adds the necessary mouse down and up event handlers on the provided tab 
		 * to support dragging capabilities.
		 * 
		 * @param tab The tab in which the event handlers are added.
		 */
		protected function addDragListeners(tab:SuperTab):void 
		{
			tab.addEventListener(MouseEvent.MOUSE_DOWN, tab_mouseDownHandler, false, 0, true);
			tab.addEventListener(MouseEvent.MOUSE_UP, tab_mouseUpHandler, false, 0, true);
		}
		
		/**
		 * Adds all drag event handlers on the provided tab.
		 * 
		 * @param tab The tab in which the event handlers are added.
		 */
		protected function addDropListeners(tab:SuperTab):void 
		{
			tab.addEventListener(DragEvent.DRAG_ENTER, tab_dragEnterHandler, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_OVER, tab_dragOverHandler, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_DROP, tab_dragDropHandler, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_EXIT, tab_dragExitHandler, false, 0, true);	
		}
		
		/**
		 * Returns the tab's close policy at the specified index.
		 * 
		 * @param index The index position of the tab.
		 * 
		 * @return The tab's close policy at the specified index.
		 */
		public function getClosePolicyForTab(index:int):String 
		{
			return SuperTab(getChildAt(index)).closePolicy;
		}
		
		/**
		 * For extensibility, if you extend <code>SuperTabBar</code> with a custom 
		 * tab bar implementation, you can override the <code>getTabClass</code> 
		 * function to return the class for the tabs that should be used. The class 
		 * that you return must extend 
		 * <code>flexlib.controls.tabBarClasses.SuperTab</code>.
		 */
		protected function getTabClass():Class 
		{
			return SuperTab;
		}
		
		/**
		 * Sets the desired close policy for a specific tab.
		 * 
		 * @param index The index position of the tab.
		 * @param value The new close policy value.
		 */
		public function setClosePolicyForTab(index:int, value:String):void 
		{
			if (index >= 0 && index < numChildren) 
			{
				(SuperTab(getChildAt(index))).closePolicy = value;
			}
		}
		
		/**
		 * Removes mouse down and up event handlers on the provided tab.
		 * 
		 * @param tab The tab in which the event handlers are removed from.
		 */
		protected function removeDragListeners(tab:SuperTab):void 
		{
			tab.removeEventListener(MouseEvent.MOUSE_DOWN, tab_mouseDownHandler);
			tab.removeEventListener(MouseEvent.MOUSE_UP, tab_mouseUpHandler);
		}
		
		/**
		 * Removes all drag event handlers on the provided tab.
		 * 
		 * @param tab The tab in which the event handlers are removed from.
		 */
		protected function removeDropListeners(tab:SuperTab):void 
		{
			tab.removeEventListener(DragEvent.DRAG_ENTER, tab_dragEnterHandler);
			tab.removeEventListener(DragEvent.DRAG_OVER, tab_dragOverHandler);
			tab.removeEventListener(DragEvent.DRAG_DROP, tab_dragDropHandler);
			tab.removeEventListener(DragEvent.DRAG_EXIT, tab_dragExitHandler);	
		}
		
		/**
		 * Resets all tabs.
		 */
		public function resetTabs():void 
		{
			resetNavItems();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function tab_dragDropHandler(event:DragEvent):void 
		{
			if (event.dragSource.hasFormat("tabDrag") && event.draggedItem != event.dragInitiator) 
			{
				var dropTab:SuperTab = (event.currentTarget as SuperTab);
				var dragTab:SuperTab = (event.dragInitiator as SuperTab);
				
				var left:Boolean = event.localX < (dropTab.width / 2);
				
				var parentBar:SuperTabBar;
				
				// Since we allow mouseChildren to enabled the close button we might
				// get drag and drop events fired from the children components (ie the label
				// or icon). So we need to find the SuperTab object, SuperTabBar, and the 
				// SuperTabNavigator object from wherever we might be down the chain of children.
				var object:* = event.dragInitiator;
				
				while (object && object.parent) 
				{
					object = object.parent;
					
					if (object is SuperTab) 
					{
						dragTab = SuperTab(object);
					} 
					else if (object is SuperTabBar) 
					{
						parentBar = SuperTabBar(object);
						break;
					} /*
					else if (object is SuperTabNavigator) 
					{
						parentNavigator = SuperTabNavigator(object);
						break;
					}*/
				}
				
				// We've done the drop so no need to show the indicator anymore	
				dropTab.showDropIndicator = false;
				
				var oldIndex:Number = parentBar.getChildIndex(dragTab);
				
				var newIndex:Number = getChildIndex(dropTab);
				if (!left) 
					newIndex += 1;
				
				dispatchEvent(new TabReorderEvent(SuperTabBar.TABS_REORDERED, false, true, parentBar, oldIndex, newIndex));
			}
		}
		
		/**
		 * @private
		 */
		private function tab_dragEnterHandler(event:DragEvent):void 
		{
			if (event.dragSource.hasFormat("tabDrag") && event.draggedItem != event.dragInitiator) 
			{
				if (dataProvider is ViewStack) 
				{
					if (event.dragSource.hasFormat("stackDP")) 
					{
						DragManager.acceptDragDrop(IUIComponent(event.target));
					}
				} 
				else if (dataProvider is IList) 
				{
					if (event.dragSource.hasFormat("listDP")) 
					{
						DragManager.acceptDragDrop(IUIComponent(event.target));
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		private function tab_dragExitHandler(event:DragEvent):void 
		{
			var dropTab:SuperTab = SuperTab(event.currentTarget);
			
			// turn off showing the indicator icon
			dropTab.showDropIndicator = false;
		}
		
		/**
		 * @private
		 */
		private function tab_dragOverHandler(event:DragEvent):void 
		{
			// We should accept tabs dragged onto other tabs, but not a tab dragged onto itself
			if (event.dragSource.hasFormat("tabDrag") && event.dragInitiator != event.currentTarget) 
			{
				var dropTab:SuperTab = SuperTab(event.currentTarget);
				var dropIndex:Number = getChildIndex(dropTab);
				
				// gap is going to be the indicatorOffset that will be used to place the indicator
				var gap:Number = 0;
				
				// We need to figure out if we're on the left half or right half of the
				// tab. This boolean tells us this so we know where to draw the indicator
				var left:Boolean = event.localX < (dropTab.width / 2);
				
				if ((left && dropIndex > 0) || (dropIndex < numChildren - 1)) 
				{
					gap = getStyle("horizontalGap") / 2;
				}
				
				gap = left ? -gap : dropTab.width + gap;
				
				dropTab.showDropIndicatorAt(gap);
				
				DragManager.showFeedback(DragManager.LINK);
			}
		}
		
		/**
		 * @private
		 */
		private function tab_mouseDownHandler(event:MouseEvent):void 
		{
			SuperTab(event.currentTarget).addEventListener(MouseEvent.MOUSE_MOVE, tab_mouseMoveHandler);
		}
		
		/**
		 * @private
		 */
		private function tab_mouseMoveHandler(event:MouseEvent):void 
		{
			if (event.target is IUIComponent 
				&& (IUIComponent(event.target) is SuperTab 
				|| (IUIComponent(event.target).parent is SuperTab 
				&& !(IUIComponent(event.target) is Button)))) 
			{
				var tab:SuperTab;
				
				if (IUIComponent(event.target) is SuperTab) 
				{
					tab = IUIComponent(event.target) as SuperTab;
				}
				
				if (IUIComponent(event.target).parent is SuperTab) 
				{
					tab = IUIComponent(event.target).parent as SuperTab;
				}
				
				var ds:DragSource = new DragSource();
				ds.addData(event.currentTarget, "tabDrag");
				
				if (dataProvider is IList) 
				{
					ds.addData(event.currentTarget, "listDP");	
				}
				
				if (dataProvider is ViewStack) 
				{
					ds.addData(event.currentTarget, "stackDP");	
				}
				
				var bmapData:BitmapData = new BitmapData(tab.width, tab.height, true, 0x00000000);
				bmapData.draw(tab);
				
				var dragProxy:Bitmap = new Bitmap(bmapData);
				
				var obj:UIComponent = new UIComponent();
				obj.addChild(dragProxy);
				
				tab.removeEventListener(MouseEvent.MOUSE_MOVE, tab_mouseMoveHandler);
				
				DragManager.doDrag(IUIComponent(event.target), ds, event, obj);
			}
		}
		
		/**
		 * @private
		 */
		private function tab_mouseUpHandler(event:MouseEvent):void 
		{
			SuperTab(event.currentTarget).removeEventListener(MouseEvent.MOUSE_MOVE, tab_mouseMoveHandler);
		}
		
		/**
		 * @private
		 * When a tab closes it dispatches a close event. This listener gets fired 
		 * in response to that event. We remove the tab from the dataProvider. This 
		 * might be as simple as removing the tab, but the dataProvider might be a 
		 * ViewStack, which means we remove the entire child from the dataProvider 
		 * (which removes it from the ViewStack).
		 */
		private function tab_tabCloseHandler(event:Event):void 
		{
			var index:int = getChildIndex(DisplayObject(event.currentTarget));
			
			// dispatch an event that can be prevented, this allows a developer to 
			// listen for the event and call event.preventDefault(), which stops 
			// the default action (removing the child)
			var tabCloseEvent:SuperTabEvent = new SuperTabEvent(SuperTabEvent.TAB_CLOSE, index, false, true);
			dispatchEvent(tabCloseEvent);
			
			// the action was not prevented so continue with default which 
			// is to remove the associated item from the provider
			if (!tabCloseEvent.isDefaultPrevented()) 
			{
				if (dataProvider is IList) 
				{
					IList(dataProvider).removeItemAt(index);
				}
				else if (dataProvider is ViewStack) 
				{
					ViewStack(dataProvider).removeChildAt(index);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function tab_tabUpdatedHandler(event:SuperTabEvent):void 
		{
			var tab:SuperTab = SuperTab(event.currentTarget);
			var index:Number = getChildIndex(tab);
			
			var item:Object;
			
			// retrieve the item to be update
			if (dataProvider is IList) 
			{
				item = IList(dataProvider).getItemAt(index);
			} 
			else if (dataProvider is ViewStack) 
			{
				item = ViewStack(dataProvider).getChildAt(index);
			}
			
			// update the item's label with the edited label from the tab
			if (labelField) 
			{
				item[labelField] = tab.label;
			} 
			else if (item.hasOwnProperty("label")) 
			{
				item.label = tab.label;
			}
		}
	}
}