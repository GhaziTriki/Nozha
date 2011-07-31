package com.alkiteb.nozha.events
{
    import flash.events.Event;

    public class LoadingEvent extends Event
    {
        public static const DATA_LOADED : String = "dataLoaded";

        public function LoadingEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
        {
            super(type, bubbles, cancelable);
        }
        
        override public function clone():Event
        {
            return new LoadingEvent( type, bubbles, cancelable );
        }
    }
}