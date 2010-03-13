package com.javierjulio.flexlib.skins
{
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	import mx.core.EdgeMetrics;
	import mx.core.FlexVersion;
	import mx.skins.halo.HaloBorder;
	import mx.utils.GraphicsUtil;
	
	/**
	 * Defines the appearance of the gradient border for the GradientCanvas, 
	 * GradientHBox, and GradientVBox containers.
	 */
	public class GradientBorder extends HaloBorder
	{
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function GradientBorder()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			if (isNaN(unscaledWidth) || isNaN(unscaledHeight)) 
				return;
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if ((getStyle("fillColors") !== null && getStyle("fillColors") !== "") || getStyle("mouseShield") || getStyle("mouseShieldChildren"))
			{
				var borderSides:String = getStyle("borderSides").toLowerCase();
				var cornerRadii:Object;
				var cornerRadius:Number = getStyle("cornerRadius");
				var fillAlphas:Array = getStyle("fillAlphas");
				var fillColors:Array = getStyle("fillColors");
				var fillRatios:Array = getStyle("fillRatios");
				var focalPointRatio:Number = getStyle("focalPointRatio");
				var gradientAngle:Number = getStyle("gradientAngle");
				var gradientType:String = getStyle("gradientType");
				var roundedBottomCorners:Boolean = getStyle("roundedBottomCorners");
				var matrix:Matrix = new Matrix();
				
				// create manual matrix gradient box, we don't use the built in vertical/horizontal gradient methods 
				// since we can't control the gradient angle, here we can and we've made it a style on top of that!
				matrix.createGradientBox(unscaledWidth, unscaledHeight, gradientAngle * Math.PI / 180);
				
				// make sure we have a numeric value, playing it safe
				if (isNaN(cornerRadius)) 
					cornerRadius = 0;
				
				// set up each corner's radius, default is all corners use the same radius
				if (roundedBottomCorners) 
					cornerRadii = {tl: cornerRadius, tr: cornerRadius, bl: cornerRadius, br: cornerRadius};
				else 
					cornerRadii = {tl: cornerRadius, tr: cornerRadius, bl: 0, br: 0}; // otherwise reset bottom left/right corners to 0
				
				// Special case for the none borderSkin to inset the chrome content
				// by the borderThickness when borderStyle is "solid", "inset" or "outset".
				var em:EdgeMetrics = EdgeMetrics.EMPTY;
				var bt:Number = getStyle("borderThickness");
				if (getStyle("borderStyle") != "none" && bt) 
				{
					em = new EdgeMetrics(bt, bt, bt, bt);
				}
				
				if (borderSides != "left top right bottom")
				{
					if (borderSides.indexOf("left") == -1) 
					{
						em.left = 0;
					}
					if (borderSides.indexOf("top") == -1) 
					{
						em.top = 0;
					}
					if (borderSides.indexOf("right") == -1) 
					{
						em.right = 0;
					}
					if (borderSides.indexOf("bottom") == -1) 
					{
						em.bottom = 0;
					}
				}
				
				var bm:EdgeMetrics = FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0 ? borderMetrics : em;
				var x:Number = bm.left;
				var y:Number = bm.top;
				var w:Number = unscaledWidth - bm.left - bm.right;
				var h:Number = unscaledHeight - bm.top - bm.bottom;
				
				graphics.beginGradientFill(gradientType, fillColors, fillAlphas, fillRatios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, focalPointRatio);
				GraphicsUtil.drawRoundRectComplex(graphics, x, y, w, h, cornerRadii.tl, cornerRadii.tr, cornerRadii.bl, cornerRadii.br);
				graphics.endFill();
			}
		}
	}
}