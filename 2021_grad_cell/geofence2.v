module geofence ( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output reg valid;
output reg is_inside;
//reg valid;
//reg is_inside;
parameter IDLE=0,data=1,sort=2,cal=3,area=4,out=5;
reg[2:0] counter;
reg[2:0] state,next;
integer i;
reg switch;
wire[27:0] sqrt_in;
wire[13:0] sqrt_out;
reg area_switch;
reg[13:0] thi_side [0:5];

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		switch <= 0;
	end
	else begin
		case(state)
		sort:begin
			switch <= ~switch;
		end
		default:
			switch <= switch;
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		counter <= 0;
	end
	else begin
		case(state)
		data:begin
			if(counter==5)
				counter <= 0;
			else
				counter <= counter + 1;
		end
		sort:begin
			if(counter==4)
				counter <= 0;
			else
				counter <= counter + 1;
		end
		cal:begin
			if (counter == 5) begin
				counter  <= 0;
			end
			else begin
				counter <= counter + 1;
			end
		end
		area:begin
			if(counter == 6 )begin
				counter <= 0;
			end
		    else begin
		    	if (area_switch) begin
		    		counter <=counter + 1;
		   		 end
				else begin
					counter <= counter;
				end
		    end
		end
		out:begin
			if (counter == 2) begin
				counter <= 0;
			end
			else begin
				counter <= counter + 1;
			end
		end
		default:
			counter <= counter;
		endcase			
	end
end


always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		state <= data;
	end
	else begin
		state <= next;
	end
end

always @(*) begin
	if (reset) begin
		// reset
		next = 0;
	end
	else begin
		case(state)
		IDLE:begin
			next = data;
		end
		data:begin
		if(counter == 5)
			next = sort;
		else
			next = data;
		end
		sort:begin
			if(counter == 4)
				next = cal;
			else
				next = sort;
		end
		cal:begin
			if(counter == 5)
				next = area;
			else
				next = cal;
		end
		area:begin
			if (counter == 6) begin
				next = out;
			end
			else begin
				next = area;
			end
		end
		out:begin
			if (counter == 2) begin
				next = data;
			end
			else begin
				next = out;
			end
		end
		default:begin
			next = data;
		end
		endcase
	end
end

reg[9:0] x_temp[0:5];
reg[9:0] y_temp[0:5];
reg[10:0] r_temp[0:5];
reg signed[10:0] vec_x[0:4];
reg signed[10:0] vec_y[0:4];


always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i=0;i<6;i=i+1)begin
			x_temp[i] <= 0;
		end
	end
	else begin
		case(state)
		data:begin
			x_temp[counter] <= X;
		end
		sort:begin
			if(~switch)begin
				for(i=0;i<3;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						x_temp[i+1] <= x_temp[i+2];
						x_temp[i+2] <= x_temp[i+1];
					end
					else begin
						x_temp[i+1] <= x_temp[i+1];
						x_temp[i+2] <= x_temp[i+2];

					end
				end
			end
			else begin
				for(i=1;i<4;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						x_temp[i+1] <= x_temp[i+2];
						x_temp[i+2] <= x_temp[i+1];
					end
					else begin
						x_temp[i+1] <= x_temp[i+1];
						x_temp[i+2] <= x_temp[i+2];

					end
				end
			end
		end
		default:begin
			for(i=0;i<6;i=i+1)begin
				x_temp[i] <= x_temp[i];
			end
		end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i=0;i<6;i=i+1)begin
			y_temp[i] <= 0;
		end
	end
	else begin
		case(state)
		data:begin
			y_temp[counter] <= Y;
		end
		sort:begin
			if(~switch)begin
				for(i=0;i<5;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						y_temp[i+1] <= y_temp[i+2];
						y_temp[i+2] <= y_temp[i+1];
					end
					else begin
						y_temp[i+1] <= y_temp[i+1];
						y_temp[i+2] <= y_temp[i+2];

					end
				end
			end
			else begin
				for(i=1;i<4;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						y_temp[i+1] <= y_temp[i+2];
						y_temp[i+2] <= y_temp[i+1];
					end
					else begin
						y_temp[i+1] <= y_temp[i+1];
						y_temp[i+2] <= y_temp[i+2];

					end
				end
			end
		end
		default:begin
			for(i=0;i<6;i=i+1)begin
				y_temp[i] <= y_temp[i];
			end
		end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i=0;i<6;i=i+1)begin
			r_temp[i] <= 0;
		end
	end
	else begin
		case(state)
		data:begin
			r_temp[counter] <= R;
		end
		sort:begin
			if(~switch)begin
				for(i=0;i<3;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						r_temp[i+1] <= r_temp[i+2];
						r_temp[i+2] <= r_temp[i+1];
					end
					else begin
						r_temp[i+1] <= r_temp[i+1];
						r_temp[i+2] <= r_temp[i+2];

					end
				end
			end
			else begin
				for(i=1;i<4;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						r_temp[i+1] <= r_temp[i+2];
						r_temp[i+2] <= r_temp[i+1];
					end
					else begin
						r_temp[i+1] <= r_temp[i+1];
						r_temp[i+2] <= r_temp[i+2];

					end
				end
			end
		end
		default:begin
			for(i=0;i<6;i=i+1)begin
				r_temp[i] <= r_temp[i];
			end
		end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i=0;i<5;i=i+1)begin
			vec_x[i] <= 0;
		end
	end
	else begin
		case(state)
		data:begin
			if(counter >= 1)begin
				vec_x[counter-1] <= X - x_temp[0];
			end
			else begin
		    	vec_x[counter] <= vec_x[counter];
			end
		end
		sort:begin
			if(~switch)begin
				for(i=0;i<3;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						vec_x[i] <= vec_x[i+1];
						vec_x[i+1] <= vec_x[i];
					end
					else begin
						vec_x[i] <= vec_x[i];
						vec_x[i+1] <= vec_x[i+1];

					end
				end
			end
			else begin
				for(i=1;i<4;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						vec_x[i] <= vec_x[i+1];
						vec_x[i+1] <= vec_x[i];
					end
					else begin
						vec_x[i] <= vec_x[i];
						vec_x[i+1] <= vec_x[i+1];

					end
				end
			end
		end
		default:begin
			for(i=0;i<5;i=i+1)begin
				vec_x[i] <= vec_x[i];
			end
		end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i=0;i<5;i=i+1)begin
			vec_y[i] <= 0;
		end
	end
	else begin
		case(state)
		data:begin
			if(counter >= 1)begin
				vec_y[counter-1] <= Y - y_temp[0];
			end
			else begin
		    	vec_y[counter] <= vec_y[counter];
			end
		end
		sort:begin
			if(~switch)begin
				for(i=0;i<3;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						vec_y[i] <= vec_y[i+1];
						vec_y[i+1] <= vec_y[i];
					end
					else begin
						vec_y[i] <= vec_y[i];
						vec_y[i+1] <= vec_y[i+1];

					end
				end
			end
			else begin
				for(i=1;i<4;i=i+2)begin
					if((vec_x[i]*vec_y[i+1] - vec_y[i]*vec_x[i+1]) < 0)begin
						vec_y[i] <= vec_y[i+1];
						vec_y[i+1] <= vec_y[i];
					end
					else begin
						vec_y[i] <= vec_y[i];
						vec_y[i+1] <= vec_y[i+1];

					end
				end
			end
		end
		default:begin
			for(i=0;i<5;i=i+1)begin
				vec_y[i] <= vec_y[i];
			end
		end
		endcase
	end
end

reg[14:0] s_length [0:5];
always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i=0;i<6;i=i+1)begin
			s_length[i] <= 0;
		end
	end
	else begin
		case(state)
		cal:begin
			if(counter <5)
				s_length[counter] <= (({r_temp[counter],3'b000} + {r_temp[counter+1],3'b000} + sqrt_out + 3'b100) >> 1) >> 3;
			else
				s_length[counter] <= (({r_temp[counter],3'b000} + {r_temp[0],3'b000} + sqrt_out + 3'b100) >> 1) >> 3;
		end
		default:begin
			for(i=0;i<6;i=i+1)begin
				s_length[i] <= s_length[i];
			end
		end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		area_switch <= 0;
	end
	else begin
		case(state)
		area:begin
			area_switch <= !area_switch;
		end
		default:
			area_switch <= 0;
		endcase
	end
end


reg[27:0] sqrt_temp;
always@(*)begin
	case(state)
	cal:begin
		case(counter)
		5: begin
			sqrt_temp = (x_temp[counter] - x_temp[0]) * (x_temp[counter] - x_temp[0]) + (y_temp[counter] - y_temp[0]) * (y_temp[counter] - y_temp[0]);
		end
		default: begin
			sqrt_temp = (x_temp[counter] - x_temp[counter+1]) * (x_temp[counter] - x_temp[counter+1]) + (y_temp[counter] - y_temp[counter+1]) * (y_temp[counter] - y_temp[counter+1]);
		end
		endcase
	end
	area:begin
		if (!area_switch) begin
			if (counter < 6) begin
				if (s_length[counter] < r_temp[counter]) begin
					sqrt_temp = 0;
				end
				else begin
					sqrt_temp = (s_length[counter] - {r_temp[counter]}) * s_length[counter] + 3'b100;
				end
			end
			else begin
				sqrt_temp = 0;
			end
		end
		else begin
			if (counter < 5) begin
				if (s_length[counter] < r_temp[counter]) begin
					sqrt_temp = 0;
				end
				else begin
					sqrt_temp = (s_length[counter] - {r_temp[counter+1]}) * (s_length[counter] - thi_side[counter])+ 3'b100;
				end
			end
			else begin
				if (counter == 5) begin
					sqrt_temp = (s_length[counter] - {r_temp[0]}) * (s_length[counter] - thi_side[counter])+ 3'b100;
				end
				else begin
					sqrt_temp = 0;
				end
			end
		end
		
	end
	default:begin
		sqrt_temp = 0;
	end
	endcase
end

assign sqrt_in = (state == cal) ? (sqrt_temp << 6): sqrt_temp;
DW_sqrt #(28,0) sqrt(.a(sqrt_in),.root(sqrt_out));

always @(posedge clk or posedge reset) begin
	if (reset) begin
		for(i=0;i<6;i=i+1)begin
			thi_side[i] <= 0;
		end
	end
	else begin
		case(state)
		cal:begin
			thi_side[counter] <= (sqrt_out+ 3'b100) >> 3;
		end
		default:begin
			for(i=0;i<6;i=i+1)begin
				thi_side[i] <= thi_side[i];
			end
		end
		endcase
	end
end


reg[13:0] mul [0:1];
always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i=0;i<2;i=i+1)begin
			mul[i] <= 0;
		end
	end
	else begin
		case(state)
		data:begin
			for(i=0;i<2;i=i+1)begin
				mul[i] <= 0;
			end
		end
		area:begin
			if (!area_switch) begin
				mul[0] <= sqrt_out;
				mul[1] <= mul[1];
			end
			else begin
				mul[0] <= mul[0];
				mul[1] <= sqrt_out;
			end
		end
		default:begin
			for(i=0;i<2;i=i+1)begin
				mul[i] <= mul[i];
			end
		end
		endcase
	end
end

reg[27:0] area_temp;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		area_temp <= 0;
	end
	else begin
		case(state)
			data:begin
				area_temp <= 0;
			end
			area:begin
				if (counter != 0 && !area_switch) begin
					area_temp <= mul[0] * mul[1] + area_temp;
				end
				else begin
					area_temp <= area_temp;
				end
			end
			default:begin
				area_temp <= area_temp;
			end
			endcase
	end
end

reg signed[20:0] poly_area;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		poly_area <= 0;
	end
	else begin
		case(state)
		data:begin
			poly_area <= 0;
		end
		cal:begin
			if (counter == 5) begin
				poly_area <= poly_area + (x_temp[counter]*y_temp[0] - x_temp[0]*y_temp[counter]);
			end
			else begin
				poly_area <= poly_area + (x_temp[counter]*y_temp[counter+1] - x_temp[counter+1]*y_temp[counter] );
			end
		end
		area:begin
			if (counter == 0 && !area_switch) begin
				poly_area <= poly_area >> 1;
			end
			else begin
				poly_area <= poly_area;
			end
		end
		default:begin
			poly_area <= poly_area;
		end
		endcase
	end
end

reg[20:0] total_area;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		total_area <= 0;
	end
	else begin
		case(state)
		out:begin
			total_area <= area_temp;
		end
		default:begin
			total_area <= total_area;
		end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		is_inside <= 0;
	end
	else begin
		case(state)
		out:begin
			if(counter > 0)begin
				if(total_area > poly_area)begin
					is_inside <= 0;
				end
				else begin
					is_inside <= 1;
				end
			end
			else begin
				is_inside <= 0;
			end
		end
		default:begin
			is_inside <= 0;
		end
		endcase	
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		valid <= 0;
	end
	else begin
		case(state)
		out:begin
			if (counter == 1) begin
				valid <= 1;
			end
			else begin
				valid <= 0;
			end
		end
		default:begin
			valid <= 0;
		end
		endcase
	end
end
endmodule

