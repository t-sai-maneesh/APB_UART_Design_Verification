class dlr_reg extends uvm_reg;
        `uvm_object_utils(dlr_reg)

        rand uvm_reg_field dlr_msb;
        rand uvm_reg_field dlr_lsb;

        //Constructor function
        function new(string name = "dlrreg")
                super.new(name,16,uvm_no_coverage);
        endfunction

        //Build function
        virtual function void build();
                dlr_msb = uvm_reg_field::type_id::create("dlr_msb");
                dlr_lsb = uvm_reg_field::type_id::create("dlr_lsb");

                dlr_msb.configure(this,8,8,"RW",0,8'd0,1,1,1);
                dlr_lsb.configure(this,8,0,"RW",0,8'd0,1,1,1);
        endfunction
endclass
