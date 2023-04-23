import serial
#import crcmod
"""
packet_header   = b'\xBA\xCD'   # Packet header
packet_task1    = b'\xA0\x10'   # Edge detection
packet_task2    = b'\xA0\x20'   # Edge enhancement
packet_task3    = b'\xA0\x30'   # Salt & Pepper Noise Filtering
packet_task4    = b'\xA0\x40'   # Histogram Statistics
packet_task5    = b'\xA0\x50'   # Histogram Equalization
packet_task6    = b'\xA0\x60'   # Boundary Extraction

# choose which task you want to test, task1 is selected for default
packet_task     = packet_task1
"""
# choose your encoded image binary file
file = open('C:\\Users\\HP\\Desktop\\arayuz\\asil_resim_bin.bin',"rb")
byte_read = file.read()
file.close()
# Check encoded image length
print(f'Number of bytes in encoded image: {len(byte_read)}')
encoded_packet = byte_read
print(encoded_packet)
"""
# create packet without CRC
encoded_packet = packet_header
encoded_packet += packet_task
encoded_packet += byte_read

# calculate CRC checksum
crc16 = crcmod.mkCrcFun(0x11021,0xFFFF, False, 0x0000)
packet_crc = crc16(encoded_packet)
encoded_crc = packet_crc.to_bytes(2,'big')

# add CRC to the packet
encoded_packet += encoded_crc
# Check packet length
print(f'Number of bytes in transmitted packet: {len(encoded_packet)}')
# Check header, task and CRC
print(f'Header is: {encoded_packet[0:2]}')
print(f'Task is: {encoded_packet[2:4]}')
print(f'CRC is: {encoded_packet[len(encoded_packet)-2:len(encoded_packet)]}')
"""

# it is possible to get error on next line related to permission issues
# "sudo chmod a+rw /dev/ttyUSB1" works, maybe better solutions possible, google it!
ser = serial.Serial('COM6',115200)  # open serial port
ser.write(encoded_packet)                   # transmit packet
ser.close()                                 # close port