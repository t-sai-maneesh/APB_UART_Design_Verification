module uart_assertions(pclk,presetn,paddr,pwdata,pwrite,penable,psel,rxd,prdata,pready,pslverr,irq,txd,baud_o);
	input pclk,presetn,pwrite,penable,psel,rxd,pready,pslverr,irq,txd,baud_o;
	input [7:0] paddr,pwdata,prdata;

	property rst;
		@(posedge pclk)
		!presetn |=> (psel === 1'b0 && penable === 0 && pready === 1'b0);
	endproperty

	//setup to access
	property setup2access;
		@(posedge pclk) disable iff(!presetn)
		(psel && !penable) |=> penable;
	endproperty

	//access state
	property access_state;
		@(posedge pclk) disable iff(!presetn)
		penable |-> psel;
	endproperty

	//Pready
	property pready_state;
		@(posedge pclk) disable iff(!presetn)
		(psel && penable) |=> ##[1:$] pready;
	endproperty

	RST: assert property(rst);
/*		$info("PASS: rst passed");
	else
		$error("FAIL: presetn:%0b, psel:%0b, penable:%0b, pready:%0b",presetn,psel,penable,pready);*/

	SP_ACS: assert property(setup2access);
		/*$info("PASS: setup2access is passed");
	else
		$error("FAIL: presetn:%0b, psel:%0b, penable:%0b, pready:%0b",presetn,psel,penable,pready);*/

	ACCESS: assert property(access_state);
	/*	$info("PASS: access state passed");
	else
		$error("FAIL: presetn:%0b, psel:%0b, penable:%0b, pready:%0b",presetn,psel,penable,pready);*/

	PREADY: assert property(pready_state);
	/*	$info("PASS: pready passed");
	else
		$error("FAIL: presetn:%0b, psel:%0b, penable:%0b, pready:%0b",presetn,psel,penable,pready);*/
endmodule
		
