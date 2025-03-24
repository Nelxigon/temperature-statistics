Temperature Statistics
===

A small project for a self-built thermometer that saves and evaluates the temperature and humidity of the room.

### Hardware
For this project I used a raspberry pi pico with a DHT11 temperature and humidity sensor connected to pin 3 and a NeoPixel WS2812B RGB LED connected to pin 16, indicating the process (read, write, error). To prevent data loss in case of power outages, this was connected to a power bank, which in turn was connected to the power outlet. However, when plugging the power bank out of the outlet, there is a minor (barely noticable) disruption, causing the RAM to be reset. 

### Software
This device has no network access, therefore it reads the current time from a time file. If there is no time file, it uses the standard input from the variable and creates a new time file with that time. It overwrites the value in the file each second, to account for the minor disruption in the power loss.  

The script messures the temperature and humidity every 5 minutes. Since the sensor isn't the most accurate, the parameters may need to be tweaked a bit.

```rplot.R``` has three different approaches to evaluate the data. I don't remember how that script works and it may need some improvement.

### Set up
1. Upload the micropython script to the rasberry pi pico. This can be done via [Thonny](https://thonny.org/).
2. Create an empty CSV file with the name ```logile.csv```
3. Adjust the time to your current time
4. Let it run continuously for as long as you need
5. Copy the CSV data from the raspberry pi pico and evaluate it with ```rplot.R```

### Results
Here is how the temperature evaluation looked for me after running it for two months:   
![temp-data](https://github.com/user-attachments/assets/513a5d7c-f369-4a73-8bce-207752e304c1)
and here is the humidity evaluation:
![hum-data](https://github.com/user-attachments/assets/bdda4f01-d85b-4bed-bc67-5e9099b38cc6)
