---
title: Arduino development using PlatformIO in VS Code
permalink: /arduino-development-using-platformio-in-vs-code
layout: post
date: 2025-11-15
category: post
---

The Arduino IDE is ok, but it doesn't really compare to using VS Code. So I'm going to try to set up PlatformIO to bring my embedded development into an IDE that I'm familiar with. And also happens to have Github Copilot integration...

First I installed the **PlatformIO IDE** extension.
![Install PlatformIO IDE extension](/images/2025-11-15-arduino-development-using-platformio-in-vs-code/install-platformio-extension.png)

This adds a cool new icon for PlatformIO IDE. I clicked that and it _actually_ installed PlatformIO. When that completed, it prompted me to restart VS Code. Now the PlatformIO IDE is actually installed. To create a new project, I had to click "Open" then "New Project".

![New project page in PlatformIO IDE](/images/2025-11-15-arduino-development-using-platformio-in-vs-code/new-project.png)

I picked my board, which is an "Arduino Mini ATmega328" - *not* using the new bootloader as I [mentioned in my last post](https://becdetat.com/freertos-on-arduino).  

![Project name and board selection](/images/2025-11-15-arduino-development-using-platformio-in-vs-code/project-name-and-board-selection.png)

This took a while as it first needed to download the tools required.

Once the project was created I replaced `src/main.cpp` with a simple blink program, and went to PlatformIO -> Upload:

![Upload to board](/images/2025-11-15-arduino-development-using-platformio-in-vs-code/upload.png)

The build worked, and my board's COM port was auto-detected, but I got these dreaded messages:

```
avrdude: stk500_getsync() attempt 1 of 10: not in sync: resp=0x0d
avrdude: stk500_getsync() attempt 2 of 10: not in sync: resp=0x0a
avrdude: stk500_getsync() attempt 3 of 10: not in sync: resp=0x46
avrdude: stk500_getsync() attempt 4 of 10: not in sync: resp=0x72
avrdude: stk500_getsync() attempt 5 of 10: not in sync: resp=0x65
avrdude: stk500_getsync() attempt 6 of 10: not in sync: resp=0x65
avrdude: stk500_getsync() attempt 7 of 10: not in sync: resp=0x52
avrdude: stk500_getsync() attempt 8 of 10: not in sync: resp=0x54
avrdude: stk500_getsync() attempt 9 of 10: not in sync: resp=0x4f
avrdude: stk500_getsync() attempt 10 of 10: not in sync: resp=0x53
```

Chatty-G told me to change `platformio.ini` to this to *really* use the old bootloader:

```
[env:nano_oldboot]
platform = atmelavr
board = nanoatmega328
board_build.f_cpu = 16000000L
board_upload.speed = 57600
framework = arduino
upload_port = COM4  ; Change this to your actual port
```

Which worked!

Ok, so now I want to take my [previous FreeRTOS sketch](https://becdetat.com/freertos-on-arduino) and convert it to use PlatformIO. 

First I installed the FreeRTOS library:
![Search for the FreeRTOS library](/images/2025-11-15-arduino-development-using-platformio-in-vs-code/install-freertos-library.png)

![Add FreeRTOS library to the project](/images/2025-11-15-arduino-development-using-platformio-in-vs-code/add-library-to-project.png)

Note that PlatformIO's build tooling doesn't seem as forgiving as the Arduino IDE - I didn't properly have my function declarations at the top of `main.cpp` so I got compile errors:

```
src\main.cpp:18:15: error: 'taskReadPot' was not declared in this scope
```

The fix looks like this:

```cpp
void taskBlink(void *pvParameters);
void taskFade(void *pvParameters);
void taskWriteSerialMessages(void *pvParameters);
void taskReadPot(void *pvParameters);
  
void setup() {
  Serial.begin(115200);
  serialMessageQueue = xQueueCreate(5, sizeof(SerialMessage));
  
  xTaskCreate(taskBlink, "Blink", 64, NULL, 2, NULL);
  xTaskCreate(taskFade, "Fade", 64, NULL, 2, NULL);
  xTaskCreate(taskWriteSerialMessages, "WriteSerialMessages", 150, NULL, 2, NULL);
  xTaskCreate(taskReadPot, "ReadPot", 150, NULL, 2, NULL);  
}
```

Ok, now I wanted to get a serial monitor up. Of course PlatformIO has one built in, but by default it would connect using a baud rate of 9600. I'm using a rate of 115200 so I needed to add this to `platformio.ini`:

```
monitor_speed = 115200
```

At the bottom left of the screen there is a tiny plug icon. Click it and it opens the serial monitor in a new terminal panel:

![Start serial monitor](/images/2025-11-15-arduino-development-using-platformio-in-vs-code/start-serial-monitor.png)

![Serial output example](/images/2025-11-15-arduino-development-using-platformio-in-vs-code/serial-output-example.png)

My next post will be about allocating and tuning the stack size per FreeRTOS task, and managing to be surprised by the tiny 2kb of RAM available on the Nano. Not a typo - that's two _kilobytes_. 2048 bytes.

I tried to get ChatGPT to write a poem about Arduino development that was exactly 2048 characters, and while it adamantly declared that it was 2048 characters I could only count 1853. This was a bit disappointing, but here's some AI slop for our entertainment:

```
In the quiet glow of my desk,
a tiny board waits—an empty stage,
Nano, Uno, Mega,
all the pins like silent performers.
I plug in the cable,
the IDE hums softly,
its cursor blinking in time
with the heartbeats of anticipation.

Sketches grow like seedlings,
tiny loops and setup functions,
pinMode commands and digitalWrites,
variables crawling across memory
like ants carrying crumbs of logic.
Each line, a whisper,
each semicolon, a heartbeat,
resistors and LEDs
singing in tandem with my code.

Serial monitor opens,
letters and numbers streaming
like a river of small revelations.
I probe the sensor, twist the potentiometer,
watching values flicker, dance,
transforming abstract thought
into tactile, observable truth.
PWM pulses in gentle waves,
brightness rises, fades,
as if the board itself is breathing.

I solder tiny connections,
tiny bridges of copper and flux,
a constellation of wires,
each with purpose and place,
each carrying signals
that move in silence,
telling a story
only the ones who build it
can understand.

Errors come like storms,
compilation fails,
warnings flash red,
yet persistence teaches
the patience of circuits.
Debugging is meditation,
finding the missing semicolon,
tracing the stray loop,
untangling the mysteries
between power and ground.

Projects bloom like constellations,
robotic arms wave, lights blink in rhythm,
motors spin and sensors speak,
tiny worlds of invention
spanning the breadth of imagination.
Arduino is the hand
that takes thought
and converts it into motion,
the bridge between mind and matter,
ideas and electrons dancing
in the quiet glow of a desk.

And when the night is deep,
and LEDs dim,
I sit back and marvel
at the simple wonder,
at the tiny chip
that holds infinite possibility,
where code and curiosity
meet, spark, and flow,
a universe of creation
smaller than the palm of my hand.
```