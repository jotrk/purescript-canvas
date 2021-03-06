-- | This module defines foreign types and functions for working with the 2D
-- | Canvas API.

module Graphics.Canvas
  ( Canvas()
  , CanvasElement()
  , Context2D()
  , ImageData()
  , CanvasPixelArray()
  , CanvasImageSource()
  , Arc()
  , Composite(..)
  , Dimensions()
  , LineCap(..)
  , Rectangle()
  , ScaleTransform()
  , TextMetrics()
  , Transform()
  , TranslateTransform()
  , TextAlign(..)
  , CanvasGradient()
  , LinearGradient()
  , RadialGradient()
  , QuadraticCurve()
  , BezierCurve()

  , getCanvasElementById
  , getContext2D
  , getCanvasWidth
  , setCanvasWidth
  , getCanvasHeight
  , setCanvasHeight
  , getCanvasDimensions
  , setCanvasDimensions
  , canvasToDataURL

  , setLineWidth
  , setFillStyle
  , setStrokeStyle
  , setShadowBlur
  , setShadowOffsetX
  , setShadowOffsetY
  , setShadowColor

  , setLineCap
  , setGlobalCompositeOperation
  , setGlobalAlpha

  , beginPath
  , stroke
  , fill
  , clip
  , lineTo
  , moveTo
  , closePath
  , strokePath
  , fillPath

  , arc

  , rect
  , fillRect
  , strokeRect
  , clearRect

  , scale
  , rotate
  , translate
  , transform

  , textAlign
  , setTextAlign
  , font
  , setFont
  , fillText
  , strokeText
  , measureText

  , save
  , restore
  , withContext

  , withImage
  , getImageData
  , getImageDataWidth
  , getImageDataHeight
  , getImageDataPixelArray
  , putImageData
  , putImageDataFull
  , createImageData
  , createImageDataCopy

  , canvasElementToImageSource
  , drawImage
  , drawImageScale
  , drawImageFull

  , createLinearGradient
  , createRadialGradient
  , addColorStop
  , setGradientFillStyle
  
  , quadraticCurveTo
  , bezierCurveTo
  ) where

import Prelude

import Data.Function
import Data.Maybe
import Control.Monad.Eff
import Control.Monad.Eff.Exception.Unsafe (unsafeThrow)

-- | The `Canvas` effect denotes computations which read/write from/to the canvas.
foreign import data Canvas :: !

-- | A canvas HTML element.
foreign import data CanvasElement :: *

-- | A 2D graphics context.
foreign import data Context2D :: *

-- | An image data object, used to store raster data outside the canvas.
foreign import data ImageData :: *

-- | An array of pixel data.
foreign import data CanvasPixelArray :: *

-- | Opaque object for drawing elements and things to the canvas.
foreign import data CanvasImageSource :: *

-- | Opaque object describing a gradient.
foreign import data CanvasGradient :: *

foreign import canvasElementToImageSource :: CanvasElement -> CanvasImageSource

-- | Wrapper for asynchronously loading a image file by path and use it in callback, e.g. drawImage
foreign import withImage :: forall eff. String -> (CanvasImageSource -> Eff eff Unit) -> Eff eff Unit

foreign import getCanvasElementByIdImpl :: 
  forall r eff. Fn3 String
                    (CanvasElement -> r)
                    r
                    (Eff (canvas :: Canvas | eff) r)

-- | Get a canvas element by ID, or `Nothing` if the element does not exist.
getCanvasElementById :: forall eff. String -> Eff (canvas :: Canvas | eff) (Maybe CanvasElement)
getCanvasElementById elId = runFn3 getCanvasElementByIdImpl elId Just Nothing

-- | Get the 2D graphics context for a canvas element.
foreign import getContext2D :: forall eff. CanvasElement -> Eff (canvas :: Canvas | eff) Context2D 

-- | Get the canvas width in pixels.
foreign import getCanvasWidth :: forall eff. CanvasElement -> Eff (canvas :: Canvas | eff) Number

-- | Get the canvas height in pixels.
foreign import getCanvasHeight :: forall eff. CanvasElement -> Eff (canvas :: Canvas | eff) Number

-- | Set the canvas width in pixels.
foreign import setCanvasWidth :: forall eff. Number -> CanvasElement -> Eff (canvas :: Canvas | eff) CanvasElement

-- | Set the canvas height in pixels.
foreign import setCanvasHeight :: forall eff. Number -> CanvasElement -> Eff (canvas :: Canvas | eff) CanvasElement

-- | Canvas dimensions (width and height) in pixels.
type Dimensions = { width :: Number, height :: Number }

