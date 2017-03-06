import flash.media.Sound;
import flash.net.URLRequest;
import flash.media.SoundChannel;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.net.FileReference;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.display.Sprite;
import flash.display.Shape;

var music : Sound = new Sound();
var channel : SoundChannel;
music.load(new URLRequest("Purple Lamborghini.mp3") , new SoundLoaderContext(2000, false));
channel = music.play();

var isPlay : Boolean = true;
var playPosition = 0;
var soundPosition = 0;
var progress:MovieClip = track.progress;
var bar:MovieClip = Bar;
var bg:MovieClip = track.bg;
var dragIs:Boolean=false;  //sound position controller drag detector
var volumeControlDragIs:Boolean=false;  //volume controller drag detector
track.progress.width=0;

var cl:int = 512;
var ba:ByteArray = new ByteArray();
var spectrum:Array = []; // spectrum
var spectrum2:Array = []; // Small box over the spectrum
var shadow_bars:Array = []; // Shadow below the spectrum
var shadowContainer:Sprite = new Sprite();
var spectrumContainer:Sprite = new Sprite();

this.addChild(shadowContainer);
this.addChild(spectrumContainer);
spectrumContainer.scaleY = -1;
spectrumContainer.y = stage.stageHeight-308;
spectrumContainer.x = 15;
shadowContainer.y = stage.stageHeight-300;
shadowContainer.x = 15;

function makeBar(container:Sprite, w:Number,h:Number, color:Number):Shape{
	var r:Shape = new Shape();
	container.addChild(r);
	r.graphics.beginFill(color, 1);
	r.graphics.drawRect(0,0,w,h);
	r.graphics.endFill();
	return r;
}

function drawBarSpectrum():void{
	var i:int = 0;
	var w:Number = 1.5;
	while (i<cl)
	{
		spectrum.push(makeBar(spectrumContainer, w, 3, i<256 ? 0x224488 : 0xAA00FF));
		spectrum2.push(makeBar(spectrumContainer, w, 5, 0xDDCCBB));
		shadow_bars.push(makeBar(shadowContainer, w, 1, 0x4B4D53));
		var bar:Shape = spectrum[i];
		var bar2:Shape = spectrum2[i];
		var shadow_bar:Shape = shadow_bars[i];
		shadow_bar.x = bar2.x = bar.x = i*(bar.width);
		i++;
	}
}
drawBarSpectrum();
function makeSpectrum():void{
	SoundMixer.computeSpectrum(ba, false, 0);   //Create spectrum
	var i:int = cl;
	while (i>0)
	{
		i--;
		var ty = ba.readFloat()*350;
		spectrum[i].height -= (spectrum[i].height-ty)*.05;
		spectrum2[i].y -= (spectrum2[i].y-(spectrum[i].y+spectrum[i].height+3))*.7;
		shadow_bars[i].height -= (shadow_bars[i].height-(ty))*.05;
	}
}

function setDrag():void{
	bar.buttonMode = true;
	bar.addEventListener(MouseEvent.MOUSE_DOWN, barDownHandler);
	bar.addEventListener(MouseEvent.CLICK, barClickHandler);
}

setDrag();

function barDownHandler(e:MouseEvent):void{
	dragIs=true;
	var me:MovieClip=e.currentTarget as MovieClip;
	var left:Number=0;
	var top:Number = bar.y;
	var right:Number=bg.width - bar.width;
	var bottom:Number = 0;
	var rect:Rectangle = new Rectangle(left, top, right, bottom);
	me.startDrag(false, rect);
	me.addEventListener(MouseEvent.MOUSE_MOVE, barMoveHandler, false, 0, true);
	stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
}

function mouseUpHandler(event:MouseEvent):void{
	dragStopHandler(bar);
}

function barMoveHandler(e:MouseEvent):void{
	var me:MovieClip = e.currentTarget as MovieClip;
	e.updateAfterEvent();
}

function dragStopHandler(me:MovieClip):void{
	dragIs = false;
	me.stopDrag();
	me.removeEventListener(MouseEvent.MOUSE_MOVE, barMoveHandler);
	channel.stop();
	soundPosition = bar.x/(bg.width-bar.width)*music.length;
	channel = music.play(soundPosition);
	stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
}

function barClickHandler(e:MouseEvent):void{
	var me:MovieClip = e.currentTarget as MovieClip;
	dragStopHandler(me);
}

stopBtn.addEventListener(MouseEvent.CLICK, musicStop);
playBtn.addEventListener(MouseEvent.CLICK, musicPlay_Pause);
stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);

//show time
function enterFrameHandler(e:Event):void{
	positionText.text = overNumber(int((channel.position/1000)/60))+ " : " + overNumber(Math.round((channel.position/1000)%60)) + "     /     " + overNumber(int((music.length/1000)/60)) + " : " + overNumber(Math.round((music.length/1000)%60))
	progress.width = bar.x-13;
	
	if(!dragIs){
		bar.x = (channel.position/1000)/(music.length/1000) * (bg.width-bar.width)+15;
	}
	
	makeSpectrum();
}

function overNumber(n:int):*{
	return n<10 ? "0"+n : n;
}

function musicStop(e:MouseEvent):void{
	if(isPlay){
		soundPosition = 0;
		channel.stop();
		playBtn.gotoAndStop(2);
		isPlay = false;
	}else{
		soundPosition = 0;
		channel.stop();
		isPlay = false;
	}
}

function musicPlay_Pause(e:MouseEvent):void{
	if(isPlay){
		soundPosition = channel.position;
		channel.stop();
		playBtn.gotoAndStop(2);
		isPlay = false;
	}else{
		channel = music.play(soundPosition);
		playBtn.gotoAndStop(1);
		isPlay = true;
	}
}
