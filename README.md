# Sunflower-FPGA-Light-Optimizer
Created by June Lin and Victoria Jiang
The “Sunflower” project uses a DE1-SoC FPGA to control a motorized solar panel that adjusts its position to maximize light exposure. 
Uses an ESP32 module to measure voltage and convert to a 12-bit binary input to the FPGA board.
The brighter the light, the stronger the voltage, thus the FPGA detects the position of maximize light exposure according to the binary input.
