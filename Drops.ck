fun void recorder()
{
    dac => Gain g => WvOut w => blackhole;
    
    "chuck-session" => w.autoPrefix;
    "special:auto" => w.wavFilename;
    <<<"writing to file: ", w.filename()>>>;

    1 => g.gain;
    null @=> w;
    
    while( true ) 1::second => now;
}

JCRev l_rev => dac.left;
JCRev r_rev => dac.right;
0.1 => l_rev.mix => r_rev.mix;

fun void drop()
{
    Impulse i => BiQuad f => Gain g => Pan2 p;
    p.left => Delay l_del => l_rev;
    p.right => Delay r_del => r_rev;
        
    .99 => f.prad;
    1 => f.eqzs;
    
    150::ms => dur max_delay;
    max_delay * 2 => l_del.max;
    max_delay * 2 => r_del.max;

    Math.random2f(-1, 1) => float pos;
    pos * 0.4 => p.pan;
    max_delay * (1.0 + pos) => l_del.delay;
    max_delay * (1.0 - pos) => r_del.delay;
    
    
    0.07 => float min_gain;
    0.5 => float max_gain;
    Math.random2f(min_gain, max_gain) => float gain;
    gain * (min_gain + (max_gain - min_gain) * (1.0 - Std.fabs(pos))) => g.gain;

    Math.random2f(1000, 2500) => f.pfreq;
    Math.random2f(500, 5000)::ms => dur interval;

    while(true)
    {
        interval => now;
        1.0 => i.next;       
    }
}

fun void bottles()
{
    [0, 2, 3, 5, 7, 8, 10, 12] @=> int scale[];
    [1, 1, 2, 2, 5, 5, 5, 5, 10, 10, 20, 40] @=> int delay[];
    
    BlowBotl b => Envelope benv;
    benv => l_rev;
    benv => r_rev;
 
    200::ms => benv.duration;
    0.1 => b.noiseGain;
    0.8 => benv.gain;
    
    3::minute => dur duration;
    
    now + duration => time end;
    
    (delay[Math.random2(0, delay.cap() - 1)] * 400)::ms => now;
    
    while(now < end)
    {     
        (delay[Math.random2(0, delay.cap() - 1)] * 200)::ms => now;
        1.0 => b.noteOn;
        
        Math.random2(0, 2) * 12 => int oct;
        scale[Math.random2(0, scale.cap() - 1)] + oct => int note;
        Std.mtof(50 + note) => b.freq;
        
        1 => benv.keyOn;
        (Math.random2(1, 4) * 500)::ms => now;        
        1 => benv.keyOff;
    }
    
    (delay[Math.random2(0, delay.cap() - 1)] * 800)::ms => now;
}

spork ~ recorder();

for(0 => int i; i < 5; i++)
{
    spork ~ drop();
}

/*
spork ~ bottles();

while(true)
{
    1::second => now;
}
*/

bottles();