-- | Get the canvas dimensions in pixels.
getCanvasDimensions :: forall eff. CanvasElement -> Eff (canvas :: Canvas | eff) Dimensions
getCanvasDimensions ce = do
  w <- getCanvasWidth  ce
  h <- getCanvasHeight ce
  return {width : w, height : h}

-- | Set the canvas dimensions in pixels.
setCanvasDimensions :: forall eff. Dimensions -> CanvasElement -> Eff (canvas :: Canvas | eff) CanvasElement
setCanvasDimensions d ce = setCanvasHeight d.height ce >>= setCanvasWidth d.width

-- | Create a data URL for the current canvas contents
foreign import canvasToDataURL :: forall eff. CanvasElement -> Eff (canvas :: Canvas | eff) String

-- | Set the current line width.
foreign import setLineWidth :: forall eff. Number -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Set the current fill style/color.
foreign import setFillStyle :: forall eff. String -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Set the current stroke style/color.
foreign import setStrokeStyle :: forall eff. String -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Set the current shadow color.
foreign import setShadowColor :: forall eff. String -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Set the current shadow blur radius.
foreign import setShadowBlur :: forall eff. Number -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Set the current shadow x-offset.
foreign import setShadowOffsetX :: forall eff. Number -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Set the current shadow y-offset.
foreign import setShadowOffsetY :: forall eff. Number -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Enumerates the different types of line cap.
data LineCap = Round | Square | Butt

foreign import setLineCapImpl :: forall eff. String -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Set the current line cap type.
setLineCap :: forall eff. LineCap -> Context2D -> Eff (canvas :: Canvas | eff) Context2D
setLineCap Round  = setLineCapImpl "round"
setLineCap Square = setLineCapImpl "square" 
setLineCap Butt   = setLineCapImpl "butt"

-- | Enumerates the different types of alpha composite operations.
data Composite
   = SourceOver
   | SourceIn
   | SourceOut
   | SourceAtop
   | DestinationOver
   | DestinationIn
   | DestinationOut
   | DestinationAtop
   | Lighter
   | Copy
   | Xor

instance showComposite :: Show Composite where
  show SourceOver      = "source-over"
  show SourceIn        = "source-in"
  show SourceOut       = "source-out"
  show SourceAtop      = "source-atop"
  show DestinationOver = "destination-over"
  show DestinationIn   = "destination-in"
  show DestinationOut  = "destination-out"
  show DestinationAtop = "destination-atop"
  show Lighter         = "lighter"
  show Copy            = "copy"
  show Xor             = "xor"

foreign import setGlobalCompositeOperationImpl :: forall eff. Context2D -> String -> Eff (canvas :: Canvas | eff) Context2D

-- | Set the current composite operation.
setGlobalCompositeOperation :: forall eff. Context2D -> Composite -> Eff (canvas :: Canvas | eff) Context2D
setGlobalCompositeOperation ctx composite = setGlobalCompositeOperationImpl ctx (show composite)

-- | Set the current global alpha level.
foreign import setGlobalAlpha :: forall eff. Context2D -> Number -> Eff (canvas :: Canvas | eff) Context2D

-- | Begin a path object.
foreign import beginPath :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Stroke the current object.
foreign import stroke :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Fill the current object.
foreign import fill :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Clip to the current object.
foreign import clip :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Move the path to the specified coordinates, drawing a line segment.
foreign import lineTo  :: forall eff. Context2D -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

-- | Move the path to the specified coordinates, without drawing a line segment.
foreign import moveTo  :: forall eff. Context2D -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

-- | Close the current path.
foreign import closePath  :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | A convenience function for drawing a stroked path.
-- | 
-- | For example:
-- |
-- | ```purescript
-- | strokePath ctx $ do
-- |   moveTo ctx 10.0 10.0
-- |   lineTo ctx 20.0 20.0
-- |   lineTo ctx 10.0 20.0
-- |   closePath ctx
-- | ```
strokePath :: forall eff a. Context2D -> Eff (canvas :: Canvas | eff) a -> Eff (canvas :: Canvas | eff) a 
strokePath ctx path = do
  beginPath ctx
  a <- path
  stroke ctx
  return a

-- | A convenience function for drawing a filled path.
-- | 
-- | For example:
-- |
-- | ```purescript
-- | fillPath ctx $ do
-- |   moveTo ctx 10.0 10.0
-- |   lineTo ctx 20.0 20.0
-- |   lineTo ctx 10.0 20.0
-- |   closePath ctx
-- | ```
fillPath :: forall eff a. Context2D -> Eff (canvas :: Canvas | eff) a -> Eff (canvas :: Canvas | eff) a 
fillPath ctx path = do
  beginPath ctx
  a <- path
  fill ctx
  return a

