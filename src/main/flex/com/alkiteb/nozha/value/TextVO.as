package com.alkiteb.nozha.value
{
    public class TextVO
    {
        private var _text  : String;
        private var _size  : Number;
        private var _color : uint;
        
        /**
         * Returns text.
         */
        public function get text() : String
        {
            return _text;
        }
        
        /**
         * Sets text.
         */
        public function set text ( value : String ) : void
        {
            this._text = value;
        }
        
        /**
         * Returns size.
         */
        public function get size() : Number
        {
            return _size;
        }
        
        /**
         * Sets size.
         */
        public function set size ( value : Number ) : void
        {
            this._size = value;
        }
        
        /**
         * Returns color.
         */
        public function get color() : uint
        {
            return _color;
        }
        
        /**
         * Sets color.
         */
        public function set color ( value : uint ) : void
        {
            this._color = value;
        }
    }
}