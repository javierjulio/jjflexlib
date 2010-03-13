package com.javierjulio.flexlib.controls
{
	import com.javierjulio.flexlib.controls.uploadListClasses.UploadInput;
	import com.javierjulio.flexlib.controls.uploadListClasses.UploadInputData;
	import com.javierjulio.flexlib.events.UploadInputEvent;
	import com.javierjulio.flexlib.events.UploadListEvent;
	import com.arc90.utils.ServiceUtil;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.containers.VBox;
	import mx.controls.LinkButton;
	import mx.core.ClassFactory;
	import mx.core.FlexVersion;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when a change has been made. This includes either removing an 
	 * attached file or selecting a new one to upload.
	 * 
	 * @eventType com.javierjulio.flexlib.events.UploadListEvent.CHANGE
	 */
	[Event(name="change", type="com.javierjulio.flexlib.events.UploadListEvent")]
	
	/**
	 * Dispatched when all file uploads have completed.
	 * 
	 * @eventType com.javierjulio.flexlib.events.UploadListEvent.UPLOADS_COMPLETED
	 */
	[Event(name="uploadsCompleted", type="com.javierjulio.flexlib.events.UploadListEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 *  Name of CSS style declaration that specifies the styles to use for the link
	 *  button navigation items.
	 * 
	 *  @default ""
	 */
	[Style(name="linkButtonStyleName", type="String", inherit="no")]
	
	/**
	 * 
	 * 
	 * @mxml
	 * <p>The <code>&lt;controls:LinkBar&gt;</code> tag inherits all of the tag
	 * attributes of its superclass, and adds the following tag attributes:</p>
	 * 
	 * <pre>
	 * &lt;controls:UploadList
	 * 	 <b>Properties</b>
	 *   url=""
	 * 
	 * 	 <b>Styles</b>
	 *   linkButtonStyleName=""
	 *   &gt;
	 * &lt;/controls:UploadList&gt;
	 */
	public class UploadList extends VBox
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Storage for the LinkButton instance to bring up the FileReference browse 
		 * window so user can select the desired file attachment.
		 */
		protected var attachFile:LinkButton;
		
		/**
		 * @private
		 * A helper for tracking the number of completed file uploads.
		 */
		protected var numCompleted:Number = 0;
		
		/**
		 * @private
		 * A helper for tracking the number of file inputs.
		 */
		protected var numFileInputs:Number = 0;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function UploadList()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  authtoken
		//----------------------------------
		
		/**
		 * The authtoken if authentication is required for uploading and/or 
		 * removing uploaded file. This takes priority over username and password. 
		 * This is a convenience if you only have an encoded auth token and not 
		 * decoded username and password.
		 */
		public var authtoken:String = "";
		
		//----------------------------------
		//  itemRenderer
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the itemRenderer property.
		 */
		protected var _itemRenderer:IFactory = new ClassFactory(UploadInput);
		
		/**
		 * @private
		 */
		protected var itemRendererChanged:Boolean = false;
		
		/**
		 * The IFactory that creates an instance to use as the UploadInput.
		 * The default value is an IFactory for UploadInput.
		 * 
		 * <p>If you write a custom upload input class, it should extend 
		 * the UploadInput and modify its functionality.</p>
		 */
		public function get itemRenderer():IFactory 
		{
			return _itemRenderer;
		}
		
		/**
		 * @private
		 */
		public function set itemRenderer(value:IFactory):void 
		{
			_itemRenderer = value;
			itemRendererChanged = true;
			
			invalidateProperties();
		}
		
		//----------------------------------
		//  maxUploads
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the maxUploads property.
		 */
		private var _maxUploads:Number = -1;
		
		/**
		 * The maximum allowed uploads. The default is -1 which means there 
		 * is no maximum and an infinite amount of uploads can be made.
		 * 
		 * @default -1
		 */
		public function get maxUploads():Number 
		{
			return _maxUploads;
		}
		
		/**
		 * @private
		 */
		public function set maxUploads(value:Number):void 
		{
			if (value == _maxUploads) 
				return;
			
			if (isNaN(value) || value < -1) 
				value = -1;
			
			_maxUploads = value;
		}
		
		//----------------------------------
		//  password
		//----------------------------------
		
		/**
		 * The password if authentication is required for uploading and/or 
		 * removing uploaded file.
		 */
		public var password:String = "";
		
		//----------------------------------
		//  processing
		//----------------------------------
		
		/**
		 * A readonly flag that indicates whether there are any current 
		 * processing uploads. Use this property to verify all uploads 
		 * are completed before accessing the upload data collection.
		 */
		public function get processing():Boolean 
		{
			var _processing:Boolean = false;
			var length:Number = numChildren;
			
			for (var i:uint = 0; i < length; i++) 
			{
				var input:UploadInput = getChildAt(i) as UploadInput;
				
				if (input && input.processing) 
				{
					_processing = true;
					break;
				}
			}
			
			return _processing;
		}
		
		/**
		 * @private
		 */
		public function set processing(value:Boolean):void 
		{
			// do nothing, prevent runtime binding warnings
		}
		
		//----------------------------------
		//  prompt
		//----------------------------------
		
		/**
		 * The initial prompt label on the attach file LinkButton.
		 * 
		 * @default "Attach a file..."
		 */
		public var prompt:String = "Attach a file...";
		
		//----------------------------------
		//  promptAnother
		//----------------------------------
		
		/**
		 * After the first file is attached, any subsequent file attachments use 
		 * this prompt on the attach file LinkButton.
		 * 
		 * @default "Attach another file..."
		 */
		public var promptAnother:String = "Attach another file...";
		
		//----------------------------------
		//  uploadDataFieldName
		//----------------------------------
		
		/**
		 * The field name where the upload data is in when making an upload 
		 * request using the FileReference object.
		 * 
		 * @default object-data-file
		 */
		public var uploadDataFieldName:String = "object-data-file";
		
		//----------------------------------
		//  url
		//----------------------------------
		
		/**
		 * The url where the file is uploaded.
		 */
		public var url:String = "";
		
		//----------------------------------
		//  username
		//----------------------------------
		
		/**
		 * The username if authentication is required for uploading and/or 
		 * removing uploaded file.
		 */
		public var username:String = "";
		
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
			
			if (!attachFile) 
			{
				attachFile = new LinkButton();
				attachFile.label = prompt;
				attachFile.addEventListener(MouseEvent.CLICK, attachFile_clickHandler, false, 0, true);
				
				if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0) 
					attachFile.styleName = this;
				else 
				{
					var linkButtonStyleName:String = getStyle("linkButtonStyleName");
					
					if (linkButtonStyleName)
						attachFile.styleName = linkButtonStyleName;
				}
				
				addChild(attachFile);
			}
		}
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void 
		{
			super.styleChanged(styleProp);
			
			var navItemStyleName:Object;
			
			if (styleProp == "styleName" && FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0) 
				navItemStyleName = this;
			else if (styleProp == "linkButtonStyleName" && FlexVersion.compatibilityVersion >= FlexVersion.VERSION_3_0) 
				navItemStyleName = getStyle("linkButtonStyleName");
			
			if (navItemStyleName)
				attachFile.styleName = navItemStyleName;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (attachFile) 
			{
				// just set the size, positioning will be handled by the VBox layout
				attachFile.setActualSize(attachFile.measuredWidth, attachFile.measuredHeight);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Checks if all uploads have been completed and if they have a 
		 * UploadListEvent.UPLOADS_COMPLETED event is dispatched.
		 */
		protected function checkAllUploads():void 
		{
			if (numCompleted == numFileInputs) 
				dispatchEvent(new UploadListEvent(UploadListEvent.UPLOADS_COMPLETED));
		}
		
		/**
		 * Returns an Array of UploadData objects consisting of the content for each 
		 * file upload that was completed. This array does <b>not</b> include 
		 * canceled or removed uploads.
		 * 
		 * @return Array of UploadData objects consisting of the content for each 
		 * file upload that was completed.
		 */
		public function getUploadData():Array 
		{
			var length:Number = numChildren;
			var result:Array = [];
			
			for (var i:uint = 0; i < length; i++) 
			{
				var input:UploadInput = getChildAt(i) as UploadInput;
				
				if (input) 
					result.push(new UploadInputData(input.location, input.fileName, input.fileSize));
			}
			
			return result;
		}
		
		/**
		 * Removes all event handlers from an UploadInput before removing it 
		 * from the display list.
		 */
		protected function removeUploadInput(input:DisplayObject):void 
		{
			// we need to do some clean up first
			input.removeEventListener(UploadInputEvent.UPLOAD_CANCELED, uploadInput_canceledHandler);
			//uploadInput.removeEventListener(Event.CHANGE, uploadInput_changeHandler);
			input.removeEventListener(UploadInputEvent.UPLOAD_COMPLETED, uploadInput_completedHandler);
			input.removeEventListener(UploadInputEvent.UPLOAD_FAILED, uploadInput_failedHandler);
			input.removeEventListener(UploadInputEvent.UPLOAD_REMOVED, uploadInput_removedHandler);
			input.removeEventListener(UploadInputEvent.UPLOAD_SELECTED, uploadInput_selectedHandler);
			input.removeEventListener(UploadInputEvent.REMOVING_UPLOAD, uploadInput_removingHandler);
			
			// we can now safely remove the input
			removeChild(input);
		}
		
		/**
		 * Removes all UploadInput instances. After you have collected and handled 
		 * all upload data this method resets the UploadList to its default state.
		 */
		public function reset():void 
		{
			var length:Number = numChildren - 1;
			
			numFileInputs = 0;
			attachFile.label = prompt;
			
			for (var i:int = length; i >= 0; i--) 
			{
				var input:UploadInput = getChildAt(i) as UploadInput;
				
				if (input) 
					removeUploadInput(input);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Creates a new UploadInput instance, adds it to the display list but is 
		 * not visible or included in the layout. The FileReference browse window 
		 * is opened and once a file is selected, the UploadInput becomes visible.
		 */
		protected function attachFile_clickHandler(event:MouseEvent):void 
		{
			var uploadInput:UploadInput = itemRenderer.newInstance() as UploadInput;
			uploadInput.url = url;
			uploadInput.percentWidth = 100;
			
			// if we are given an authtoken use that, otherwise default to using 
			// username and password to generate authtoken credentials
			uploadInput.authtoken = (authtoken) ? authtoken : ServiceUtil.createAuthtoken(username + ":" + password);
			
			// we need to handle when the upload is selected, completed and/or removed
			uploadInput.addEventListener(UploadInputEvent.UPLOAD_CANCELED, uploadInput_canceledHandler);
			//uploadInput.addEventListener(UploadInputEvent.CHANGE, uploadInput_changeHandler);
			uploadInput.addEventListener(UploadInputEvent.UPLOAD_COMPLETED, uploadInput_completedHandler);
			uploadInput.addEventListener(UploadInputEvent.UPLOAD_REMOVED, uploadInput_removedHandler);
			uploadInput.addEventListener(UploadInputEvent.UPLOAD_SELECTED, uploadInput_selectedHandler);
			uploadInput.addEventListener(UploadInputEvent.REMOVING_UPLOAD, uploadInput_removingHandler);
			uploadInput.addEventListener(UploadInputEvent.UPLOAD_FAILED, uploadInput_failedHandler);
			
			// initially not visible, visible once a file is selected
			uploadInput.includeInLayout = false;
			uploadInput.visible = false;
			
			// add the new uploadInput before the last child (the attachFile button)
			addChildAt(uploadInput, getChildIndex(attachFile));
			
			uploadInput.browse();
		}
		
		/**
		 * On a canceled a upload dispatch a CHANGE event and remove the upload input.
		 */
		protected function uploadInput_canceledHandler(event:UploadInputEvent):void 
		{
			dispatchEvent(new UploadListEvent(UploadListEvent.CHANGE));
			uploadInput_removedHandler(event);
		}
		
		/**
		 * Increments an internal count for all completed uploads and then runs a 
		 * check if all uploads have completed (the number completed is equal to 
		 * the number of upload inputs).
		 */
		protected function uploadInput_completedHandler(event:UploadInputEvent):void 
		{
			numCompleted++;
			checkAllUploads();
		}
		
		/**
		 * On a failed upload we remove the UploadInput.
		 */
		protected function uploadInput_failedHandler(event:UploadInputEvent):void 
		{
			uploadInput_removedHandler(event);
		}
		
		/**
		 * Handles when an upload has been removed so we can safely remove the 
		 * selected UploadInput instance from the display list.
		 */
		protected function uploadInput_removedHandler(event:UploadInputEvent):void 
		{
			var uploadInput:DisplayObject = event.target as DisplayObject;
			
			removeUploadInput(uploadInput);
			
			// decrement the number of file inputs
			numFileInputs--;
			
			// and reset our prompt if needed
			if (numFileInputs == 0) 
				attachFile.label = prompt;
			
			// make sure to redisplay the attach file button
			if (numFileInputs < _maxUploads) 
				attachFile.includeInLayout = attachFile.visible = true;
			
			checkAllUploads();
		}
		
		/**
		 * When an upload is in the process of being removed dispatch a CHANGE 
		 * event.
		 */
		protected function uploadInput_removingHandler(event:UploadInputEvent):void 
		{
			dispatchEvent(new UploadListEvent(UploadListEvent.CHANGE));
		}
		
		/**
		 * When an upload has been selected dispatch a CHANGE event, display 
		 * the upload input and increment the number of file inputs. We reset 
		 * the prompt to the promptAnother if we have more than 1 input.
		 */
		protected function uploadInput_selectedHandler(event:UploadInputEvent):void 
		{
			var uploadInput:UIComponent = event.target as UIComponent;
			
			dispatchEvent(new UploadListEvent(UploadListEvent.CHANGE));
			
			// a file is selected so display our control
			uploadInput.includeInLayout = true;
			uploadInput.visible = true;
			
			// increment the number of file inputs
			numFileInputs++;
			
			// and reset our prompt if needed
			if (numFileInputs >= 1) 
				attachFile.label = promptAnother;
			
			// have we reached the max amount of uploads? 
			// if so hide the attach another button
			if (_maxUploads == numFileInputs) 
				attachFile.includeInLayout = attachFile.visible = false;
		}
	}
}