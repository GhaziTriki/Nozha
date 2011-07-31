package com.alkiteb.nozha.value
{
    public class ImageVO
    {
        private var _source   : String;
        private var _title    : TextVO;
        private var _messages : Array;
        
        /**
         * Returns source.
         */
        public function get source() : String
        {
            return _source;
        }
        
        /**
         * Sets source.
         */
        public function set source ( value : String ) : void
        {
            this._source = value;
        }
        
        /**
         * Returns title.
         */
        public function get title() : TextVO
        {
            return _title;
        }
        
        /**
         * Sets title.
         */
        public function set title ( value : TextVO ) : void
        {
            this._title = value;
        }
        
        /**
         * Returns message.
         */
        public function get messages() : Array
        {
            return _messages;
        }
        
        /**
         * Sets message.
         */
        public function set messages ( value : Array ) : void
        {
            this._messages = value;
        }
    }
}