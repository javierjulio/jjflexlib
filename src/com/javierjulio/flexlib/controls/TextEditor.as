package com.javierjulio.flexlib.controls
{
	import com.javierjulio.flexlib.controls.textEditorClasses.LineNumberedField;
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.controls.TextArea;
	import mx.core.EdgeMetrics;
	import mx.core.IUITextField;
	import mx.events.ResizeEvent;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 *  Name of CSS style declaration that specifies the styles to use for the link
	 *  button navigation items.
	 * 
	 *  @default "lineNumberedTextFieldStyleName"
	 */
	[Style(name="lineNumberedTextFieldStyleName", type="String", inherit="no")]
	
	/**
	 * 
	 */
	public class TextEditor extends TextArea
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
			if (!StyleManager.getStyleDeclaration("TextEditor")) 
			{
				// there is no CSS definition for LabelHeader so set default values
				var styles:CSSStyleDeclaration = new CSSStyleDeclaration();
				styles.defaultFactory = function():void 
				{
					this.focusAlpha = 0;
					this.focusThickness = 0;
				}
				StyleManager.setStyleDeclaration("TextEditor", styles, false);
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Storage for the last value of the textField numLines property when a 
		 * keyboard event is picked up for the BACKSPACE or DELETE key.
		 */
		protected var prevNumLinesOnDeletion:Number = 0;
		
		/**
		 * Storage for the styleName property for the line numbered text field.
		 */
		protected var lineNumStyleNameProp:String = "lineNumberedTextFieldStyleName";
		
		/**
		 * The internal UITextField that renders the line numbers of this TextArea.
		 */
		protected var lineNumTextField:IUITextField;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function TextEditor()
		{
			super();
			
			addEventListener(ResizeEvent.RESIZE, resizeHandler);
			addEventListener(ScrollEvent.SCROLL, scrollingHandler);
			addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  caretLineIndex
		//----------------------------------
		
		/**
		 * Returns the zero-based line index of where the caret currently resides.
		 */
		public function get caretLineIndex():Number 
		{
			var _caretLineIndex:int = 0;
			var _caretIndex:int = textField.selectionBeginIndex;
			
			// with only 1 line we already know the line index the user is at
			if (textField.numLines == 1) 
			{
				_caretLineIndex = 0;
			} // things get hairy when determining the line index for a caret on an empty line
			else if (textField.getLineIndexOfChar(_caretIndex) == -1) 
			{
				// since we didn't get a valid line index with the normal selection index 
				// then we will get the previous line by going one character before
				var line:int = textField.getLineIndexOfChar(_caretIndex-1);
				
				// as long as we have a valid line number and the length of the next line 
				// (which is the real one we want) is 0 
				// then caret is on an empty line so set the correct line index
				if ( line + 1 < textField.numLines && textField.getLineLength(line + 1) == 0) 
				{
					_caretLineIndex = line + 1;
				} 
				else 
				{
					_caretLineIndex = line;
				}
			} 
			else 
			{
				// all other cases should return a valid line index
				_caretLineIndex = textField.getLineIndexOfChar(_caretIndex);
			}
			
			return _caretLineIndex;
		}
		
		//----------------------------------
		//  caretPosition
		//----------------------------------
		
		/**
		 * Retuns the bounding rectangle of the character previous to the cursors 
		 * location.
		 * 
		 * @return Returns a Point object containing the caret's x and y position.
		 */
		public function get caretPosition():Point 
		{
			var caretPoint:Point;
			var bounds:Rectangle = textField.getCharBoundaries(textField.caretIndex - 1);
			
			if (bounds) // if we have a char bounds
			{
				// set new boundry
				caretPoint = new Point();
				caretPoint.x = bounds.x + bounds.width;
				caretPoint.y = bounds.y + bounds.height;
			}
			
			return caretPoint;
		}
		
		//----------------------------------
		//  numLines
		//----------------------------------
		
		/**
		 * @private
		 */
		private var numLinesChanged:Boolean = false;
		
		/**
		 * Returns the number of text lines defined.
		 * 
		 * @return A Number indicating the amount of lines.
		 */
		public function get numLines():int 
		{
			return textField.numLines;
		}
		
		//----------------------------------
		//  startingLineNumber
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the startingLineNumber property.
		 */
		private var _startingLineNumber:Number = 1;
		
		/**
		 * @private
		 */
		private var startingLineNumberChanged:Boolean = false;
		
		/**
		 * 
		 * 
		 * @default 1
		 */
		public function get startingLineNumber():Number 
		{
			return _startingLineNumber;
		}
		
		/**
		 * @private
		 */
		public function set startingLineNumber(value:Number):void 
		{
			if (_startingLineNumber == value) 
				return;
			
			_startingLineNumber = value;
			startingLineNumberChanged = true;
			
			// its critical we invalidate the display list because the TextArea's 
			// updateDisplayList method will call a private method named adjustScrollBars 
			// on the next frame using callLater since some values aren't available till 
			// then and this prevents an issue where a scrollbar appears when removing 
			// the last line, a scroll bar will be 1 position from the bottom when it 
			// really is at the bottom
			invalidateProperties();
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  text
		//----------------------------------
		
		/**
		 * @private
		 */
		private var textChanged:Boolean = false;
		
		/**
		 * @private
		 */
		override public function set text(value:String):void 
		{
			if (!value) 
				value = "";
			
			if (value == text) 
				return;
			
			super.text = value;
			textChanged = true;
			
			// its critical we invalidate the display list because the TextArea's 
			// updateDisplayList method will call a private method named adjustScrollBars 
			// on the next frame using callLater since some values aren't available till 
			// then and this prevents an issue where a scrollbar appears when removing 
			// the last line, a scroll bar will be 1 position from the bottom when it 
			// really is at the bottom
			invalidateProperties();
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  visibleRows
		//----------------------------------
		
		/**
		 * Returns the number of visible rows.
		 * 
		 * @return A Number indicating the amount of visible rows.
		 */
		public function get visibleRows():int 
		{
			return textField.bottomScrollV - textField.scrollV + 1;
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
			
			// if the font changed and we already created the textfield, we will need to
			// destory it so it can be re-created, possibly in a different swf context
			
			if (hasFontContextChanged() && lineNumTextField != null) 
			{
				removeLineNumberedTextField();
				
				numLinesChanged = true;
			}
			
			if (!lineNumTextField) 
				createLineNumberedTextField(-1);
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			if (startingLineNumberChanged || textChanged || numLinesChanged) 
			{
				drawLineNumbers(_startingLineNumber);
				//highlight();
				
				startingLineNumberChanged = false;
				textChanged = false;
				numLinesChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void 
		{
			var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
			
			super.styleChanged(styleProp);
			
			if (allStyles || styleProp == lineNumStyleNameProp) 
			{
				var newStyleName:String = getStyle(lineNumStyleNameProp);
				
				if (lineNumTextField) 
					lineNumTextField.styleName = newStyleName;
			}
		}
		
		/**
		 * @private
		 * Stretch the border, and resize the TextArea to allow the space for 
		 * the line numbered textField to fit.
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var vm:EdgeMetrics = viewMetrics;
			
			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingTop:Number = getStyle("paddingTop");
			var paddingRight:Number = getStyle("paddingRight");
			var paddingBottom:Number = getStyle("paddingBottom");
			
			var w:Number = unscaledWidth - vm.left - paddingLeft - vm.right - paddingRight - 50;
			var h:Number = unscaledHeight - vm.top - paddingTop - vm.bottom - paddingBottom;
			
			// padding only affects textField
			textField.move(vm.left + paddingLeft + 50, vm.top + paddingTop);
			textField.setActualSize(Math.max(4, w), Math.max(4, h));
			
			// padding does not affect line numbered text field which will 
			// appear at the very left edge of this component minus border if any
			lineNumTextField.move(vm.left, vm.top);
			lineNumTextField.setActualSize(50, h);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Creates the line numbered text field child and adds it as a child of 
		 * this component.
		 * 
		 * @param childIndex The index of where to add the child. If -1, the text 
		 * field is appended to the end of the list.
		 */
		protected function createLineNumberedTextField(childIndex:int):void 
		{
			if (!lineNumTextField) 
			{
				lineNumTextField = IUITextField(createInFontContext(LineNumberedField));
				
				// all text fields start off with 1 line of content
				lineNumTextField.text = "1";
				
				var _styleName:String = getStyle(lineNumStyleNameProp);
				
				if (_styleName) 
					lineNumTextField.styleName = _styleName;
				
				if (childIndex == -1) 
					addChild(DisplayObject(lineNumTextField));
				else 
					addChildAt(DisplayObject(lineNumTextField), childIndex);
			}
		}
		
		/**
		 * Draws line numbers for the current visible rows in the text field 
		 * starting at the start position given.
		 * 
		 * @param start The starting number to draw the line numbers from.
		 */
		protected function drawLineNumbers(start:Number):void 
		{
			trace('redrawing line numbers:', start, '-', start + visibleRows - 1);
			var totalRows:int = start + visibleRows;
			var result:String = "";
			
			for (var i:int = start; i < totalRows; i++) 
			{
				result += i.toString() + "\n";
			}
			
			lineNumTextField.text = result;
		}
		
		/**
		 * Jumps to the given line index and if instructed selects the line of text.
		 * 
		 * @param lineIndex The zero based line index.
		 * @param selectText If <code>true</code> selects the line of text.
		 * 
		 * @return Returns <code>true</code> if caret was set on the desired line 
		 * index.
		 */
		public function goToLineIndex(lineIndex:int, selectText:Boolean=false):Boolean 
		{
			// cancel out if the line doesn't exist!
			if (isNaN(lineIndex) || lineIndex >= textField.numLines || lineIndex < 0) 
				return false;
			
			var lineNum:int = lineIndex + 1; // line index is 0 based
			
			var beginIndex:int = textField.getLineOffset(lineIndex); // getLineOffset seems to be off by 1 sometimes
			var endIndex:int = beginIndex + textField.getLineLength(lineIndex) - 1;
			
			// if its the last line, don't substract by one as that calculation 
			// doesn't seem to be correctly applied on the last line
			if (lineNum == textField.numLines) 
				endIndex = beginIndex + textField.getLineLength(lineIndex);
			
			// if the index provided is more than the furtherest down we can position 
			// our textField vertical scroll then we choose the smallest number
			var startLineNum:int = Math.min(lineNum, textField.maxScrollV);
			
			textField.scrollV = startLineNum;
			startingLineNumber = startLineNum;
			
			// to select text, use the endIndex for the selection call
			// otherwise place the cursor at the beginning of the line
			setSelection(beginIndex, (selectText) ? endIndex : beginIndex);
			
			return true;
		}
		
		/**
		 * Returns <code>true</code> if the specified line index is within the 
		 * scrolling visible area.
		 * 
		 * @param lineIndex The line index to determine if visible.
		 * 
		 * @return Returns <code>true</code> if the line index is visible.
		 */
		public function isLineIndexVisible(lineIndex:int):Boolean 
		{
			var lineNum:int = lineIndex + 1; // line index is 0 based
			
			return (lineNum <= textField.scrollV + visibleRows - 1 && lineNum >= textField.scrollV);
		}
		
		/**
		 * Removes the line numbered text field from this component.
		 */
		protected function removeLineNumberedTextField():void 
		{
			if (lineNumTextField) 
			{
				removeChild(DisplayObject(lineNumTextField));
				lineNumTextField = null;
			}
		}
		
		/**
		 * 
		 */
		protected function highlight():void 
		{
			// if changes happen to quickly, the text property hasn't been updated yet 
			// just fail silently and let the next change trigger highlighting
			if (text == null) 
				return;
			
			var content:String = text;
			
			try 
			{
				content = XML(content).toXMLString();
			} 
			catch (error:Error) 
			{
				trace('xml conversion failed', error.message, error.getStackTrace());
			}
			
			content = content.replace(/</g, "«").replace(/>/g, "»");
			
			var startIndex:Number = textField.getLineOffset(Math.min((textField.scrollV - 1), (textField.numLines - 1)));
			var endIndex:Number = textField.getLineOffset(Math.min((textField.scrollV + visibleRows - 1), (textField.numLines - 1))) 
								+ textField.getLineLength(Math.min((textField.scrollV + visibleRows - 1), (textField.numLines - 1)));
			
			// strip out content in three parts, the upper non-visible part, the 
			// visible part, and lastly the lower non-visible part
			var preContent:String = content.substring(0, startIndex);
			var midContent:String = content.substring(startIndex, endIndex);
			var postContent:String = content.substring(endIndex);
			
			// add code highlighting for matching content only within the visible part
			midContent = midContent.replace(/(«\/?[^»]*»)/gi, '<FONT COLOR="#0000FF">$1</FONT>');
			
			var finalContent:String = preContent + midContent + postContent;
			
			finalContent = finalContent.replace(/«/g, "&lt;").replace(/»/g, "&gt;");
			
			//trace("------------------");
			//trace(preContent);
			//trace(midContent);
			//trace(postContent);
			
			htmlText = finalContent;
			
			// despite text having font tags with color attributes, it seems 
			// in some cases the first line doesn't appeared colored despite having 
			// the correct font tags, this seems to do the trick
			callLater(invalidateProperties);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Line numbers are redrawn if we have a difference in the number of lines 
		 * of text in the TextField when text is being deleted.
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void 
		{
			super.keyDownHandler(event);
			
			if (event.keyCode == Keyboard.BACKSPACE || event.keyCode == Keyboard.DELETE) 
			{
				trace('keyDown', textField.numLines, prevNumLinesOnDeletion);
				// as the user holds down the key to delete text we need to redraw 
				// the number of lines without letting go we still need to update 
				// our tracker for the new number of lines after deletion
				if (textField.numLines != prevNumLinesOnDeletion) 
				{
					trace('line deleted on keyDown');
					numLinesChanged = true;
					invalidateProperties();
					invalidateDisplayList();
					
					prevNumLinesOnDeletion = textField.numLines;
				}
			}
		}
		
		/**
		 * @private
		 * Line numbers are redrawn if we have a difference in the number of lines 
		 * of text in the TextField when text is being deleted.
		 */
		override protected function keyUpHandler(event:KeyboardEvent):void 
		{
			super.keyUpHandler(event);
			
			if (event.keyCode == Keyboard.BACKSPACE || event.keyCode == Keyboard.DELETE) 
			{
				trace('keyUp', textField.numLines, prevNumLinesOnDeletion);
				// sometimes when deleting lines the keyDown event won't fire 
				// but either way we need to reset our tracker when the user 
				// has let go of the delete key
				if (prevNumLinesOnDeletion != textField.numLines) 
				{
					numLinesChanged = true;
					invalidateProperties();
					invalidateDisplayList();
					
					prevNumLinesOnDeletion = textField.numLines;
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * When the component size has changed we need to redraw the line numbers 
		 * in case the componet has grown or shrunk in vertically.
		 */
		private function resizeHandler(event:ResizeEvent):void 
		{
			numLinesChanged = true;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		 * The event handler called for a <code>ScrollEvent.SCROLL</code> event.
		 * If you override this method, make sure to call the base class version.
		 * 
		 * <p>Since the user is scrolling by dragging or clicking on the scroll bar 
		 * or using the up/down arrows to move we can safely just set the 
		 * <code>startingLineNumber</code> property since that is all that 
		 * changes, not the number of lines.</p>
		 * 
		 * @param event The scroll event object.
		 */
		protected function scrollingHandler(event:ScrollEvent):void 
		{
			trace(event.detail, event.delta, event.direction, event.position);
			
			switch (event.detail) 
			{
				case ScrollEventDetail.LINE_DOWN:
				case ScrollEventDetail.LINE_UP:
				case ScrollEventDetail.PAGE_DOWN:
				case ScrollEventDetail.PAGE_UP:
				case ScrollEventDetail.THUMB_POSITION:
				case ScrollEventDetail.THUMB_TRACK:
					startingLineNumber = event.position + 1; // position is 0 based
					break;
				
				// this case is for when the user moves the cursor within the 
				// textField via the up or down arrow keys or enters a new 
				// block of text whether its a new line through the ENTER key 
				// or by pasting in a large amount of text
				case null:
					startingLineNumber = event.position + 1; // position is 0 based
					break;
			}
		}
		
		/**
		 * The event handler called for a <code>TextEvent.TEXT_INPUT</code> event.
		 * If you override this method, make sure to call the base class version.
		 * 
		 * <p>Since the user is entering new lines of text or pasting a large 
		 * amount we need to have the line numbers redrawn.</p>
		 * 
		 *  @param event The text event object.
		 */
		protected function textInputHandler(event:TextEvent):void 
		{
			var text:String = event.text;
			
			// redraw line numbers if new line entered or text containing 1 or 
			// more new lines only, since we don't want to trigger redrawing 
			// if user entered any other character
			if (text == "\n" || text.indexOf("\n") >= 0) 
			{
				numLinesChanged = true;
				invalidateProperties();
			}
		}
	}
}