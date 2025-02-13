
// *************************************************
// localparams definitions for the gpio bits   
// The file is AUTO-GENERATED, DO NOT MODIFY!!!   
// Timestamp:           Mon Feb 10 17:23:47 CST 2025
// TCL Code Version:    v0.0.7 released at	2025-01-27 20:45:56
// *************************************************

// GPIO INPUT Port 0 -> Board ID bit 0 (input pin)
localparam	BOARD_ID_0 = 0 ;

// GPIO INPUT Port 0 -> Board ID bit 1 (input pin)
localparam	BOARD_ID_1 = 1 ;

// GPIO INPUT Port 0 -> Board ID bit 2 (input pin)
localparam	BOARD_ID_2 = 2 ;

// GPIO INPUT Port 0 -> Board ID bit 3 (input pin)
localparam	BOARD_ID_3 = 3 ;

// GPIO INPUT Port 0 -> Board ID bit 4 (input pin)
localparam	BOARD_ID_4 = 4 ;

// GPIO INPUT Port 0 -> Board ID bit 5 (input pin)
localparam	BOARD_ID_5 = 5 ;

// GPIO INPUT Port 0 -> Common stop signal from host (input pin)
localparam	COMMON_STOP = 6 ;

// GPIO INPUT Port 0 -> Global enable signal from host (input pin)
localparam	GLOB_ENA = 7 ;

// GPIO INPUT Port 0 -> Event enable signal from host (input pin)
localparam	EVENT_ENA = 8 ;

// GPIO INPUT Port 0 -> Force reset signal from the host (input pin)
localparam	FORCE_RESET = 9 ;

// GPIO INPUT Port 0 -> Take event signal from the host (input pin)
localparam	TAKE_EVENT = 10 ;

// GPIO OUTPUT Port 0 -> 2-bit code used to select which OR we use
localparam	OR_SEL_0 = 0 ;

// GPIO OUTPUT Port 0 -> 00 is PSD0 OR ; 01 is PSD1 OR ; 11 for both PSD Ors; 10 is the CFD chip OR
localparam	OR_SEL_1 = 1 ;

// GPIO OUTPUT Port 0 -> Select cfd output from either 0- PSD0 or 1– PSD1
localparam	CFD_OUT_SEL = 2 ;

// GPIO OUTPUT Port 0 -> Route out intx from either PSD 0 or PSD1 to host
localparam	PSD_INTX_OUT_SEL = 3 ;

// GPIO INPUT Port 1 -> PSD 0 channel address input bit 0
localparam	PSD0_CHAN_ADDR_IN_0 = 0 ;

// GPIO INPUT Port 1 -> PSD 0 channel address input bit 1
localparam	PSD0_CHAN_ADDR_IN_1 = 1 ;

// GPIO INPUT Port 1 -> PSD 0 channel address input bit 2
localparam	PSD0_CHAN_ADDR_IN_2 = 2 ;

// GPIO INPUT Port 1 -> PSD 0 channel address input bit 3
localparam	PSD0_CHAN_ADDR_IN_3 = 3 ;

// GPIO INPUT Port 1 -> PSD 0 channel address input bit 4
localparam	PSD0_CHAN_ADDR_IN_4 = 4 ;

// GPIO INPUT Port 1 -> PSD 1 channel address input bit 0
localparam	PSD1_CHAN_ADDR_IN_0 = 5 ;

// GPIO INPUT Port 1 -> PSD 1 channel address input bit 1
localparam	PSD1_CHAN_ADDR_IN_1 = 6 ;

// GPIO INPUT Port 1 -> PSD 1 channel address input bit 2
localparam	PSD1_CHAN_ADDR_IN_2 = 7 ;

// GPIO INPUT Port 1 -> PSD 1 channel address input bit 3
localparam	PSD1_CHAN_ADDR_IN_3 = 8 ;

// GPIO INPUT Port 1 -> PSD 1 channel address input bit 4
localparam	PSD1_CHAN_ADDR_IN_4 = 9 ;

// GPIO OUTPUT Port 1 -> PSD 0 channel address input bit 0
localparam	PSD0_CHAN_ADDR_OUT_0 = 0 ;

// GPIO OUTPUT Port 1 -> PSD 0 channel address input bit 1
localparam	PSD0_CHAN_ADDR_OUT_1 = 1 ;

// GPIO OUTPUT Port 1 -> PSD 0 channel address input bit 2
localparam	PSD0_CHAN_ADDR_OUT_2 = 2 ;

// GPIO OUTPUT Port 1 -> PSD 0 channel address input bit 3
localparam	PSD0_CHAN_ADDR_OUT_3 = 3 ;

// GPIO OUTPUT Port 1 -> PSD 0 channel address input bit 4
localparam	PSD0_CHAN_ADDR_OUT_4 = 4 ;

