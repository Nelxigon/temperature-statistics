from neopixel import NeoPixel
from machine import Pin
from time import sleep
from time import localtime
import dht
import utime
from machine import RTC   # or import from machine depending on your micropython version
import os

pin_np = 16
n_leds = 1
prev_time = -1

np = NeoPixel(Pin(pin_np, Pin.OUT), n_leds)
sensor = dht.DHT11(Pin(3))
#sensor = dht.DHT22(Pin(22))

# Initialize time tupel
start_time = (2024, 5, 29, 0, 15, 11, 0, 0)

# Try to overwrite it from the safety file (in case of power outage)
try:
    # Indicate Read Operation by Blue Light
    np[0] = (0, 0, 255)
    
    # Open the file and read the contents
    time = open("time","r")
    start_time = time.read()
    time.close()
    
    # Stop Blue Light after Write Operation is done
    np[0] = (0, 0, 0)
    np.write()
    
    # Format the string and turn it into a list
    start_time = start_time.strip("()")
    start_time = start_time.split(", ")
    
    # Turn the string list into an int list
    for i in range(len(start_time)):
        start_time[i] = int(start_time[i])
        
    # Turn the list into a tupel
    start_time = tuple(start_time)
    print(start_time)
# If there has never been a power outage, meaning that it's the first iteration
except OSError:
    print("No time backup available. Setting standard time!")

# Set the Start Time
rtc = RTC()
rtc.datetime(start_time)    
current_time = utime.localtime()

# Endless loop, ends on signal
while True:
    #Get the current time
    current_time = utime.localtime()
    
    #Save the current time in case of power outages
    time = open("time", "w")
    try:
        # Format the time properly and write it to a file
        write_time = (current_time[0], current_time[1], current_time[2], 0, current_time[3], current_time[4], current_time[5], 0)
        time.write(str(write_time))
    except OSError:
        print("Disk full?")
        # Flash White for Full Disk
        np[0] = (255, 0, 0)
    time.close()
    
    # Activate every 5 minutes, once per minute
    if (current_time[4] % 5 == 0 and prev_time != current_time[4]):
        prev_time = current_time[4]
        try:
            #Format the current time as "dd/mm/yyyy HH:MM"
            formatted_date = "{:02d}/{:02d}/{}".format(current_time[2], current_time[1], current_time[0])
            formatted_time = "{:02d}:{:02d}:{:02d}".format(current_time[3], current_time[4], current_time[5])
            # Measure the temperature and humidity
            sensor.measure()
            # Save and correct the values
            temp = sensor.temperature() - 2
            hum = sensor.humidity() + 5
            # Print the Information
            print('Temperature: %3.0f C' %temp)
            print('Humidity: %3.0f %%' %hum)
            print('Date: ' + formatted_date)
            print('Time: ' + formatted_time)
            # Open the CSV file
            logf = open("logfile.csv","a")
            # Try to access filesystem
            try:
                # Indicate Write Operation by Green Light
                np[0] = (0, 255, 0)
                np.write()
                # Write Data to CSV File
                logf.write(str(formatted_date))
                logf.write(",")
                logf.write(formatted_time)
                logf.write(",")
                logf.write(str(temp))
                logf.write(",")
                logf.write(str(hum))
                logf.write("\r\n")
                # Stop Green Light after Write Operation is done
                np[0] = (0, 0, 0)
                np.write()
            except OSError:
                print("Disk full?")
                # Flash White for Full Disk
                np[0] = (255, 0, 0)
            logf.close()
        except OSError as e:
            print('Failed to read sensor.')


