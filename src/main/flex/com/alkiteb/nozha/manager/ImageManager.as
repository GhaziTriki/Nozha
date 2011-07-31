package com.alkiteb.nozha.manager
{
    import flash.display.Bitmap;
    
    import mx.collections.ArrayCollection;
    import mx.containers.Canvas;
    import mx.controls.Image;
    import mx.controls.Label;
    import mx.core.IMXMLObject;
    import mx.effects.Blur;
    import mx.effects.Fade;
    import mx.effects.Move;
    import mx.effects.Parallel;
    import mx.effects.Resize;
    import mx.events.EffectEvent;
    
    import com.alkiteb.nozha.conf.EffectConfiguration;
    import com.alkiteb.nozha.controls.spinner.Spinner;
    import com.alkiteb.nozha.events.LoadingEvent;
    import com.alkiteb.nozha.loader.ObjectLoader;
    import com.alkiteb.nozha.utils.StringUtils;
    import com.alkiteb.nozha.value.ImageVO;
    import com.alkiteb.nozha.value.TextVO;

    public class ImageManager implements IMXMLObject
    {
       private const PLAYING_FORWARD  : String  = "FORWARD"; 
       private const PLAYING_BACKWARD : String = "BACKWARD"; 
        
        private var _view : nozha;
        private var _objectLoader : ObjectLoader;
        private var _images : ArrayCollection;
        private var _bitmaps : ArrayCollection;
        private var _lastLoadedImageIndex : int;
        private var _loadedImages : int;
        private var _parallel : Parallel;

        // The total number of image
        private var _totalNumber : int;

        // The number of images that should be loaded into the application
        private var _mustLoadNumber : int = 7;

        // Effects arrays
        private var _moveEffects : ArrayCollection;
        private var _resizeEffects : ArrayCollection;
        private var _fadeEffects : ArrayCollection
        private var _blurEffects : ArrayCollection;
        /**
         * Constructor
         */
        public function ImageManager()
        {
            _objectLoader = new ObjectLoader();
            _images = new ArrayCollection();

            _moveEffects = new ArrayCollection();
            _resizeEffects = new ArrayCollection();
            _fadeEffects = new ArrayCollection();
            _blurEffects = new ArrayCollection();
            _bitmaps = new ArrayCollection();

            _lastLoadedImageIndex = -1;
            _loadedImages = 0;
        }

        /**
         * IMXMLObject implementation.
         */
        public function initialized(document : Object, id : String) : void
        {
            _view = document as nozha;
            createEffects();
        }

        //*******************************************//
        // Effects configuration and Initialisation        
        //*******************************************//

        /**
         * Creates effects that will be used for image transitions
         */
        public function createEffects() : void
        {
            _parallel = new Parallel();
            _parallel.addEventListener(EffectEvent.EFFECT_END, parallelEndHandler);
            var move : Move;
            var blur : Blur;
            var resize : Resize;
            for ( var i : int = 0; i < _mustLoadNumber; i++ )
            {
                move = new Move();
                resize = new Resize();
                blur = new Blur();
                _parallel.addChild(move);
                _moveEffects.addItem(move);
                _parallel.addChild(resize);
                _resizeEffects.addItem(resize);
                _parallel.addChild(blur);
                _blurEffects.addItem(blur);
            }

            // Fade in effect
            var fadeIn : Fade = new Fade();
            fadeIn.alphaFrom = 0;
            fadeIn.alphaTo = 1;
            _fadeEffects.addItem(fadeIn);
            _parallel.addChild(fadeIn);

            // Fade out effect
            var fadeOut : Fade = new Fade();
            fadeOut.alphaFrom = 1;
            fadeOut.alphaTo = 0;
            _fadeEffects.addItem(fadeOut);
            _parallel.addChild(fadeOut);

        }

        private function parallelEndHandler( event : EffectEvent ) : void
        {
            configureText();
            drawMessages();
            showText(true);
        }

        //*******************************************//
        // XML Loading       
        //*******************************************//

        /**
         * Creates an XMLLoader to load image list.
         */
        public function loadXMLFile() : void
        {
            _objectLoader.addEventListener(LoadingEvent.DATA_LOADED, xmlLoadedHandler, false, 0, true);
            _objectLoader.loadXML("images.xml");
        }

        /**
         * Triggered when xml loading is complete. It extract data from the laoded xml.
         */
        private function xmlLoadedHandler(event : LoadingEvent) : void
        {
            ObjectLoader(event.currentTarget).removeEventListener(LoadingEvent.DATA_LOADED, xmlLoadedHandler);
            var xml : XML = XML(ObjectLoader(event.currentTarget).loadedData);

            // Start exctrating images from the file
            var imageVO : ImageVO;
            var textVO  : TextVO;
            for (var i : int = 0; i < xml.children().length(); i++)
            {
                imageVO = new ImageVO();
                imageVO.source = xml.image[i].source;
                textVO = new TextVO();
                textVO.color = xml.image[i].title..@color;
                textVO.size = xml.image[i].title..@size;
                textVO.text = StringUtils.parseArabic(xml.image[i].title);
                imageVO.title = textVO;
                imageVO.messages = [];

                for ( var j : int = 0; j < xml.image.messages[i].message.length(); j++ )
                {
                    textVO = new TextVO();
                    textVO.color = xml.image.messages[i].message[j]..@color;
                    textVO.size = xml.image.messages[i].message[j]..@size;
                    textVO.text = StringUtils.parseArabic(xml.image[i].messages.message[j]);
                    imageVO.messages.push(textVO);
                }
//                imageVO.message = xml.image[i].message;
                _images.addItem(imageVO);
            }
            // We store our image number
            _totalNumber = _images.length;

            // We add the final image at the beginning for previous action handling
            _images.addItemAt(_images.getItemAt(_images.length - 1), 0);
            _images.removeItemAt(_images.length - 1);
            
            loadFirstImages();
        }

        //*******************************************//
        // Images loading        
        //*******************************************//

        /**
         * Load images the first time.
         */
        public function loadFirstImages() : void
        {
            _objectLoader.addEventListener(LoadingEvent.DATA_LOADED, addImage);
            _objectLoader.loadImage(_images.getItemAt(_loadedImages).source);
        }

        /**
         * Adding first images after their loading handler
         */
        public function addImage(event : LoadingEvent) : void
        {
            var bitmap : Bitmap = Bitmap(_objectLoader.loadedData);
            _bitmaps.addItem(bitmap);
            _loadedImages++;
            if (_loadedImages < _mustLoadNumber)
            {
                loadFirstImages();
            }
            else
            {
                _objectLoader.removeEventListener(LoadingEvent.DATA_LOADED, addImage);
                drawFirstImages();
            }
        }

        /**
         * Draws the first images.
         */
        public function drawFirstImages() : void
        {
            var bitmap : Bitmap;
            var image : Image;
            for ( var i : int = 0; i < _mustLoadNumber; i++ )
            {
                addImageAt( _bitmaps.getItemAt(i) as Bitmap, 0, i, true);
            }
            configureEffects();
            showHideSpinner();
            _parallel.duration = 750;
            _parallel.play();
        }

        //*******************************************//
        // Navigation methods         
        //*******************************************//

        /**
         * Goes to the next image
         */
        public function goNext() : void
        {
            if ( !_parallel.isPlaying && !_view.textHolderShowEffect.isPlaying )
            {
                showHideSpinner();
                _objectLoader.addEventListener(LoadingEvent.DATA_LOADED, goNextHandler);
                _objectLoader.loadImage(_images.getItemAt(getPlayImageIndex()).source);
            }
        }

        public function goPrevious() : void
        {
            if ( !_parallel.isPlaying )
            {
                showHideSpinner();
                _objectLoader.addEventListener(LoadingEvent.DATA_LOADED, goPreviousHandler);
                _objectLoader.loadImage(_images.getItemAt(getPlayImageIndex(true)).source);
            }
        }

        //*******************************************//
        // Index methods        
        //*******************************************//

        /**
         * Reutrns the next image to load index
         */
        private function getPlayImageIndex( previous : Boolean = false ) : int
        {
            var index : int;
            if ( !previous )
            {
                _lastLoadedImageIndex = _lastLoadedImageIndex == -1 ? 6 : _lastLoadedImageIndex;
                index = _lastLoadedImageIndex < _mustLoadNumber ? _lastLoadedImageIndex + 1 : 0;
            }
            else
            {
                _lastLoadedImageIndex = _lastLoadedImageIndex == -1 ? 0 : _lastLoadedImageIndex;
                index = _lastLoadedImageIndex > 0 ? _lastLoadedImageIndex - 1 : _mustLoadNumber;
            }
            return index;
        }

        private function updateLastLoadedImageIndex( previous : Boolean = false) : void
        {
            if ( !previous )
            {
                _lastLoadedImageIndex < _mustLoadNumber ? _lastLoadedImageIndex++ : _lastLoadedImageIndex = 0 ;
            }
            else
            {
                _lastLoadedImageIndex > 0 ? _lastLoadedImageIndex-- : _lastLoadedImageIndex = _mustLoadNumber;
            }
        }

        //*******************************************//
        // Navigation Handlers         
        //*******************************************//

        /**
         * Handles loading next image
         */
        private function goNextHandler(event : LoadingEvent) : void
        {
            // Storing image
            showText(false);
            var bitmap : Bitmap = Bitmap(_objectLoader.loadedData);
            _bitmaps.addItemAt(bitmap,0);
            _bitmaps.removeItemAt(6);
            _objectLoader.removeEventListener(LoadingEvent.DATA_LOADED, goNextHandler);
            updateLastLoadedImageIndex();
            // Drawing image
            imageHolder.removeChildAt(6);
            addImageAt(bitmap, 0, 6, false);

            configureEffects();
            showHideSpinner();
            _parallel.duration = 500;
            _parallel.play();
        }

        private function goPreviousHandler(event : LoadingEvent) : void
        {
            showText(false);
            var bitmap : Bitmap = Bitmap(_objectLoader.loadedData);
            _bitmaps.addItem(bitmap);
            _bitmaps.removeItemAt(0);
            _objectLoader.removeEventListener(LoadingEvent.DATA_LOADED, goPreviousHandler);
            updateLastLoadedImageIndex(true);

            // Drawing image
            imageHolder.removeChildAt(0);
            addImageAt(bitmap, 6, 0, false);
            
            configureEffects(true);
            showHideSpinner();
            _parallel.duration = 500;
            _parallel.play();
        }

        //*******************************************//
        // Image Configuration        
        //*******************************************//
        
        /**
         * Configure effects
         */
        private function configureEffects( previous : Boolean = false) : void
        {
            var move : Move;
            var resize : Resize;
            var blur : Blur;
            var image : Image;
            var i : int = 0;
            Fade(_fadeEffects.getItemAt(previous?0:1)).target = (imageHolder.getChildAt(_mustLoadNumber-i-1));
            for ( ; i < _mustLoadNumber; i++ )
            {
                move = Move(_moveEffects.getItemAt(i));
                resize = Resize(_resizeEffects.getItemAt(i));
                blur = Blur(_blurEffects.getItemAt(i));
                image = imageHolder.getChildAt(_mustLoadNumber-i-1) as Image;

                // Setting effects configuration
                move.target = image;
                resize.heightFrom = image.height;
                resize.heightTo = Bitmap(image.content).bitmapData.height * EffectConfiguration.sizeRatios[i];
                resize.widthFrom = image.width;
                resize.widthTo = Bitmap(image.content).bitmapData.width * EffectConfiguration.sizeRatios[i];

                blur.target = image;
                blur.blurXTo = EffectConfiguration.blurValues[i];
                blur.blurYTo = EffectConfiguration.blurValues[i];

                resize.target = image;
                move.xFrom = image.x;
                move.xTo = EffectConfiguration.xPositions[i];
                move.yFrom = image.y;
                move.yTo = (nozhaApp.height - resize.heightTo) / 2
                image.alpha = 1;
            }
            Fade(_fadeEffects.getItemAt(previous?1:0)).target = image;
        }

        /**
         * Adds an imagge to the imageHolder
         */
        public function addImageAt( bitmap : Bitmap, index : int, effectIndex : int, firstTime : Boolean = false ) : void
        {
            var image : Image;
            image = new Image();
            image.source = bitmap;
            if ( index == _mustLoadNumber - 1 || index == 0 )
            {
                image.alpha = 0;
                    //image.visible = false;
            }
            image.x = firstTime? 540 : EffectConfiguration.xPositions[effectIndex];
            image.width = bitmap.bitmapData.width * EffectConfiguration.sizeRatios[effectIndex];
            image.height = bitmap.bitmapData.height * EffectConfiguration.sizeRatios[effectIndex];
            image.y = (nozhaApp.height - image.height) / 2;
            imageHolder.addChildAt(image, index);
        }

        //*******************************************//
        // Text methods     
        //*******************************************//
        /**
         * Configures text related to the image
         */
        private function configureText() : void 
        {
            var index : int = _lastLoadedImageIndex + 1;
            if ( index == _images.length)
            {
                index = _images.length - index;
            }
            var imageVO : ImageVO = _images.getItemAt( index ) as ImageVO;
            _view.titleText.text = imageVO.title.text + " " + _lastLoadedImageIndex;
            _view.titleText.setStyle( "fontSize", imageVO.title.size );
            _view.titleText.setStyle( "color", imageVO.title.color );
        }
        
        public function drawMessages() : void
        {
            var index : int = _lastLoadedImageIndex + 1;
            if ( index == _images.length)
            {
                index = _images.length - index;
            }
            var imageVO : ImageVO = _images.getItemAt( index ) as ImageVO;
            var message : TextVO;
            var messageLabel : Label;
            messagesHolder.removeAllChildren();
            for each ( message in imageVO.messages )
            {
                messageLabel = new Label();
                messageLabel.text = message.text;
                messageLabel.setStyle("color", message.color);
                messageLabel.setStyle("fontSize", message.size);
                //messageLabel.setStyle("right", 0);
                messageLabel.y = messagesHolder.getChildren().length * 24;
                messagesHolder.addChild(messageLabel);
            }
            textShowEffect.play(messagesHolder.getChildren());
        }
        
        public function showText( value : Boolean ) : void
        {
            textHolder.visible = value;
            _view.titleText.visible = value;
        }
        
        //*******************************************//
        // Spinner control         
        //*******************************************//
        public function showHideSpinner() : void
        {
            spinner.visible = !spinner.visible;
            spinner.isPlaying ? spinner.stop() : spinner.play();
        }

        //*******************************************//
        // Shorcuts         
        //*******************************************//

        /**
         * Returns associated view
         */
        private function get nozhaApp() : nozha
        {
            return _view;
        }

        /**
         * Retruns the image holder container.
         */
        private function get imageHolder() : Canvas
        {
            return _view.imageHolder;
        }

        /**
         * Retruns the text holder container.
         */
        private function get textHolder() : Canvas
        {
            return _view.textHolder;
        }
        
        /**
         * Returns the message holder VBox
         */
        private function get messagesHolder() : Canvas
        {
            return _view.messagesHolder;
        }

        /**
         * Returns the spinner
         */
        private function get spinner() : Spinner
        {
            return _view.spinner;
        }
        
        /**
         * Returns the text show effect
         */
        private function get textShowEffect() : Parallel
        {
            return _view.textShowEffect;
        }
    }
}