-- | A type representing an arc object:
-- |
-- | - The center coordinates `x` and `y`,
-- | - The radius `r`,
-- | - The starting and ending angles, `start` and `end`.
type Arc =
  { x :: Number
  , y :: Number
  , r :: Number
  , start :: Number
  , end   :: Number
  }

-- | Render an arc object.
foreign import arc :: forall eff. Context2D -> Arc -> Eff (canvas :: Canvas | eff) Context2D

-- | A type representing a rectangle object:
-- |
-- | - The top-left corner coordinates `x` and `y`,
-- | - The width and height `w` and `h`.
type Rectangle = 
  { x :: Number
  , y :: Number
  , w :: Number
  , h :: Number
  }

-- | Render a rectangle.
foreign import rect :: forall eff. Context2D -> Rectangle -> Eff (canvas :: Canvas | eff) Context2D

-- | Fill a rectangle.
foreign import fillRect :: forall eff. Context2D -> Rectangle -> Eff (canvas :: Canvas | eff) Context2D

-- | Stroke a rectangle.
foreign import strokeRect :: forall eff. Context2D -> Rectangle -> Eff (canvas :: Canvas | eff) Context2D

-- | Clear a rectangle.
foreign import clearRect :: forall eff. Context2D -> Rectangle -> Eff (canvas :: Canvas | eff) Context2D

-- | An object representing a scaling transform:
-- | 
-- | - The scale factors in the `x` and `y` directions, `scaleX` and `scaleY`.
type ScaleTransform =
  { scaleX :: Number
  , scaleY :: Number
  }

-- | Apply a scaling transform.
foreign import scale  :: forall eff. ScaleTransform -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Apply a rotation.
foreign import rotate :: forall eff. Number -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | An object representing a translation:
-- | 
-- | - The translation amounts in the `x` and `y` directions, `translateX` and `translateY`.
type TranslateTransform =
  { translateX :: Number
  , translateY :: Number
  }

-- | Apply a translation
foreign import translate :: forall eff. TranslateTransform -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | An object representing a general transformation as a homogeneous matrix.
type Transform =
  { m11 :: Number
  , m12 :: Number
  , m21 :: Number
  , m22 :: Number
  , m31 :: Number
  , m32 :: Number
  }

-- | Apply a general transformation.
foreign import transform :: forall eff. Transform -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Enumerates types of text alignment.
data TextAlign
  = AlignLeft | AlignRight | AlignCenter | AlignStart | AlignEnd

instance showTextAlign :: Show TextAlign where
  show AlignLeft = "left"
  show AlignRight = "right"
  show AlignCenter = "center"
  show AlignStart = "start"
  show AlignEnd = "end"

foreign import textAlignImpl :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) String

-- | Get the current text alignment.
textAlign :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) TextAlign
textAlign ctx = unsafeParseTextAlign <$> textAlignImpl ctx
  where
  unsafeParseTextAlign :: String -> TextAlign
  unsafeParseTextAlign "left" = AlignLeft
  unsafeParseTextAlign "right" = AlignRight
  unsafeParseTextAlign "center" = AlignCenter
  unsafeParseTextAlign "start" = AlignStart
  unsafeParseTextAlign "end" = AlignEnd
  unsafeParseTextAlign align = unsafeThrow $ "invalid TextAlign: " ++ align
  -- ^ dummy to silence compiler warnings

foreign import setTextAlignImpl :: forall eff. Context2D -> String -> (Eff (canvas :: Canvas | eff) Context2D)

-- | Set the current text alignment.
setTextAlign :: forall eff. Context2D -> TextAlign -> Eff (canvas :: Canvas | eff) Context2D
setTextAlign ctx textalign =
  setTextAlignImpl ctx (show textalign)

-- | Text metrics:
-- |
-- | - The text width in pixels. 
type TextMetrics = { width :: Number }

-- | Get the current font.
foreign import font :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) String

-- | Set the current font.
foreign import setFont :: forall eff. String -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Fill some text.
foreign import fillText :: forall eff. Context2D -> String -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

-- | Stroke some text.
foreign import strokeText :: forall eff. Context2D -> String -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

-- | Measure some text.
foreign import measureText :: forall eff. Context2D -> String -> Eff (canvas :: Canvas | eff) TextMetrics

