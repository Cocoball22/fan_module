`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////
// dht module
module dht11_fan(
        input clk,
        input reset_p,
        inout dht11_data,
        output  led_G, 
        output  led_Y,
        output  led_R,
        output [15:0] value
);
        wire [7:0] humidity, temperature;  // ?˜¨?Šµ?„ ?°?´?„°ê°? ì¶œë ¥
        dht11_cntr dht11_inst(
            .clk(clk), 
            .reset_p(reset_p), 
            .dht11_data(dht11_data), 
            .humidity(humidity), 
            .temperature(temperature)
        );
        
        wire [15:0] humidity_bcd, temperature_bcd;  // 2ì§„í™” 10ì§„ìˆ˜ ë³??™˜
        bin_to_dec bcd_humidity(
            .bin({4'b0, humidity}), 
            .bcd(humidity_bcd)
        );
        bin_to_dec bcd_temperature(
            .bin({4'b0, temperature}), 
            .bcd(temperature_bcd)
        );
    
        assign led_G = (temperature > 8'd24 && temperature <= 8'd27) ? 1 : 0;
        assign led_Y = (temperature > 8'd27 && temperature < 8'd30) ? 1 : 0;
        assign led_R = (temperature >= 8'd30) ? 1 : 0;
        
         assign value = {humidity_bcd[7:0], temperature_bcd[7:0]};
    
    endmodule

///////////////////////////////////////////////
// standard white led
module fan_white_led(
        input clk, reset_p,
        input reset_w_led,
        input [3:0] btn,
        output led_r, led_g, led_b
    );
    
        reg [31:0] clk_div;
        reg [2:0] brightness;  // ë°ê¸° ?‹¨ê³„ë?? ?œ„?•œ 2ë¹„íŠ¸ ë³??ˆ˜
    
        // ?´?Ÿ­ ë¶„ì£¼ê¸?
        always @(posedge clk or posedge reset_p) begin
            if (reset_p)
                clk_div = 0;
            else
                clk_div = clk_div + 1;
        end
    
        // ë²„íŠ¼ ?ˆŒë¦? ê°ì?
        wire btn_white_led;
        button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pedge(btn_white_led));
    
        // ë°ê¸° ?‹¨ê³? ì¡°ì ˆ (ë²„íŠ¼?„ ?ˆ„ë¥? ?•Œë§ˆë‹¤)
        always @(posedge clk or posedge reset_p) begin
            if (reset_p || reset_w_led) brightness = 2'b00;
            else if (btn_white_led) begin
                if (brightness == 2'b11) // ìµœë? ë°ê¸°?—?„œ ?‹¤?‹œ ì²˜ìŒ?œ¼ë¡?
                    brightness = 2'b00; 
                else
                   brightness = brightness + 1;
            end
        end
    
        wire [31:0] duty_r, duty_g, duty_b;
    
        // ê°? ?ƒ‰?ƒë³„ë¡œ ë°ê¸° ?‹¨ê³„ì— ?”°ë¥? ???‹° ?‹¸?´?´ ?„¤? •
        assign duty_r = (brightness == 2'b00) ? 32'd0 : 
                        (brightness == 2'b01) ? 32'd20 :
                        (brightness == 2'b10) ? 32'd50 : 
                                                 32'd100; //0%,20%,50%,100%
    
        assign duty_g = duty_r;  // ?™?¼?•œ ???‹° ?‹¸?´?´ ?‚¬?š© (?•„?š”?‹œ ê°? ?ƒ‰?ƒë³„ë¡œ ?‹¤ë¥´ê²Œ ?„¤? • ê°??Š¥)
        assign duty_b = duty_r;  // ?™?¼?•œ ???‹° ?‹¸?´?´ ?‚¬?š©
    
        
        pwm_Nstep_freq#(
            .duty_step(100)) pwm_r( .clk(clk), .reset_p(reset_p), .duty(duty_r), .pwm(led_r));
        pwm_Nstep_freq#(
            .duty_step(100)) pwm_g( .clk(clk), .reset_p(reset_p), .duty(duty_g), .pwm(led_g));
        pwm_Nstep_freq#(
            .duty_step(100)) pwm_b( .clk(clk), .reset_p(reset_p), .duty(duty_b), .pwm(led_b));
    
endmodule

// ìº í•‘ëª¨ë“œ ì£¼í™©?ƒ‰ LED ë°ê¸° ì¡°ì ˆ ì½”ë“œ
////////////////////////////////////////////////////////////////////////
module camp_yellow_led(
        input clk, reset_p,
        input reset_y_led,
        input [3:0] btn,
        output y_led_r, y_led_g, y_led_b
    );
    
        reg [31:0] clk_div;
        reg [2:0] brightness;  // ë°ê¸° ?‹¨ê³„ë?? ?œ„?•œ 2ë¹„íŠ¸ ë³??ˆ˜
        
        // ?´?Ÿ­ ë¶„ì£¼ê¸?
        always @(posedge clk or posedge reset_p) begin
            if (reset_p)
                clk_div = 0;
            else
                clk_div = clk_div + 1;
        end
    
        // ë²„íŠ¼ ?ˆŒë¦? ê°ì?
        wire btn_yellow_led;
        button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pedge(btn_yellow_led));
    
        // ë°ê¸° ?‹¨ê³? ì¡°ì ˆ (ë²„íŠ¼?„ ?ˆ„ë¥? ?•Œë§ˆë‹¤)
        always @(posedge clk or posedge reset_p) begin
            if (reset_p || reset_y_led) brightness = 2'b00;
            else if (btn_yellow_led) begin
                if (brightness == 2'b11) // ìµœë? ë°ê¸°?—?„œ ?‹¤?‹œ ì²˜ìŒ?œ¼ë¡?
                    brightness = 2'b00; 
                else
                    brightness = brightness + 1;
            end
        end
    
        wire [31:0] duty_g, duty_r;
    
        // ì´ˆë¡?ƒ‰ LED?—ë§? ë°ê¸° ?‹¨ê³„ì— ?”°ë¥? ???‹° ?‹¸?´?´ ?„¤? •
        assign duty_g = (brightness == 2'b00) ? 32'd0 : 
                        (brightness == 2'b01) ? 32'd10 :
                        (brightness == 2'b10) ? 32'd20 :
                                                 32'd30; //0%,10%,20%,30%
        
         assign duty_r = (brightness == 2'b00) ? 32'd0 : 
                        (brightness == 2'b01) ? 32'd40 :
                        (brightness == 2'b10) ? 32'd70 : 
                                                 32'd100; //0%,40%,70%,100%
        
        pwm_Nstep_freq#(
            .duty_step(100)) pwm_g( .clk(clk), .reset_p(reset_p), .duty(duty_g), .pwm(y_led_g));
        pwm_Nstep_freq#(
            .duty_step(100)) pwm_r( .clk(clk), .reset_p(reset_p), .duty(duty_r), .pwm(y_led_r));
    
endmodule
module T_flip_flop_p_reset(
        input clk, reset_p,
        input t,
        input timer_reset,
        output reg q);
    
        always @(posedge clk or posedge reset_p)begin
            if(reset_p)q = 0;
            else begin
                if(t) q = ~q;
                else if(timer_reset) q = 0;
                else q = q;
            end
        end
endmodule

module dc_motor_pwm_mode(
        input clk, reset_p,
        input timer_reset,
        input [3:0] btn,
        output [15:0] led,
        output motor_pwm,
        output survo_pwm);
          
        button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pedge(btn_fan_step));
        button_cntr btn3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pedge(btn_fan_rotation));
       
        reg [2:0] led_count;
        reg [5:0] duty;
        always @(posedge clk or posedge reset_p)begin
                if(reset_p || timer_reset)begin
                        duty = 0;
                end
                else if(btn_fan_step) begin
                        duty = duty + 1;
                        if(duty >= 4) duty = 0;
                end
        end
       
        always @(posedge clk or posedge reset_p)begin
                    if(reset_p || timer_reset) led_count = 3'b000;
                    else if(btn_fan_step)begin
                        if(led_count == 3'b111) led_count = 3'b000;
                        else led_count = {led_count[1:0], 1'b1};
                    end
            end
           
         assign led = led_count;
       
         pwm_Nstep_freq #(
            .duty_step(4),
            .pwm_freq(100))
         pwm_motor(
            .clk(clk),        
            .reset_p(reset_p), 
            .duty(duty),      
            .pwm(motor_pwm)     
        );
       
         reg [31:0] clk_div;
    
        always @(posedge clk or posedge reset_p) begin
            if (reset_p)
                clk_div = 0;
            else
                clk_div = clk_div + 1;
        end
    
    
        wire clk_div_22_pedge;
    
    
        edge_detector_p ed(
            .clk(clk),
            .reset_p(reset_p),
            .cp(clk_div[22]),
            .p_edge(clk_div_22_pedge)
        );
       
        T_flip_flop_p_reset en(.clk(clk), .reset_p(reset_p),.t(btn_fan_rotation), .timer_reset(timer_reset), .q(on_off));
       
        reg [7:0] sv_duty;     
        reg down_up;    
        reg [7:0] duty_min, duty_max;
        always @(posedge clk or posedge reset_p) begin
            if (reset_p) begin
                sv_duty = 16;    
                down_up = 0;
                duty_min = 16;
                duty_max = 96;
            end
            else if (clk_div_22_pedge && on_off) begin
                if (timer_reset) begin
                    sv_duty = sv_duty;              
                end
                else if (!down_up) begin
                    if (sv_duty < duty_max) 
                        sv_duty = sv_duty + 1;
                    else
                        down_up = 1; 
                end
                else begin
                    if (sv_duty > duty_min)  
                        sv_duty = sv_duty - 1;
                    else
                        down_up = 0; 
                end
            end
        end
    
    
         pwm_Nstep_freq #(
            .duty_step(800),  
            .pwm_freq(50)  
               ) sv_motor(
            .clk(clk),
            .reset_p(reset_p),
            .duty(sv_duty),
            .pwm(survo_pwm)
        );
    

endmodule
/////////////////////////////////////////////////
// Timer Counter
module loadable_down_counter_state(
        input clk,
        input reset_p,
        input [3:0] btn,
        output reg [3:0] bcd1_out,
        output reg [3:0] bcd10_out,
        output reg timer_done);

        wire clk_usec, clk_msec, clk_sec;
        clock_div_100   usec_clk(.clk(clk), .reset_p(reset_p), .clk_div_100(clk_usec));  
        clock_div_1000  msec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_usec), .clk_div_1000(clk_msec));    
        clock_div_1000  sec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_nedge(clk_sec));
       
        button_cntr btn_timer_start(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pedge(next_timer));
             
        parameter S_0s  = 4'b0001;
        parameter S_3s  = 4'b0010;
        parameter S_5s  = 4'b0100;
        parameter S_10s = 4'b1000;
        reg [3:0] state, next_state;
       
            reg [3:0] bcd1, bcd10;
        always @(posedge clk or posedge reset_p) begin
            if (reset_p) state = S_0s;
            else state = next_state;
        end
       
            always @(negedge clk or posedge reset_p) begin
            if (reset_p) begin
                next_state = S_0s;
                bcd1 = 0;
                bcd10 = 0;
                timer_done = 0;
            end
            else begin
                case (state)
                    S_0s: begin
                        bcd1  = 3;
                        bcd10 = 0;
                        timer_done = 0;
                        if (next_timer) begin
                            timer_done = 0;
                            next_state = S_3s;
                        end
                    end
                    S_3s : begin
                        bcd1  = 5;
                        bcd10 = 0;
                        if(bcd1_out == 0 && bcd10_out == 0)begin
                            timer_done = 1;
                            next_state = S_0s;
                        end
                        else if (next_timer) begin
                            next_state = S_5s;
                        end
                    end
                    S_5s: begin
                        bcd1  = 0;
                        bcd10 = 1;
                        if(bcd1_out == 0 && bcd10_out == 0)begin
                            timer_done = 1;
                            next_state = S_0s;
                        end
                        else if (next_timer) begin
                            next_state = S_10s;
                        end
                    end
                    S_10s: begin
                        bcd1  = 0;
                        bcd10 = 0;
                        if(bcd1_out == 0 && bcd10_out == 0)begin
                            timer_done = 1;
                             next_state = S_0s;
                        end
                        else if (next_timer) begin
                            next_state = S_0s;
                        end
                    end
                    default: next_state = S_0s;
                endcase
            end
        end
       
        always @(posedge clk or posedge reset_p) begin
            if (reset_p) begin
                bcd1_out  = 0;
                bcd10_out = 0;
            end
            else if (next_timer) begin
                    bcd1_out  = bcd1;
                    bcd10_out = bcd10;
            end        
            else if (clk_sec) begin
                    if(bcd1_out == 0)begin
                        if(bcd10_out > 0)begin
                            bcd10_out = bcd10_out - 1;
                            bcd1_out  = 9;
                        end
                    end    
                    else begin
                            bcd1_out = bcd1_out - 1;
                    end    
            end
        end
endmodule
