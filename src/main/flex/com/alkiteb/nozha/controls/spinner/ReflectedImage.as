package com.alkiteb.nozha.controls.spinner
{
    import com.rictus.reflector.Reflector;
    import com.sebastiaanholtrop.reflection.Reflect;
    
    import flash.events.Event;
    
    import mx.binding.utils.BindingUtils;
    import mx.controls.Image;
    
    public class ReflectedImage extends Image
    {
        private var _reflection : Reflector;
        
        public function ReflectedImage()
        {
            super();
            var _reflection : Reflector = new Reflector();
            _reflection.alpha = 0.33;
            _reflection.falloff = 0.75;
            _reflection.target = this;
            this.addEventListener(Event.ENTER_FRAME, loadedComplete, false, 0, true);
        }
        
        private function loadedComplete( event : Event ) : void
        {
            if ( _reflection )
            {
                _reflection.x = x;
                _reflection.x = y;
            }
           // this.addEventListener(Event.ENTER_FRAME, loadedComplete, false, 0, true);
        }
    }
}