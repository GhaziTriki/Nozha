package com.sebastiaanholtrop.reflection
{

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.SpreadMethod;
    import flash.display.Sprite;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;

    public class Reflect extends EventDispatcher
    {

        public static const LEFT : String = "left";
        public static const BOTTOM : String = "bottom";
        public static const RIGHT : String = "right";
        public static const TOP : String = "top";

        private var _sourceSprite : Sprite;
        private var _reflectionBmd : BitmapData;
        private var _gradientBmd : BitmapData;
        private var _updateTimer : Timer;

        private var _alpha : Number;
        private var _ratio : Number;
        private var _distance : Number;
        private var _side : String;
        private var _add : Boolean;
        private var _updateTime : Number;

        public function Reflect(sourceSprite : Sprite, alpha : Number = 0.5, ratio : Number = 50, add : Boolean = true, side : String = Reflect.BOTTOM, distance : Number = 0, updateTime : Number = 0)
        {
            trace("Reflect constructor");
            this._sourceSprite = sourceSprite;

            this._alpha = alpha;
            this._ratio = ratio;
            this._distance = distance;
            this._side = side;
            this._add = add;
            this._updateTime = updateTime;

            this.redraw();


        }


        private function spriteToFlippedBitmapData() : void
        {

            this._reflectionBmd = new BitmapData(this._sourceSprite.width, this._sourceSprite.height, true, 0xFFFFFF);

            var flipMatrix : Matrix = new Matrix();

            switch (this.side)
            {
                case Reflect.LEFT:
                case Reflect.RIGHT:
                    flipMatrix.scale(-1, 1);
                    flipMatrix.translate(this._sourceSprite.width, 0);
                    break;
                case Reflect.BOTTOM:
                case Reflect.TOP:
                    flipMatrix.scale(1, -1);
                    flipMatrix.translate(0, this._sourceSprite.height);
                    break;
            }
            this._reflectionBmd.draw(this._sourceSprite, flipMatrix);
        }

        private function createGradientBitmapData() : void
        {

            var gradientSprite : Sprite = new Sprite();

            var colors : Array = [0xFFFFFF, 0xFFFFFF];
            var alphas : Array = [this.alpha, 0];
            var ratios : Array = [0, this.ratio];
            var rotation : Number;

            switch (side)
            {
                case Reflect.LEFT:
                    rotation = 1;
                    break;
                case Reflect.RIGHT:
                    rotation = 0;
                    break;
                case Reflect.BOTTOM:
                    rotation = 0.5;
                    break
                case Reflect.TOP:
                    rotation = 1.5;
                    break;
            }

            var matrix : Matrix = new Matrix();
            matrix.createGradientBox(this._sourceSprite.width, this._sourceSprite.height, rotation * Math.PI, 0, 0);

            gradientSprite.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD);
            gradientSprite.graphics.drawRect(0, 0, this._sourceSprite.width, this._sourceSprite.height);

            this._gradientBmd = new BitmapData(this._sourceSprite.width, this._sourceSprite.height, true, 0xFFFFFF);
            this._gradientBmd.draw(gradientSprite);
        }


        private function addToSource() : void
        {
            trace("addToSource");
            if (this._sourceSprite.getChildByName("reflectionBitmap") != null)
            {
                this._sourceSprite.removeChild(this._sourceSprite.getChildByName("reflectionBitmap"));
            }

            var resultBm : Bitmap = new Bitmap(this._reflectionBmd);
            resultBm.name = "reflectionBitmap";

            switch (this.side)
            {
                case Reflect.LEFT:
                    resultBm.x = -this._sourceSprite.width - this._distance;
                    break;
                case Reflect.RIGHT:
                    resultBm.x = this._sourceSprite.width + this._distance;
                    break;
                case Reflect.BOTTOM:
                    resultBm.y = this._sourceSprite.height + this._distance;
                    break
                case Reflect.TOP:
                    resultBm.y = -this._sourceSprite.height - this._distance;
                    break;
            }

            this._sourceSprite.addChild(resultBm);
        }


        public function get reflectionAsBitmapData() : BitmapData
        {
            return this._reflectionBmd;
        }

        public function get reflectionAsSprite() : Sprite
        {
            var reflectionBm : Bitmap = new Bitmap(this._reflectionBmd);
            var reflectionSprite : Sprite = new Sprite();
            reflectionSprite.addChild(reflectionBm);
            return reflectionSprite;
        }


        protected function set sourceSprite(sourceSprite : Sprite) : void
        {
            this._sourceSprite = sourceSprite;
            //this.redraw();
        }

        public function get sourceSprite() : Sprite
        {
            return this._sourceSprite;
        }

        public function set alpha(alpha : Number) : void
        {
            this._alpha = alpha;
            this.redraw();
        }

        public function get alpha() : Number
        {
            return this._alpha;
        }

        public function set ratio(ratio : Number) : void
        {
            trace("Reflect.ratio");
            this._ratio = ratio;
            this.redraw();
        }

        public function get ratio() : Number
        {
            return this._ratio;
        }

        public function set distance(distance : Number) : void
        {
            this._distance = distance;
            if (this.add)
            {

                var resultBm : Bitmap = this._sourceSprite.getChildByName("reflectionBitmap") as Bitmap;

                switch (this.side)
                {
                    case Reflect.LEFT:
                        resultBm.x = -this._sourceSprite.width - distance;
                        break;
                    case Reflect.RIGHT:
                        resultBm.x = this._sourceSprite.width + distance;
                        break;
                    case Reflect.BOTTOM:
                        resultBm.y = this._sourceSprite.height + distance;
                        break
                    case Reflect.TOP:
                        resultBm.y = -this._sourceSprite.height - distance;
                        break;
                }
            }
        }

        public function get distance() : Number
        {
            return this._distance;
        }

        public function get side() : String
        {
            return this._side;
        }

        public function get add() : Boolean
        {
            return this._add;
        }

        public function set updateTime(updateTime : Number) : void
        {
            this._updateTime = updateTime;
            this.redraw();
        }

        public function get updateTime() : Number
        {
            return this._updateTime;
        }

        public function redraw() : void
        {

            this.spriteToFlippedBitmapData();

            this.createGradientBitmapData();

            this._reflectionBmd.copyChannel(this._gradientBmd, new Rectangle(0, 0, this._sourceSprite.width, this._sourceSprite.height), new Point(0, 0), 8, 8);

            if (this.add)
            {
                this.addToSource();
            }

            if (this._updateTime > 0)
            {
                if (this._updateTimer != null)
                {
                    this._updateTimer.stop();
                    this._updateTimer.removeEventListener(TimerEvent.TIMER, this.timerEventHandler);
                    this._updateTimer = null;
                }
                this._updateTimer = new Timer(this._updateTime);
                this._updateTimer.addEventListener(TimerEvent.TIMER, this.timerEventHandler);
                this._updateTimer.start();
            }
        }

        public function refresh() : void
        {

            this.spriteToFlippedBitmapData();

            this._reflectionBmd.copyChannel(this._gradientBmd, new Rectangle(0, 0, this._sourceSprite.width, this._sourceSprite.height), new Point(0, 0), 8, 8);
            if (this.add)
            {
                var resultBm : Bitmap = this._sourceSprite.getChildByName("reflectionBitmap") as Bitmap;
                resultBm.bitmapData = this._reflectionBmd;
            }
        }

        private function timerEventHandler(event : TimerEvent) : void
        {
            this.refresh();
        }
    }
}
