package com.javierjulio.flexlib.controls.uploadListClasses
{
	import com.javierjulio.flexlib.controls.ProgressClock;
	import com.javierjulio.flexlib.events.UploadInputEvent;
	import com.arc90.utils.FormatUtil;
	import com.arc90.utils.ServiceUtil;
	import com.arc90.utils.StringUtil;
	
	import flash.errors.IllegalOperationError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	import mx.utils.UIDUtil;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when an uploaded file is in the process of being removed from 
	 * its storage location.
	 * 
	 * @eventType com.arc90.flexlib.events.UploadInputEvent.REMOVING_UPLOAD
	 */
	[Event(name="removingUpload", type="com.arc90.flexlib.events.UploadInputEvent")]
	
	/**
	 * Dispatched when a file upload is canceled through the file-browsing dialog.
	 * 
	 * @eventType com.arc90.flexlib.events.UploadInputEvent.UPLOAD_CANCELED
	 */
	[Event(name="uploadCanceled", type="com.arc90.flexlib.events.UploadInputEvent")]
	
	/**
	 * Dispatched when a file upload has completed.
	 * 
	 * @eventType com.arc90.flexlib.events.UploadInputEvent.UPLOAD_COMPLETED
	 */
	[Event(name="uploadCompleted", type="com.arc90.flexlib.events.UploadInputEvent")]
	
	/**
	 * Dispatched when a file has failed to upload.
	 * 
	 * @eventType com.arc90.flexlib.events.UploadInputEvent.UPLOAD_FAILED
	 */
	[Event(name="uploadFailed", type="com.arc90.flexlib.events.UploadInputEvent")]
	
	/**
	 * Dispatched when a file is removed from its storage location.
	 * 
	 * @eventType com.arc90.flexlib.events.UploadInputEvent.UPLOAD_REMOVED
	 */
	[Event(name="uploadRemoved", type="com.arc90.flexlib.events.UploadInputEvent")]
	
	/**
	 * Dispatched when a file is selected.
	 * 
	 * @eventType com.arc90.flexlib.events.UploadInputEvent.UPLOAD_SELECTED
	 */
	[Event(name="uploadSelected", type="com.arc90.flexlib.events.UploadInputEvent")]
	
	public class UploadInput extends UIComponent
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Storage for the LOGGER instance.
		 */
		private static const LOGGER:ILogger = Log.getLogger("com.arc90.flexlib.controls.uploadListClasses.UploadInput");
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		protected var checkBox:CheckBox;
		
		protected var fileRef:FileReference;
		
		protected var fileRemovalService:HTTPService;
		
		protected var label:Label;
		
		protected var progressClock:ProgressClock;
		
		protected var maxFailures:Number = 3;
		
		protected var numFailed:Number = 0;
		
		protected var uniqueFileName:String = "";
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function UploadInput()
		{
			super();
			
			fileRemovalService = new HTTPService();
			fileRemovalService.method = "POST"; // we will be sending custom headers
			fileRemovalService.contentType = "application/xml";
			fileRemovalService.resultFormat = "e4x";
			fileRemovalService.showBusyCursor = false;
			fileRemovalService.requestTimeout = 0;
			fileRemovalService.addEventListener(ResultEvent.RESULT, deleteFile_resultHandler, false, 0, true);
			fileRemovalService.addEventListener(FaultEvent.FAULT, deleteFile_faultHandler, false, 0, true);
			
			fileRef = new FileReference();
			fileRef.addEventListener(Event.CANCEL, fileRef_cancelHandler, false, 0, true);
			fileRef.addEventListener(Event.COMPLETE, fileRef_completeHandler, false, 0, true);
			fileRef.addEventListener(Event.SELECT, fileRef_selectHandler, false, 0, true);
			fileRef.addEventListener(HTTPStatusEvent.HTTP_STATUS, fileRef_httpStatusHandler, false, 0, true);
			fileRef.addEventListener(IOErrorEvent.IO_ERROR, fileRef_ioErrorHandler, false, 0, true);
			fileRef.addEventListener(ProgressEvent.PROGRESS, fileRef_progressHandler, false, 0, true);
			fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, fileRef_uploadCompleteDataHandler, false, 0, true);
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
		 * removing uploaded file.
		 */
		public var authtoken:String = "";
		
		//----------------------------------
		//  location
		//----------------------------------
		
		/**
		 * The url where the uploaded file is located.
		 */
		public var location:String = "";
		
		//----------------------------------
		//  fileName
		//----------------------------------
		
		/**
		 * The name of the selected file. 
		 * A value is set only after a SELECT event is dispatched.
		 */
		public var fileName:String = "";
		
		//----------------------------------
		//  fileSize
		//----------------------------------
		
		/**
		 * The size of the selected file.
		 * A value is set only after a SELECT event is dispatched.
		 */
		public var fileSize:Number = 0;
		
		//----------------------------------
		//  processing
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the processing property.
		 */
		private var _processing:Boolean = false;
		
		/**
		 * A readonly flag that indicates if this control is processing an upload.
		 */
		public function get processing():Boolean 
		{
			return _processing;
		}
		
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
			
			if (!checkBox) 
			{
				checkBox = new CheckBox();
				checkBox.selected = true;
				checkBox.addEventListener(Event.CHANGE, checkBox_changeHandler, false, 0, true);
				addChild(checkBox);
			}
			
			if (!label) 
			{
				label = new Label();
				addChild(label);
			}
			
			if (!progressClock) 
			{
				progressClock = new ProgressClock();
				progressClock.includeInLayout = true;
				progressClock.visible = true;
				addChild(progressClock);
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void 
		{
			super.measure();
			
			
			measuredMinWidth = DEFAULT_MEASURED_MIN_WIDTH;
			measuredMinHeight = DEFAULT_MEASURED_MIN_HEIGHT;
			
			measuredWidth = checkBox.getExplicitOrMeasuredHeight() 
							+ label.getExplicitOrMeasuredHeight() 
							+ progressClock.getExplicitOrMeasuredHeight();
			measuredHeight = label.getExplicitOrMeasuredHeight();
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (checkBox) 
			{
				checkBox.setActualSize(checkBox.measuredWidth, checkBox.measuredHeight);
				checkBox.move(0, (unscaledHeight - checkBox.measuredHeight) / 2);
			}
			
			if (label && checkBox && progressClock) 
			{
				label.setActualSize(unscaledWidth - checkBox.measuredWidth - progressClock.measuredWidth - 10, unscaledHeight);
				label.move(checkBox.measuredWidth + 5, (unscaledHeight - label.measuredHeight) / 2);
			}
			
			if (progressClock) 
			{
				var labelWidth:Number = 0;
				
				// if the label does not need the full width available and the text is not truncated
				// we use measuredWidth since its a smaller number, this way the ProgressClock appears 
				// right after the end of the label. If the label is to long and the text is truncated 
				// the label will appear at the far right edge. Label will be truncated automatically 
				// but enough space will be given for the ProgressClock.
				if (label.measuredWidth < label.width) 
					labelWidth = label.measuredWidth;
				else 
					labelWidth = label.width;
				
				progressClock.setActualSize(progressClock.measuredWidth, progressClock.measuredHeight);
				progressClock.move(label.x + labelWidth + 5, (unscaledHeight - progressClock.measuredHeight) / 2);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Opens a file browse window.
		 */
		public function browse(typeFilter:Array=null):Boolean 
		{
			return fileRef.browse(typeFilter);
		}
		
		/**
		 * Cancels the file upload and resets the necessary controls.
		 */
		public function cancel():void 
		{
			fileRef.cancel();
			_processing = false;
			checkBox.enabled = true;
			indicateProgress(false);
		}
		
		/**
		 * A helper to either make the ProgressClock visible or hidden.
		 */
		protected function indicateProgress(progress:Boolean):void 
		{
			progressClock.includeInLayout = progress;
			progressClock.visible = progress;
		}
		
		/**
		 * Shows an error message using an Alert based on a given status code. To 
		 * provide a custom error message not specific to a status code, just pass 
		 * NaN as the statusCode value and then provide both the message and title.
		 * 
		 * @param statusCode The status code.
		 * @param message The message. Only used if statusCode is NaN.
		 * @param title The title. Only used if statusCode is NaN.
		 */
		protected function showErrorMessage(statusCode:Number, message:String="", title:String=""):void 
		{
			var title:String = "";
			
			switch (statusCode) 
			{
				case NaN:
					break;
				
				case 401:
					message = "Sorry, you are not authorized to upload a file.";
					title = "File Upload Denied";
					break;
				
				case 403:
					message = "Sorry, you do not have the necessary permissions to upload a file.";
					title = "File Upload Denied";
					break;
				
				case 400:
				case 500:
				default:
					message = "Sorry, the service is unavailable for uploading files (" + statusCode + ").";
					title = "Unknown Error";
					break;
			}
			
			Alert.show(message, title);
		}
		
		/**
		 * Uploads the selected file.
		 */
		public function upload():void 
		{
			_processing = true;
			
			try 
			{
				var fileName:String = fileRef.name;
				
				// use a uid for a unique name and strip out the file extension from the original file name
				uniqueFileName = UIDUtil.createUID() + fileName.substring(fileName.lastIndexOf("."));
				
				// our REST standards only state that crippled client support can be enabled 
				// via URL parameters but not through form parameters, FileReference uploads 
				// (POST request) sends URLVariables defined in the data property as form 
				// params, the auth-token and object-key params haven't changed and are still 
				// handled as form params by ixLibrary
				var request:URLRequest = new URLRequest(url + "?x-crippled-client=true&x-crippled-client-envelope=true");
				request.method = URLRequestMethod.POST;
				request.data = new URLVariables();
				request.data["auth-token"] = "Basic " + authtoken;
				request.data["object-key"] = uniqueFileName;
				
				// don't allow upload prevention, later the user will have the ability to remove upload
				checkBox.enabled = false;
				
				fileRef.upload(request, uploadDataFieldName);
				
				indicateProgress(true);
			} 
			catch (ioerror:IllegalOperationError) 
			{
				LOGGER.error("An illegal operation error occurred when attempting to call the upload method on FileReference object. {0}", ioerror.message);
			} 
			catch (error:Error) 
			{
				LOGGER.error("An unknown error occurred when attempting to call the upload method on FileReference object. {0}", error.message);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * When the checkbox has been deselected we enable the processing indicator, 
		 * dispatch a REMOVING_UPLOAD event, disable the checkbox since we will 
		 * start the process of removing the upload, and make our HTTP service call 
		 * to delete it. 
		 */
		protected function checkBox_changeHandler(event:Event):void 
		{
			// we only handle the checkbox if it was deselected
			if (checkBox.selected) return;
			
			_processing = true;
			
			// indicate that this upload is being removed
			dispatchEvent(new UploadInputEvent(UploadInputEvent.REMOVING_UPLOAD));
			
			// we can safely continue to remove the file
			checkBox.enabled = false;
			
			fileRemovalService.headers = ServiceUtil.getHeaders(authtoken, "DELETE");
			fileRemovalService.headers["X-Archive"] = false; // permanently remove file
			fileRemovalService.url = StringUtil.stripTrailingSlash(url) + "/" + uniqueFileName;
			fileRemovalService.send();
			
			indicateProgress(true);
		}
		
		/**
		 * If deleting a file failed just dispatch an UPLOAD_REMOVED event 
		 * and log the error that occurred.
		 */
		protected function deleteFile_faultHandler(event:FaultEvent):void 
		{
			LOGGER.warn("Deleting the uploaded file resulted in a fault. {0} {1} {2}", event.message, event.fault.message, event.fault.faultDetail);
			
			cancel();
			
			dispatchEvent(new UploadInputEvent(UploadInputEvent.UPLOAD_REMOVED));
		}
		
		/**
		 * On successfully deleting a file dispatch an UPLOAD_REMOVED event.
		 */
		protected function deleteFile_resultHandler(event:ResultEvent):void 
		{
			cancel();
			
			LOGGER.info("The file {0} has been removed successfully.", fileRef.name);
			
			dispatchEvent(new UploadInputEvent(UploadInputEvent.UPLOAD_REMOVED));
		}
		
		/**
		 * On cancel dispatch an UPLOAD_CANCELED event.
		 */
		protected function fileRef_cancelHandler(event:Event):void 
		{
			cancel();
			dispatchEvent(new UploadInputEvent(UploadInputEvent.UPLOAD_CANCELED));
		}
		
		/**
		 * On complete we don't handle the response since that comes through the 
		 * DataEvent.UPLOAD_COMPLETE_DATA event that is dispatced by FileReference.
		 */
		protected function fileRef_completeHandler(event:Event):void 
		{
			LOGGER.info("The request to upload file {0} has completed.", fileRef.name);
		}
		
		/**
		 * We need to handle 4xx and 5xx status codes sent back from the server. For 
		 * any of these status codes we have custom messages that declare the issue. 
		 * For example a 403 demonstrates that the user does not have permissions to 
		 * upload a file. A 401 and a 403 are handled with custom messages, a 400, 
		 * 500 and any other status code is handled with a service unavailable 
		 * message.
		 */
		protected function fileRef_httpStatusHandler(event:HTTPStatusEvent):void 
		{
			LOGGER.warn("Error uploading file. Status code of {0}.", event.status);
			
			showErrorMessage(event.status);
			
			dispatchEvent(new UploadInputEvent(UploadInputEvent.UPLOAD_FAILED));
		}
		
		/**
		 * If an error occurs we want to retry before failing. If we have reached 
		 * the maximum number of retries then we bail out by alerting the user 
		 * the upload failed and dispatching an UPLOAD_FAILED event.
		 */
		protected function fileRef_ioErrorHandler(event:IOErrorEvent):void 
		{
			// increment our failure counter
			numFailed++;
			
			// if we have reached the max number of failures, cancel out
			if (numFailed == maxFailures) 
			{
				LOGGER.error("Failed to upload file despite retrying {0} times.", numFailed);
				
				cancel();
				
				Alert.show("Sorry, the file named " + fileRef.name + " failed to upload. Please try attaching it again.", "File Upload Failure");
				
				dispatchEvent(new UploadInputEvent(UploadInputEvent.UPLOAD_FAILED));
			} 
			else 
				upload(); // try uploading until max number of failures is reached
		}
		
		/**
		 * Log the progress made for uploading a file.
		 */
		protected function fileRef_progressHandler(event:ProgressEvent):void 
		{
			LOGGER.info("Progress -> Loaded: {0} Total: {1}", event.bytesLoaded, event.bytesTotal);
		}
		
		/**
		 * When a file has been selected we need to set the file name, file size, 
		 * dispatch an UPLOAD_SELECTED event and begin the upload.
		 */
		protected function fileRef_selectHandler(event:Event):void 
		{
			label.text = fileRef.name;
			fileName = fileRef.name;
			fileSize = fileRef.size;
			
			LOGGER.info("The file '{0}' ({1}) has been selected to upload.", fileName, FormatUtil.format(fileSize, FormatUtil.FILE_SIZE));
			
			dispatchEvent(new UploadInputEvent(UploadInputEvent.UPLOAD_SELECTED));
			
			upload();
		}
		
		/**
		 * When a file has been uploaded successfully we need to inspect the 
		 * response from the service to verify that the upload completed 
		 * successfully. If the success the location is set and an 
		 * UPLOAD_COMPLETED event is dispatched. If its determined that the 
		 * response failed or was unable to parse the response a UPLOAD_FAILED 
		 * event is dispatched.
		 */
		protected function fileRef_uploadCompleteDataHandler(event:DataEvent):void 
		{
			cancel();
			
			try 
			{
				var data:String = event.data;
				
				// strip out the CDATA before XML parsing as we don't need it 
				// and for some reason causes the Flash XML parser to fail:
				// Error #1091: XML parser failure: Unterminated CDATA section.
				// After further investigation it seems that the response has a 
				// maximum length, when debugging event.data appears to be cut 
				// off at a consistent point, in this case since the Body is 
				// completely unnecessary as I just need the headers to determine 
				// whether the request was successful or not
				var endIndex:Number = data.indexOf("</Headers>");
				
				// substring call gives us the full response up to 
				// and BEFORE the </Headers> tag so we include it
				var response:String = data.substring(0, endIndex) + "</Headers></HttpResponse>";
				
				var result:XML = XML(response);
				
				var statusCode:Number = NaN;
				var statusCodes:XMLList = result.Headers.Header.(@name.toLowerCase() == "x-true-status-code").@value;
				if (statusCodes.length() >= 1) 
					statusCode = Number(statusCodes[0]);
				
				if (statusCode != 201) 
				{
					throw new Error(statusCode, 1);
				}
				
				LOGGER.info("The file {0} has been uploaded successfully with a {1} status code.", fileRef.name, statusCode);
				
				// the url might or not end with a /, either way remove, and add it back in to be safe
				location = StringUtil.stripTrailingSlash(url) + "/" + uniqueFileName;
				
				dispatchEvent(new UploadInputEvent(UploadInputEvent.UPLOAD_COMPLETED));
			} 
			catch (error:Error) 
			{
				LOGGER.info("Unable to upload the file {0}: {1} {2}", fileRef.name, error.message, error.getStackTrace());
				
				if (error.errorID == 1) 
					showErrorMessage(Number(error.message));
				else 
					showErrorMessage(NaN, "Sorry, the response from the service was not understood to upload a file.");
				
				dispatchEvent(new UploadInputEvent(UploadInputEvent.UPLOAD_FAILED));
			}
		}
	}
}