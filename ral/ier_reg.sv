class ier_reg extends uvm_reg;
        `uvm_object_utils(ier_reg)

        uvm_reg_field reserved;
        rand uvm_reg_field msr_intrpt;
        rand uvm_reg_field lsr_intrpt;
        rand uvm_reg_field thr_empty_intrpt;
        rand uvm_reg_field rcv_data_available_intrpt;

        //Constructor function
        function new(string name = "ier_reg")
                super.new(name,4,uvm_no_coverage);
        endfunction

        //Build function
        virtual function void build();
                msr_intrpt = uvm_reg_field::type_id::create("msr_intrpt");
                lsr_intrpt = uvm_reg_field::type_id::create("lsr_intrpt");
                thr_empty_intrpt = uvm_reg_field::type_id::create("thr_empty_intrpt");
                rcv_data_available_intrpt = uvm_reg_field::type_id::create("rcv_data_available_intrpt");

                msr_intrpt.configure(this,1,3,"RW",0,1'b0,1,1,0);
                lsr_intrpt.configure(this,1,2,"RW",0,1'b0,1,1,0);
                thr_empty_intrpt.configure(this,1,1,"RW",0,1'b0,1,1,0);
                rcv_data_available_intrpt.configure(this,1,0,"RW",0,1'b0,1,1,0);
        endfunction
endclass
