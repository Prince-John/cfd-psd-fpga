//
///////////////////////////////////////////////////////////////////////////////////////////
// Copyright � 2010-2013, Xilinx, Inc.
// This file contains confidential and proprietary information of Xilinx, Inc. and is
// protected under U.S. and international copyright and other intellectual property laws.
///////////////////////////////////////////////////////////////////////////////////////////
//
// Disclaimer:
// This disclaimer is not a license and does not grant any rights to the materials
// distributed herewith. Except as otherwise provided in a valid license issued to
// you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
// MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
// DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
// INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
// OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
// (whether in contract or tort, including negligence, or under any other theory
// of liability) for any loss or damage of any kind or nature related to, arising
// under or in connection with these materials, including for any direct, or any
// indirect, special, incidental, or consequential loss or damage (including loss
// of data, profits, goodwill, or any type of loss or damage suffered as a result
// of any action brought by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-safe, or for use in any
// application requiring fail-safe performance, such as life-support or safety
// devices or systems, Class III medical devices, nuclear facilities, applications
// related to the deployment of airbags, or any other applications that could lead
// to death, personal injury, or severe property or environmental damage
// (individually and collectively, "Critical Applications"). Customer assumes the
// sole risk and liability of any use of Xilinx products in Critical Applications,
// subject only to applicable laws and regulations governing limitations on product
// liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//
// Production definition of a 1K program for KCPSM6 in a 7-Series device using a 
// RAMB18E1 primitive.
//
// Note: The complete 12-bit address bus is connected to KCPSM6 to facilitate future code 
//       expansion with minimum changes being required to the hardware description. 
//       Only the lower 10-bits of the address are actually used for the 1K address range
//       000 to 3FF hex.  
//
// Program defined by '{psmname}.psm'.
//
// Generated by KCPSM6 Assembler: 2025-04-03T17:36:09. 
//
// Assembler used ROM_form template: ROM_form_7S_1K_14March13.v
//
//
module pico_program (
input  [11:0] address,
output [17:0] instruction,
input         enable,
input         clk);
//
//
wire [13:0] address_a;
wire [17:0] data_in_a;
wire [17:0] data_out_a;
wire [13:0] address_b;
wire [17:0] data_in_b;
wire [17:0] data_out_b;
wire        enable_b;
wire        clk_b;
wire [3:0]  we_b;
//
//
assign address_a = {address[9:0], 4'b1111};
assign instruction = data_out_a[17:0];
assign data_in_a = {16'h0000, address[11:10]};
//
assign address_b = 14'b11111111111111;
assign data_in_b = data_out_b[17:0];
assign enable_b = 1'b0;
assign we_b = 4'h0;
assign clk_b = 1'b0;
//
// 
RAMB18E1 # ( .READ_WIDTH_A              (18),
             .WRITE_WIDTH_A             (18),
             .DOA_REG                   (0),
             .INIT_A                    (16'b000000000000000000),
             .RSTREG_PRIORITY_A         ("REGCE"),
             .SRVAL_A                   (36'h000000000000000000),
             .WRITE_MODE_A              ("WRITE_FIRST"),
             .READ_WIDTH_B              (18),
             .WRITE_WIDTH_B             (18),
             .DOB_REG                   (0),
             .INIT_B                    (36'h000000000000000000),
             .RSTREG_PRIORITY_B         ("REGCE"),
             .SRVAL_B                   (36'h000000000000000000),
             .WRITE_MODE_B              ("WRITE_FIRST"),
             .INIT_FILE                 ("NONE"),
             .SIM_COLLISION_CHECK       ("ALL"),
             .RAM_MODE                  ("TDP"),
             .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
             .SIM_DEVICE                ("7SERIES"),
             .INIT_00                   (256'h1B001A001900180017001600150014001300120011001000F20092011F3F2157),
             .INIT_01                   (256'h1C00D006D0055040D601367FD6015680002ADB045B40D203D202D2001D001C00),
             .INIT_02                   (256'h5000DB043BF70025DB045B085000DB043BDFDB045B20500000366024B200DC07),
             .INIT_03                   (256'h6B201220DB045B1050000062005010011D4100305000DB045B8000AEDB043B7F),
             .INIT_04                   (256'h5000DB045B405000DB043BBF5000DB043BEF603F9401DB046B200EE00EE0DB04),
             .INIT_05                   (256'h003C1410004ADB043BFD0025DB045B02D003DB043BFB0025DB045B04DD03002A),
             .INIT_06                   (256'h004ADB043BFB0025DB045B04DD03002A5000005010011D402067B2005000004D),
             .INIT_07                   (256'h5C04D0021050D2FE2079D1019100DC073CFB5C08D00210405000004D003C1420),
             .INIT_08                   (256'h208DD101910000681D10DC073CF7D0021090D2FE60A8B2002081D1019100DC07),
             .INIT_09                   (256'h209DD101910000681D1BD00210D0D2FE2095D101910000681D11D00210A0D2FE),
             .INIT_0A                   (256'h950115185000DA003ABFD2FFDA005A4020A5D101910000681D1CD00210E0D2FE),
             .INIT_0B                   (256'h0EE00EE06670D60166701410D601668000AE00AED60106809F01E4F0500060AF),
             .INIT_0C                   (256'h4D0E4D0E9F01E1F09F01E0F09F01E4F0DA005A045000A4F01F0160BB9401D601),
             .INIT_0D                   (256'h40060040D00240204206420642064206024000D0130120D6DD08130014004D0E),
             .INIT_0E                   (256'h1401D0FEDA003AF720E7D1019100DA005A08D001504020E6D301400640064006),
             .INIT_0F                   (256'h16001900DC073CF73CFBDA005A025000A4F01F01A0F01F01A1F01F0160D6D404),
             .INIT_10                   (256'h2131D9032121D9022111D9012148D90059022108D101910359012104D1019102),
             .INIT_11                   (256'h60FED1029102D00530F700C69D0200B21804170100AED0055008D00510002110),
             .INIT_12                   (256'h60FED1029103D00630F700C6910300B21808170200AED0065008D00610002148),
             .INIT_13                   (256'h30F700C6960300C6960200B2180C170300AED006D0055008D006D00510002148),
             .INIT_14                   (256'h0074DA005A20D006D0055040DA005A1060FED102910360FED1029102D006D005),
             .INIT_15                   (256'hDC073CEF5C02215AD1029100DA005A0100015000DA003AFDDA003AEF3ADF3AFB),
             .INIT_16                   (256'h00002158DC073CFE0EE00EE0DC075C01D0073CFD6163D102910000F9DA003AFE),
             .INIT_17                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_18                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000009000),
             .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3F                   (256'h2380000000000000000000000000000000000000000000000000000000000000),
             .INITP_00                  (256'h22C208A8A28AA0CA8A28A28AA28A360208A82A28A28A22B22888A2A000000082),
             .INITP_01                  (256'h0822111D68C2231548550301566688760208A86B4A28C222C222C222C2222CC2),
             .INITP_02                  (256'h0000000028088C288308A880A288C30A2220A8A2C2220A22C2220A22DDDD3030),
             .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INITP_07                  (256'h8000000000000000000000000000000000000000000000000000000000000002))
 kcpsm6_rom( .ADDRARDADDR               (address_a),
             .ENARDEN                   (enable),
             .CLKARDCLK                 (clk),
             .DOADO                     (data_out_a[15:0]),
             .DOPADOP                   (data_out_a[17:16]), 
             .DIADI                     (data_in_a[15:0]),
             .DIPADIP                   (data_in_a[17:16]), 
             .WEA                       (2'b00),
             .REGCEAREGCE               (1'b0),
             .RSTRAMARSTRAM             (1'b0),
             .RSTREGARSTREG             (1'b0),
             .ADDRBWRADDR               (address_b),
             .ENBWREN                   (enable_b),
             .CLKBWRCLK                 (clk_b),
             .DOBDO                     (data_out_b[15:0]),
             .DOPBDOP                   (data_out_b[17:16]), 
             .DIBDI                     (data_in_b[15:0]),
             .DIPBDIP                   (data_in_b[17:16]), 
             .WEBWE                     (we_b),
             .REGCEB                    (1'b0),
             .RSTRAMB                   (1'b0),
             .RSTREGB                   (1'b0));
//
//
endmodule
//
////////////////////////////////////////////////////////////////////////////////////
//
// END OF FILE pico_program.v
//
////////////////////////////////////////////////////////////////////////////////////