// GPIO OUTPUT Port 1 -> PSD 1 channel address input bit 0
localparam	PSD1_CHAN_ADDR_OUT_0 = 5 ;

// GPIO OUTPUT Port 1 -> PSD 1 channel address input bit 1
localparam	PSD1_CHAN_ADDR_OUT_1 = 6 ;

// GPIO OUTPUT Port 1 -> PSD 1 channel address input bit 2
localparam	PSD1_CHAN_ADDR_OUT_2 = 7 ;

// GPIO OUTPUT Port 1 -> PSD 1 channel address input bit 3
localparam	PSD1_CHAN_ADDR_OUT_3 = 8 ;

// GPIO OUTPUT Port 1 -> PSD 1 channel address input bit 4
localparam	PSD1_CHAN_ADDR_OUT_4 = 9 ;

// GPIO OUTPUT Port 1 -> Global enable signal from ublaze to psd chips
localparam	PSD_GLOBAL_ENABLE = 10 ;

// GPIO OUTPUT Port 1 -> Force a reset on both psd chips
localparam	PSD_FORCE_RST = 11 ;

// GPIO OUTPUT Port 1 -> Veto reset signal into PSD chips i.e. take_event
localparam	PSD_VETO_RESET = 12 ;

// GPIO OUTPUT Port 1 -> Digial reset for PSD chip
localparam	PSD_RESET = 13 ;

// GPIO INPUT Port 2 -> Serial output from PSD 1 config register (input pin)
localparam	PSD_SOUT = 0 ;

// GPIO OUTPUT Port 2 -> Busy out signal to busy tri-state circuits
localparam	BUSY_OUT = 0 ;

// GPIO OUTPUT Port 2 -> Serial data into the delay ICs (output pin)
localparam	DELAY_DATA = 1 ;

// GPIO OUTPUT Port 2 -> Clock for the delay ICs (output pin)
localparam	DELAY_CLK = 2 ;

// GPIO OUTPUT Port 2 -> Serial enable (active LOW) for delay chip #0 (output pin)
localparam	DELAY_EN_L_0 = 3 ;

// GPIO OUTPUT Port 2 -> Serial enable (active LOW) for delay chip #1 (output pin)
localparam	DELAY_EN_L_1 = 4 ;

// GPIO OUTPUT Port 2 -> Serial enable (active LOW) for delay chip #2 (output pin)
localparam	DELAY_EN_L_2 = 5 ;

// GPIO OUTPUT Port 2 -> Serial enable (active LOW) for delay chip #3 (output pin)
localparam	DELAY_EN_L_3 = 6 ;

// GPIO OUTPUT Port 2 -> Serial enable (active LOW) for delay chip #4 (output pin)
localparam	DELAY_EN_L_4 = 7 ;

// GPIO OUTPUT Port 2 -> Serial enable (active LOW) for delay chip #5 (output pin)
localparam	DELAY_EN_L_5 = 8 ;

// GPIO OUTPUT Port 2 -> Delay chip amplifer setting 0 
localparam	DELAY_X2 = 9 ;

// GPIO OUTPUT Port 2 -> Test MUX enable (output pin)
localparam	MUX_EN = 10 ;

// GPIO OUTPUT Port 2 -> Test MUX select bit 0 (output pin)
localparam	MUX_SEL_0 = 11 ;

// GPIO OUTPUT Port 2 -> Test MUX select bit 1 (output pin)
localparam	MUX_SEL_1 = 12 ;

// GPIO OUTPUT Port 2 -> Test MUX select bit 2 (output pin)
localparam	MUX_SEL_2 = 13 ;

// GPIO OUTPUT Port 2 -> Test MUX select bit 3 (output pin)
localparam	MUX_SEL_3 = 14 ;

// GPIO OUTPUT Port 2 -> Octal DAC load signal (output pin)
localparam	DAC_LD = 15 ;

// GPIO OUTPUT Port 2 -> Octal DAC serial clock (output pin)
localparam	DAC_SCLK = 16 ;

// GPIO OUTPUT Port 2 -> Octal DAC serial input (output pin)
localparam	DAC_DIN = 17 ;

// GPIO OUTPUT Port 2 -> PSD chip 0 DAC strobe (output pin)
localparam	PSD_DAC_STB_0 = 18 ;

// GPIO OUTPUT Port 2 -> PSD chip 1 DAC strobe (output pin)
localparam	PSD_DAC_STB_1 = 19 ;

// GPIO OUTPUT Port 2 -> ACQ all to both PSD chips (output pin)
localparam	PSD_ACQ_ALL = 20 ;

// GPIO OUTPUT Port 2 -> Selects cfd-bypass mode for PSDs (output pin)
localparam	PSD_CFD_BYPASS = 21 ;

// GPIO OUTPUT Port 2 -> Serial input  into PSD 0 (output pin)
localparam	PSD_SIN = 22 ;

