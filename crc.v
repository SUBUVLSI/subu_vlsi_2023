// CRC polynomial coefficients: x^16 + x^12 + x^5 + 1
//                              0x1021 (hex)
// CRC width:                   16 bits
// CRC shift direction:         left (big endian)
// Input word width:            8 bits

function automatic [15:0] crc;
    input [15:0] crcIn;
    input [7:0] data;
begin
    crc[0] = (crcIn[8] ^ crcIn[12] ^ data[0] ^ data[4]);
    crc[1] = (crcIn[9] ^ crcIn[13] ^ data[1] ^ data[5]);
    crc[2] = (crcIn[10] ^ crcIn[14] ^ data[2] ^ data[6]);
    crc[3] = (crcIn[11] ^ crcIn[15] ^ data[3] ^ data[7]);
    crc[4] = (crcIn[12] ^ data[4]);
    crc[5] = (crcIn[8] ^ crcIn[12] ^ crcIn[13] ^ data[0] ^ data[4] ^ data[5]);
    crc[6] = (crcIn[9] ^ crcIn[13] ^ crcIn[14] ^ data[1] ^ data[5] ^ data[6]);
    crc[7] = (crcIn[10] ^ crcIn[14] ^ crcIn[15] ^ data[2] ^ data[6] ^ data[7]);
    crc[8] = (crcIn[0] ^ crcIn[11] ^ crcIn[15] ^ data[3] ^ data[7]);
    crc[9] = (crcIn[1] ^ crcIn[12] ^ data[4]);
    crc[10] = (crcIn[2] ^ crcIn[13] ^ data[5]);
    crc[11] = (crcIn[3] ^ crcIn[14] ^ data[6]);
    crc[12] = (crcIn[4] ^ crcIn[8] ^ crcIn[12] ^ crcIn[15] ^ data[0] ^ data[4] ^ data[7]);
    crc[13] = (crcIn[5] ^ crcIn[9] ^ crcIn[13] ^ data[1] ^ data[5]);
    crc[14] = (crcIn[6] ^ crcIn[10] ^ crcIn[14] ^ data[2] ^ data[6]);
    crc[15] = (crcIn[7] ^ crcIn[11] ^ crcIn[15] ^ data[3] ^ data[7]);
end
endfunction