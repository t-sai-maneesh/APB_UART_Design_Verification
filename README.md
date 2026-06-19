# APB UART Design and UVM Verification

## Project Overview

This project implements and verifies an APB-based UART controller using Verilog, SystemVerilog, and UVM.

The APB UART core acts as the Device Under Test (DUT). It interfaces with the APB bus for register configuration and performs UART serial data transmission and reception.

The verification environment uses two independent UVM agents:

* APB Agent: Configures and controls the UART core through APB register accesses.
* UART Agent: Acts as an external UART device that transmits serial data to the DUT or receives serial data from the DUT.

## Design Features

* APB Slave Interface
* UART Transmitter
* UART Receiver
* Register File
* FIFO Support
* Interrupt Generation
* Configurable UART Operation

## Verification Architecture

### TB Architecture
<img width="1000" height="1112" alt="Your paragraph text" src="https://github.com/user-attachments/assets/43bea023-93d7-4312-a2ce-fbdc9ec842d2" />

### APB Agent

The APB Agent drives APB transactions to the UART core and performs:

* Register Read Operations
* Register Write Operations
* UART Configuration
* Interrupt Enable/Disable Configuration
* FIFO Configuration

Components:

* APB Sequencer
* APB Driver
* APB Monitor

### UART Agent

The UART Agent represents an external UART device connected to the DUT.

Functions:

* Sends serial data to the UART Receiver inside the DUT
* Receives serial data from the UART Transmitter inside the DUT
* Monitors UART protocol behavior

Components:

* UART Sequencer
* UART Driver
* UART Monitor

### Verification Components

* Environment
* Scoreboard
* Functional Coverage
* Assertions
* Virtual Sequences

## Test Scenarios

### Normal Test Scenarios
* Half_Duplex - Sending from the DUT
* Half_Duplex - Recieving to the DUT
* Full_Duplex - Sending and recieving
* LoopBack Mode - Checking whether it can send and recieve

### Error Test Scenarios
* Parity Error - Checking for the data mismatch
* Framing Error - checking for the stop bit 
* Break Error - If the reciver pin is low for one character frame
* Overrun Error - checking whether the Reciever FIFO is full
* Timeout Error - If the reciver pin is low for four character frame

## Directory Structure

rtl/              RTL Design Files

tb/               UVM Environment, Scoreboard, Top

test/             UVM Test Cases

apb_agent_top/    APB Agent Components

uart_agent_top/   UART Agent Components

sim/              Makefile

## Tools Used

* Verilog
* SystemVerilog
* UVM
* QuestaSim
* Git
* GitHub

## Results

* Successfully verified APB UART functionality using UVM methodology.
* Developed reusable APB and UART verification agents.
* Executed directed and randomized test scenarios.
* Functional verification completed with scoreboard-based checking and Assertions.
  
### Functional Coverage
<img width="960" height="504" alt="Screenshot 2026-06-18 114805" src="https://github.com/user-attachments/assets/604ece37-e494-4f76-a5fe-1d176c8774a8" />

### Wave Form
<img width="960" height="504" alt="Screenshot 2026-06-18 115248" src="https://github.com/user-attachments/assets/0d53dc74-f32d-428c-8a08-51b9654c2481" />


### Terminal Output
<img width="475" height="539" alt="Screenshot 2026-06-19 125517" src="https://github.com/user-attachments/assets/05c29308-0549-4cb4-bf31-dac6e737980a" />
<img width="810" height="374" alt="Screenshot 2026-06-19 125648" src="https://github.com/user-attachments/assets/a649bea1-176f-4ae1-84b3-9904353af99b" />


  