// GPIO OUTPUT Port 2 -> Serial clock into PSD 0 and 1 (output pin)
localparam	PSD_SCLK = 23 ;

// GPIO OUTPUT Port 2 -> PSD chip 0 address direction selection line
localparam	PSD_SEL_EXT_ADDR_0 = 24 ;

// GPIO OUTPUT Port 2 -> PSD chip 1 address direction selection line
localparam	PSD_SEL_EXT_ADDR_1 = 25 ;

// GPIO OUTPUT Port 2 -> PSD chip 0 sub channel select bit 0
localparam	PSD_SC0_0 = 26 ;

// GPIO OUTPUT Port 2 -> PSD chip 0 sub channel select bit 1
localparam	PSD_SC1_0 = 27 ;

// GPIO OUTPUT Port 2 -> PSD chip 1 sub channel select bit 0
localparam	PSD_SC0_1 = 28 ;

// GPIO OUTPUT Port 2 -> PSD chip 1 sub channel select bit 1
localparam	PSD_SC1_1 = 29 ;

// GPIO OUTPUT Port 2 -> PSD 0 select test mode
localparam	PSD_TEST_MODE_INT_0 = 30 ;

// GPIO OUTPUT Port 2 -> PSD 1 select test mode
localparam	PSD_TEST_MODE_INT_1 = 31 ;

// GPIO INPUT Port 3 -> Bit 0 of cfd_ad_in bus from the cfd_ad tri-state circuits
localparam	CFD_AD_IN_0 = 0 ;

// GPIO INPUT Port 3 -> Bit 1 of cfd_ad_in bus from the cfd_ad tri-state circuits
localparam	CFD_AD_IN_1 = 1 ;

// GPIO INPUT Port 3 -> Bit 2 of cfd_ad_in bus from the cfd_ad tri-state circuits
localparam	CFD_AD_IN_2 = 2 ;

// GPIO INPUT Port 3 -> Bit 3 of cfd_ad_in bus from the cfd_ad tri-state circuits
localparam	CFD_AD_IN_3 = 3 ;

// GPIO INPUT Port 3 -> Bit 4 of cfd_ad_in bus from the cfd_ad tri-state circuits
localparam	CFD_AD_IN_4 = 4 ;

// GPIO INPUT Port 3 -> Bit 5 of cfd_ad_in bus from the cfd_ad tri-state circuits
localparam	CFD_AD_IN_5 = 5 ;

// GPIO INPUT Port 3 -> Bit 6 of cfd_ad_in bus from the cfd_ad tri-state circuits
localparam	CFD_AD_IN_6 = 6 ;

// GPIO INPUT Port 3 -> Bit 7 of cfd_ad_in bus from the cfd_ad tri-state circuits
localparam	CFD_AD_IN_7 = 7 ;

// GPIO OUTPUT Port 3 -> Bit 0 of cfd_ad_out bus from the cfd_ad tri-state circuits
localparam	CFD_AD_OUT_0 = 0 ;

// GPIO OUTPUT Port 3 -> Bit 1 of cfd_ad_out bus from the cfd_ad tri-state circuits
localparam	CFD_AD_OUT_1 = 1 ;

// GPIO OUTPUT Port 3 -> Bit 2 of cfd_ad_out bus from the cfd_ad tri-state circuits
localparam	CFD_AD_OUT_2 = 2 ;

// GPIO OUTPUT Port 3 -> Bit 3 of cfd_ad_out bus from the cfd_ad tri-state circuits
localparam	CFD_AD_OUT_3 = 3 ;

// GPIO OUTPUT Port 3 -> Bit 4 of cfd_ad_out bus from the cfd_ad tri-state circuits
localparam	CFD_AD_OUT_4 = 4 ;

// GPIO OUTPUT Port 3 -> Bit 5 of cfd_ad_out bus from the cfd_ad tri-state circuits
localparam	CFD_AD_OUT_5 = 5 ;

// GPIO OUTPUT Port 3 -> Bit 6 of cfd_ad_out bus from the cfd_ad tri-state circuits
localparam	CFD_AD_OUT_6 = 6 ;

// GPIO OUTPUT Port 3 -> Bit 7 of cfd_ad_out bus from the cfd_ad tri-state circuits
localparam	CFD_AD_OUT_7 = 7 ;

// GPIO OUTPUT Port 3 -> CFD chip strobe (output pin)
localparam	CFD_STB = 8 ;

// GPIO OUTPUT Port 3 -> CFD write (output pin)
localparam	CFD_WRITE = 9 ;

// GPIO OUTPUT Port 3 -> When high select negative pulses (output pin)
localparam	CFD_NEG_POL = 10 ;

// GPIO OUTPUT Port 3 -> Resets CFD chip (output pin)
localparam	CFD_RESET = 11 ;

// GPIO OUTPUT Port 3 -> CFD global enable (output pin)
localparam	CFD_GLOBAL_ENA = 12 ;


