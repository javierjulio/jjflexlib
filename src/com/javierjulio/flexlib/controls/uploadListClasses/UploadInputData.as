package com.javierjulio.flexlib.controls.uploadListClasses
{
	public class UploadInputData
	{
		public function UploadInputData(location:String, name:String, size:Number)
		{
			super();
			
			this.location = location;
			this.name = name;
			this.size = size;
		}
		
		public var location:String = "";
		public var name:String = "";
		public var size:Number = 0;
	}
}