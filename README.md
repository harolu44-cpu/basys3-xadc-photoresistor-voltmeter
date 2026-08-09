# basys3-xadc-photoresistor-voltmeter
Designed a VHDL based FPGA voltmeter using the XC7A35T XADC to sample a photoresistor voltage divider circuit then converted the 12-bit ADC measurements into millivolts. Applied a 16 sample averaging filter for display stability and shows this voltage readings on a 7-segment display. Measurements were validated against a digital multimeter.

Tools: VHDL, Vivado, XADC, sourcetree

Demo- https://youtube.com/shorts/ZjS7KwpbWkc?si=Oeiirqwa2CuMr34I
The FPGA voltage measurement filtered and unfiltered is compared against a conventional digital
multimeter to verify the XADC measurement and if the 16 sample filter makes a difference in the measurements.

Features
- Analog voltage acquisition using the Xilinx 7-Series XADC
- Photoresistor voltage-divider input
- 12-bit ADC sampling
- VHDL-based voltage conversion logic
- Real-time four-digit seven-segment display
- Onboard LED output for ADC visualization
- Implemented and tested on a Basys 3 FPGA board
- Optional 16-sample averaging filter for display stabilization
- Vivado XDC constraints for clock, XADC input, LEDs, anodes, segments, and decimal point

Architecture:
Photoresistor Circuit -> Basys 3 XADC pins -> 12-bit data -> 16 sample filter -> voltage conversion -> 7-segment Display

Design Approach:
The design first reads the analog voltage from the photoresistor voltage divider using the Basys 3 XADC input. The XADC provides a 12-bit digital sample from 0 to 4095, where 0 represents approximately 0 Volts and 4095 represents approximately 1 Volt. The raw ADC sample is then passed through a 16 sample averaging filter. This is meant to reduce small reading changes caused by analog noise and makes the displayed voltage more stable. After filtering, the ADC value is converted from counts to millivolts. Since the XADC input range is approximately 0–1.0 Volt, the design scales the 0–4095 ADC range into 0–1000 mV we can get this from this equation: mv_value <= ((to_integer(adc_filtered) * 1000) + 2047) / 4095; In this equation adc_filtered is the averaged 12 bit ADC value then we multiplying this by 1000 which converts the reading into millivolts and dividing by 4095 scales it to the XADC input range. The added 2047 is used for rounding so the displayed voltage is closer to the actual measured value.


Equipment: Basys 3, digital multimeter, jumper wires, breadboard, GL5528 photoresistor, 10kΩ and 1kΩ 

How to Run
- In sourcetree select clone then paste the GitHub repository URL after this choose a local folder and click clone.
- In the Vivado tcl Console write cd C:/Users/YourName/Documents/GitHub/basys3-xadc-photoresistor-voltmeter then press enter after this write source ./tcl/create_project.tcl and press enter again.
