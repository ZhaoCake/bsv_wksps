package ExampleTB;

import Example::*;

module mkExampleTB (Empty);
    Counter dut <- mkCounter();
    Reg#(UInt#(8)) test_cycle <- mkReg(0);
    
    rule run_test;
        test_cycle <= test_cycle + 1;
        
        case (test_cycle)
            0: begin
                $display("=== Counter Testbench ===");
                dut.reset();
            end
            1, 2, 3, 4, 5: begin
                dut.increment();
                $display("Test %d: Incrementing", test_cycle);
            end
            6, 7, 8: begin
                dut.decrement();
                $display("Test %d: Decrementing", test_cycle);
            end
            9: begin
                dut.reset();
                $display("Test %d: Resetting", test_cycle);
            end
            default: begin
                if (test_cycle < 15) begin
                    dut.increment();
                    $display("Test %d: Final increment phase", test_cycle);
                end
            end
        endcase
    endrule
    
    rule check_value;
        let val <- dut.read();
        $display("Cycle %d: Counter value = %d", test_cycle, val);
        
        if (test_cycle >= 20) begin
            $display("=== Test completed ===");
            $finish();
        end
    endrule
endmodule

endpackage