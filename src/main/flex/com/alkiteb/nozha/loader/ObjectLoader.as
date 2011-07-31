package com.alkiteb.nozha.loader
{
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    import com.alkiteb.nozha.events.LoadingEvent;

    [Event(name="dataLoaded", type="com.alkiteb.nozha.events.LoadingEvent")]
    public class ObjectLoader extends EventDispatcher
    {
        private var _XMLLoader:URLLoader;
        private var _imageLoader:Loader;
        private var _loadedData:Object;

        /**
         * Loads xml file.
         */
        public function loadXML(url:String):void
        {
            this._XMLLoader=new URLLoader();
            this._XMLLoader.addEventListener(Event.COMPLETE, xmlLoadingComplete);
            this._XMLLoader.load(new URLRequest(url));
        }

        /**
         * Loads an image.
         */
        public function loadImage(url:String) : void
        {
            this._imageLoader=new Loader();
            this._imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoadingComplete);
            this._imageLoader.load(new URLRequest(url));
        }

        /**
         * Dispatched when the loading of the xml is complete.
         */
        private function xmlLoadingComplete(event:Event):void
        {
            this._XMLLoader.removeEventListener(Event.COMPLETE, xmlLoadingComplete);
            this._loadedData = new XML(URLLoader(event.currentTarget).data);
            dispatchEvent(new LoadingEvent(LoadingEvent.DATA_LOADED));
        }
        
        
        private function imageLoadingComplete(event:Event) : void
        {
            this._loadedData = LoaderInfo(event.currentTarget).content;
            dispatchEvent(new LoadingEvent(LoadingEvent.DATA_LOADED));
        }

        public function get loadedData():Object
        {
            return _loadedData;
        }
    }
}