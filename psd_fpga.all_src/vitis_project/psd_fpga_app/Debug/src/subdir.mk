################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/config_routines.c \
../src/event.c \
../src/gpio.c \
../src/i2c.c \
../src/main.c \
../src/self_test.c \
../src/str_utils.c \
../src/timer.c \
../src/uart.c 

OBJS += \
./src/config_routines.o \
./src/event.o \
./src/gpio.o \
./src/i2c.o \
./src/main.o \
./src/self_test.o \
./src/str_utils.o \
./src/timer.o \
./src/uart.o 

C_DEPS += \
./src/config_routines.d \
./src/event.d \
./src/gpio.d \
./src/i2c.d \
./src/main.d \
./src/self_test.d \
./src/str_utils.d \
./src/timer.d \
./src/uart.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -I/home/prince/Vivado_projects/Trenz-Projects/psd_fpga_gle_2_oct_2024/psd_fpga.all_src/vitis_project/psd_fpga_platform/export/psd_fpga_platform/sw/psd_fpga_platform/standalone_domain/bspinclude/include -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v11.0 -mno-xl-soft-mul -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


