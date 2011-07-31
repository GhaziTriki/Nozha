package com.alkiteb.nozha.utils
{
    public class StringUtils
    {
        /**
         * Inverts the order of the word to display arabic texxt in the good direction
         */
        public static function parseArabic ( value : String ) : String
        {
            var ar : Array = value.split(" ");
            value = "";
            for ( var i : int = 0; i < ar.length; i++ )
            {
                value += ar[ar.length-i-1].toString() + " ";
            }
            return value;
        }
    }
}