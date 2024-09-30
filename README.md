
# StreamPhoneData

本仓库利用手机6轴（3轴加速度+3轴陀螺仪）来实时解算手机方位角！

## 历史记录

1. 2024.9.29 加入了低通butterworth滤波算法，即Mathworks官方示例代码<https://ww2.mathworks.cn/matlabcentral/fileexchange/48954-matlab-to-iphone-made-easy-example-files>，注意该代码只有利用3轴加速度滤波，并没有利用陀螺仪等传感器数据！
1. 2024.9.30 应该使用`imufilter`对6轴传感器数据做姿态解算（理论上能得到roll,pitch,tilt,不能得到yaw，参考文献3），因为其融合了间接卡尔曼滤波器算法，而`ahrsfilter`则是对9轴传感器数据做姿态解算，根据参考文献3的PDF文档SensorFusionDatasheet.pdf如下所述：

| Feature                          | Accel Only | Accel + Gyro | Accel + Mag | Accel + Mag + Gyro |  
|----------------------------------|------------|--------------|-------------|---------------------|  
| Filter type                      | Low pass   | Indirect  Kalman    |  Low pass(1)    | Indirect Kalman           |  
| Roll / Pitch / Tilt in degrees   | Yes        | Yes          | Yes         | Yes                 |  
| Yaw in degrees                   | No         | No           | Yes         | Yes                 |  
| Angular rate in degrees/second   | virtual 2 axis | Yes      | virtual 3 axis | Yes                 |  
| Compass heading (magnetic north) | No         | No           | Yes         | Yes                 |

1. More precisely: a non-linear modified exponential low pass quaternion SLERP filter

官方示例“Estimate Phone Orientation Using Sensor Fusion”较好，已经修改使用`imufilter`，初步也可以估计位姿，待继续调查使用。

## 原始作者的

feel free to cite this code using the doi;
[![DOI](https://zenodo.org/badge/90114835.svg)](https://zenodo.org/badge/latestdoi/90114835)

Some matlab scripts to stream the data from the sensors (accelerometers, gyroscopes, GPS, and whatever more your phone may have) in your smartphone (Android or Iphone) to Matlab

## Requirements

MathWorks Products(<www.mathworks.com>)

- MATLAB®
- Instrument Control Toolbox™ ([udpport](https://www.mathworks.com/help/instrument/udpport.html) build-in function）

## How to get started

To use this software:

1. Download the measurement software; for android, download ‘IMU+GPS-Stream’; for Iphone/Ipad, download ‘Sensorlog’ (by Bernd Thomas).
2. If you have an Iphone/Ipad, open your Sensorlog, click the settings icon. In the settings, in the “log data to” select “socket”. In the lower tab, make sure that only “accelerator” (ACC) and “gyroscope” (GYR) are switched on. Also, fully at the bottom, make sure that “fill missing data with previous sample” is switched on. (see screenshots in screenshots apple folder)
3. Connect with both your phone and laptop to the same Wifi network.
4. Open the MainExample file. Since this program is written for different devices, you should now uncomment the appropriate lines (see comments in the script). You have to do this BOTH at the beginning of the script, and in the middle somewhere.
5. For android: You can now run this script. This Matlab script will open up a connection, and display an IP address on which it can be reached. This IP address (the address on which your computer can be reached) should start with 192. If you are at a network that does not use the 192. addresses, change the IpAdress in the script. Input the Ip adress in your phone, as well as the port (50000). Also, to avoid problems, make sure to check the "run in background". As soon as you switch the stream to on, you should see your accelerometer data in Matlab
6. FOR IPHONE in the block of code you just uncommented, it also says:
IpAdress='192.168.1.72';
Port=61904;
Change these values to the values you see in the main screen of the sensorlog app, bottom right (it reads as 192.168.1.72: 61904) on your phone. Next, you can click the “play” button in the lower left of the screen. Now you can run the Matlab script. You should see the accelerometer from your phone in a Matlab graph.

- If no data do appear in the figure, there is probably a problem with your connection. Press Ctrl+C to break the program, turn of any virus scanning or security software and turn off the built in firewall of your operating system (for windows: <https://support.microsoft.com/en-us/help/17228/windows-protect-my-pc-from-viruses>), (for mac: <http://www.wikihow.com/Turn-off-Mac-Firewall>), and try again.

## References

1. <https://ww2.mathworks.cn/matlabcentral/fileexchange?q=AHRS>
1. <https://ww2.mathworks.cn/matlabcentral/fileexchange/63149-virtual-reality-drawing-with-android-device?s_tid=srchtitle>
1. <https://github.com/memsindustrygroup/Open-Source-Sensor-Fusion/tree/master/docs>
