B-Lab SuperCollider勉強会_6.26



[モノフォニーとポリフォニー]




音は時間軸上での変化です。
そして並列的に音を扱うことは作曲においては必須課題です。


一つの音の時間軸上での変化には、音色とそしてエンベロープがあります。

______________________


エンベロープ


サイン波にエンべロープをかけみます。

EnvGenというUGenを使います。

x={SinOsc.ar(440,0,0.2)*EnvGen.ar(Env.linen)}.play


Envといのはエンペローブを整形してくれるクラスです。
.linenは台形のエンペローブです。

ローカルサーバウィンドウのSynthsを見てください。1のままです。音は出ていませんがシンセが生成されたまままだ処理が続いています。

音を止めましょう。
x.free;

エンベロープが終わったタイミングでシンセを消去したいので、
doneActionというアーギュメントを”2”で埋めます。
x={SinOsc.ar(440,0,0.2)*EnvGen.ar(Env.linen,doneAction:2)}.play

エンベロープが終わるとシンセが消去されます。






.testでサイン波で確かめる事ができます。さらに.plotでグラフを表示できます。

Env.linen(1, 2, 3, 0.6).test.plot;

その他の
Envメソッド
Env.new([0, 1, 0.3, 0.8, 0], [2, 3, 1, 4], -2).test.plot;
Env.triangle(1, 1).test.plot;
Env.sine(1,1).test.plot;
Env.perc(0.05, 1, 1, -4).test.plot;
Env.asr(0.02, 0.5, 1, 1, -4).test.plot;
Env.adsr(0.02, 0.2, 0.25, 1, 1, -4).test.plot;
Env.dadsr(0.5,0.02, 0.2, 0.25, 1, 1, -4).test.plot;
Env.cutoff(1, 1, 4).test.plot;
______________________


Decay UGen

トリガーを使ったエンべロープ

(
{var trig;
trig=Impulse.kr(2);
SinOsc.ar(400,0,0.3)*Decay.kr(trig,0.2)}.play;
)

(
{var trig;
trig=Impulse.kr(1);
SinOsc.ar(400,0,0.3)*Decay2.kr(trig,0.001,1)}.play;
)


______________________


マルチチャンネル


SuperColliderではオーディオシグナルのチャンネルをBus(バス)と呼ばれるは0~127までの整数で管理しています。
Bus(バス)にはコントロールバス、オーディオバス、インプット／アウトプットバスなどあります。がここではオーディオバスについて触れます。


基本的に1チャンネルごとに1プロセスをあたえなくてはいけません。
{SinOsc.ar(440,0,0.3)}.play;

Lチャンネルしか鳴りません。


{SinOsc.ar(440,0,0.3).dup}.play;
LR同じシグナルが鳴ります。.dupはオブジェクトをコピーしてくれます。



List

UGenの中ではListはそれぞれ違ったチャンネルに割り当てられます。このときUGenのインスタンスは複数作られます。
{Pulse.ar([400, 500, 600],[0.5, 0.1], 0.2)}.play

上のプログラムは以下と同じ。

{[ Pulse.ar(400,0.5,0.2), Pulse.ar(500,0.1,0.2), Pulse.ar(600,0.5,0.2) ]}.play


Mix

{ Mix.new(  Pulse.ar([400, 501, 600], [0.5, 0.1], 0.1) ) }.play
Mixは複数のシグナルをミックスして一つのチャンネルに束ねます。束はListで表現します。


{ Mix.fill( 12 ,{ SinOsc.ar( { 3000.rand }, 0 , 0.05 ) } ) }.play
Mix.fillはnに指定した数だけfunctionを繰り返し一つのチャンネルにまとめます。

//Mix.fill(n,function)


______________________


ポリフォニー

先週までの変数に代入する方法。

(
a=Pbind(\dur,0.5).play

b=Pbind(\dur,0.5,\note,Pseq([0,1,2,3],10)).play

c=Pbind(\dur,0.25,\note,Pseq([0,1,2,3,4,5,6,7,8,9],inf),\amp,Prand([0,0.3],inf)).play
)


Ppar

複数のストリームを束ねます。

(
a=Ppar(
	[
		Pbind(\dur,1),

		Pbind(\dur,0.75,\note,Pseq([0,1,2,3],inf)),

		Pbind(\dur,0.25,\note,Pseq([0,1,2,3,4,5,6,7,8,9],inf),\amp,Prand([0,0.3],inf))
	]).play;
)
a.stop;





Pdef

ストリームを名前で管理。

(
Pdef(\test_pdef,
Ppar(
	[
		Pbind(\dur,1,\note,Pseq([5,0,2],inf)),

		Pbind(\dur,0.75,\note,Prand([0,2,5,7,9,12]+12,inf)),

		Pbind(\dur,0.125,\note,Prand([0,2,5,7,9,12]-12,inf),\amp,Prand([0,0.3],inf))
	])
	)
)
Pdef(\test_pdef).play;
Pdef(\test_pdef).stop;




//＊自分のシンセを作ってストリームで演奏してみましょう

______________________
______________________
______________________
______________________



サウンドファイル


サウンドファイルを扱うにはBufferを使います。
サウンドファイルはsounds/以下におくのが良いでしょう。


b = Buffer.new(s);//サーバにバッファを作ります
b.allocRead("sounds/a11wlk01.wav");//サウンドファイルを割り当てます。

x = { PlayBuf.ar(1, b.bufnum, BufRateScale.kr(b.bufnum), loop: 1) * 0.5 }.play;
x.free; b.free;







TGrains
グラニューラシンセシスのためのUGen


s.sendMsg(\b_allocRead, 10, "sounds/a11wlk01.wav");


(
{
	var b = 10, trate, dur, rate;
	trate = MouseY.kr(2,200,1);
	dur = 4 / trate;
	rate = 1;
	TGrains.ar(2, Impulse.ar(trate), b, rate, MouseX.kr(0,BufDur.kr(b)), dur, Dseq([-1, 1], inf), 0.1, 2);
}.play;
)