-- | Save the current context.
foreign import save  :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | Restore the previous context.
foreign import restore  :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | A convenience function: run the action, preserving the existing context.
-- | 
-- | For example, outside this block, the fill style is preseved:
-- |
-- | ```purescript
-- | withContext ctx $ do
-- |   setFillStyle "red" ctx
-- |   ...
-- | ```
withContext :: forall eff a. Context2D -> Eff (canvas :: Canvas | eff) a -> Eff (canvas :: Canvas | eff) a 
withContext ctx action = do
  save ctx
  a <- action
  restore ctx
  return a

-- | Get image data for a portion of the canvas.
foreign import getImageData :: forall eff. Context2D -> Number -> Number -> Number -> Number -> Eff (canvas :: Canvas | eff) ImageData

-- | Set image data for a portion of the canvas.
foreign import putImageDataFull :: forall eff. Context2D -> ImageData -> Number -> Number -> Number -> Number -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

-- | Get image data for a portion of the canvas.
foreign import putImageData :: forall eff. Context2D -> ImageData -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

-- | Create an image data object.
foreign import createImageData :: forall eff. Context2D -> Number -> Number -> Eff (canvas :: Canvas | eff) ImageData

-- | Create a copy of an image data object.
foreign import createImageDataCopy :: forall eff. Context2D -> ImageData -> Eff (canvas :: Canvas | eff) ImageData

-- | Get the width of an image data object in pixels.
foreign import getImageDataWidth :: forall eff. ImageData -> Eff (canvas :: Canvas | eff) Number

-- | Get the height of an image data object in pixels.
foreign import getImageDataHeight :: forall eff. ImageData -> Eff (canvas :: Canvas | eff) Number

-- | Get the pixel data array from an image data object.
foreign import getImageDataPixelArray :: forall eff. ImageData -> Eff (canvas :: Canvas | eff) CanvasPixelArray

foreign import drawImage :: forall eff. Context2D -> CanvasImageSource -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

foreign import drawImageScale :: forall eff. Context2D -> CanvasImageSource -> Number -> Number -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

foreign import drawImageFull :: forall eff. Context2D -> CanvasImageSource -> Number -> Number -> Number -> Number -> Number -> Number -> Number -> Number -> Eff (canvas :: Canvas | eff) Context2D

-- | A type representing a linear gradient.
-- |  -  Starting point coordinates: (`x0`, `y0`)
-- |  -  Ending point coordinates: (`x1`, `y1`)

type LinearGradient =
    { x0 :: Number
    , y0 :: Number
    , x1 :: Number
    , y1 :: Number
    }

-- | Create a linear CanvasGradient.
foreign import createLinearGradient :: forall eff. LinearGradient -> Context2D -> Eff (canvas :: Canvas | eff) CanvasGradient

-- | A type representing a radial gradient.
-- |  -  Starting circle center coordinates: (`x0`, `y0`)
-- |  -  Starting circle radius: `r0`
-- |  -  Ending circle center coordinates: (`x1`, `y1`)
-- |  -  Ending circle radius: `r1`

type RadialGradient =
    { x0 :: Number
    , y0 :: Number
    , r0 :: Number
    , x1 :: Number
    , y1 :: Number
    , r1 :: Number
    }

-- | Create a radial CanvasGradient.
foreign import createRadialGradient :: forall eff. RadialGradient -> Context2D -> Eff (canvas :: Canvas | eff) CanvasGradient

-- | Add a single color stop to a CanvasGradient.
foreign import addColorStop :: forall eff. Number -> String -> CanvasGradient -> Eff (canvas :: Canvas | eff) CanvasGradient

-- | Set the Context2D fillstyle to the CanvasGradient.
foreign import setGradientFillStyle :: forall eff. CanvasGradient -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | A type representing a quadratic Bézier curve.
-- |  - Bézier control point: (`cpx`, `cpy`)
-- |  - Ending point coordinates: (`x`, `y`)

type QuadraticCurve =
    { cpx :: Number
    , cpy :: Number
    , x   :: Number
    , y   :: Number
    }

-- | Draw a quadratic Bézier curve.
foreign import quadraticCurveTo :: forall eff. QuadraticCurve -> Context2D -> Eff (canvas :: Canvas | eff) Context2D

-- | A type representing a cubic Bézier curve.
-- |  - First Bézier control point: (`cp1x`, `cp1y`)
-- |  - Second Bézier control point: (`cp2x`, `cp2y`)
-- |  - Ending point: (`x`, `y`)

type BezierCurve =
    { cp1x :: Number
    , cp1y :: Number
    , cp2x :: Number
    , cp2y :: Number
    , x    :: Number
    , y    :: Number
    }

-- | Draw a cubic Bézier curve.
foreign import bezierCurveTo :: forall eff. BezierCurve -> Context2D -> Eff (canvas :: Canvas | eff) Context2D
