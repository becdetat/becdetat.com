---
title: FreeRTOS on Arduino
permalink: /freertos-on-arduino
layout: post
date: 2025-11-09
category: post
---

This isn't a beginner's guide to Arduino development or FreeRTOS, it's me learning in the open and sharing my discoveries.

[FreeRTOS](https://www.freertos.org/) is a full RTOS stack for "small" microprocessors. I haven't explored FreeRTOS at all, I'm just using a [fork of FreeRTOS for Arduino ATMEGA](https://github.com/feilipu/Arduino_FreeRTOS_Library).

## Getting cheap AliExpress Arduino Nanos working
First up, I'm using [extremely cheap AliExpress Arduino Nano clones](https://www.aliexpress.com/item/1005008858797002.html). I like them because a) they're extremely cheap, b) they're small so they're good for art projects, and c) I can buy a bunch of them at a time (see "a") and don't really need to worry about releasing the magic smoke. 

For reference my boards use the MEGA328P processor. They don't always have perfect hardware compatibility and need a bit of finessing to work with new versions of the Arduino IDE. I kept getting this error:

```
avrdude: ser_open(): can't set com-state for "\\.\COM4" mega328p
```

I ended up having to go into Device Manager, uninstalling the device, and removing the driver.

![](/images/2025-11-09-freertos-on-arduino/uninstall-device.png)

When I plugged the Nano back in, it was recognised but still didn't let me upload - it gave a different error though so that was progress. I had to set the Arduino IDE to use the "old" bootloader. I guess you get what you pay for.

![](/images/2025-11-09-freertos-on-arduino//select-bootloader.png)

Once this was done I was able to upload "Blink". This exact process might not work with your particular board but it did with mine. I think you've got to set the bootloader every time you open a new sketch.

## Installing and using FreeRTOS on Arduinos
I followed [this guide](https://feilipu.me/2015/11/24/arduino_freertos/) by the developer of the ATMEGA FreeRTOS port, but I'll go through the steps below. I'm using version 2.3.6 of the Arduino IDE so it's a bit different to the guide. First install the library using the library manager in the Arduino IDE.

![](/images/2025-11-09-freertos-on-arduino//install-freertos.png)

The "Blink" sketch becomes:
```cpp
#include <Arduino_FreeRTOS.h>
  
void setup() {
  xTaskCreate(taskBlink, "Blink", 128, NULL, 2, NULL);
}
  
void loop() {
  // Don't do anything here, it's all handled in the tasks for this example
}
  
void taskBlink(void *pvParameters) {
  (void)pvParameters;
  
  pinMode(LED_BUILTIN, OUTPUT);
  
  for (;;) {
    digitalWrite(LED_BUILTIN, HIGH);
    vTaskDelay(1000 / portTICK_PERIOD_MS);
    digitalWrite(LED_BUILTIN, LOW);
    vTaskDelay(1000 / portTICK_PERIOD_MS);
  }
}
```

The arguments for `xTaskCreate` are:
1. The task function (`taskBlink`)
2. A human readable name for the task
3. The stack size for the task
4. Parameters to pass to the task function (`null` for this example)
5. The priority for the task (0 to 3)
6. A handle to the created task (`null` for this example)

In the task we enter an infinite loop. Note that the `delay()` function has been replaced with `vTaskDelay`, which doesn't block other tasks like `delay()` would. I'm thinking of it working like yielding in a thread - but remember these are _tasks_, not threads. The MEGA328P only has one "thread", FreeRTOS is simulating something like a multi-threaded environment.

I'll demonstrate that with a second task that does a fade on an LED attached to pin D9:

```cpp
void taskFade(void *pvParameters) {
  int ledPin = 9;
  int brightness = 0;
  int fadeAmount = 5;
  
  pinMode(ledPin, OUTPUT);
  
  for(;;) {
    analogWrite(ledPin, brightness);
    brightness += fadeAmount;
    
    if (brightness <= 0 || brightness >= 255) {
      fadeAmount = -fadeAmount;
    }
    
    // Delay for 30ms
    vTaskDelay(30 / portTICK_PERIOD_MS);
  }
}
```

The task gets added to `setup()`:
```cpp
void setup() {
  xTaskCreate(taskBlink, "Blink", 128, NULL, 2, NULL);
  xTaskCreate(taskFade, "Fade", 128, NULL, 2, NULL);
}
```

So now we've got two "animations" happening, seemingly independently of each other. To do that in a traditional "single-threaded" loop requires a whole heap of extra code for state management and counting milliseconds.

![](/images/2025-11-09-freertos-on-arduino//blink-and-fade.gif)






