`timescale 1ns / 1ps

module Matrix_Multiplier
#(
parameter
    BIT_SIZE = 8,
    ROW_COL_SIZE = 3,
    OUT_M_BIT_SIZE = BIT_SIZE * 2 + $clog2(ROW_COL_SIZE),
    LINE_SIZE = BIT_SIZE * ROW_COL_SIZE,
    OUT_M_LINE_SIZE = OUT_M_BIT_SIZE * ROW_COL_SIZE, 
    UNPACKED_MATRIX_SIZE = LINE_SIZE * ROW_COL_SIZE,
    UNPACKED_OUT_MATRIX_SIZE =  OUT_M_LINE_SIZE * ROW_COL_SIZE
)
(
    .n_rst(n_rst),
    .m1(m1),
    .m2(m2),
    .out_m(out_m)
);
    
input n_rst;    
input [0 : UNPACKED_MATRIX_SIZE - 1] m1;
input [0 : UNPACKED_MATRIX_SIZE - 1] m2;
output reg [0 : UNPACKED_OUT_MATRIX_SIZE - 1] out_m;

wire [BIT_SIZE - 1 : 0] w_m1_arr [0 : ROW_COL_SIZE - 1][0 : ROW_COL_SIZE - 1];
wire [BIT_SIZE - 1 : 0] w_m2_arr [0 : ROW_COL_SIZE - 1][0 : ROW_COL_SIZE - 1];
reg [OUT_M_BIT_SIZE - 1 : 0] r_out_m_arr [0 : ROW_COL_SIZE - 1][0 : ROW_COL_SIZE - 1];

genvar i, j;
generate
    for(i = 0; i < ROW_COL_SIZE; i = i + 1) begin : ARR_ROW
       for(j = 0; j < ROW_COL_SIZE; j = j + 1) begin : ARR_COL
           assign w_m1_arr[i][j] = m1[i * LINE_SIZE + j * BIT_SIZE +: BIT_SIZE];
           assign w_m2_arr[i][j] = m2[i * LINE_SIZE + j * BIT_SIZE +: BIT_SIZE];
       end
    end
endgenerate
    
integer k, l, a;
always@(*) begin
    if(!n_rst) begin
        for (k = 0; k < ROW_COL_SIZE; k = k + 1) begin
            for (l = 0; l < ROW_COL_SIZE; l = l + 1) begin
                r_out_m_arr[k][l] = 0;
            end
        end
        out_m = 0;
    end
    
    else begin
        for (k = 0; k < ROW_COL_SIZE; k = k + 1) begin : OUT_ARR_ROW
            for (l = 0; l < ROW_COL_SIZE; l = l + 1) begin : OUT_ARR_COL
                for (a = 0; a < ROW_COL_SIZE; a = a + 1) begin : ROW_COL_MULTIPLICATE 
                    r_out_m_arr[k][l] = r_out_m_arr[k][l] + w_m1_arr[k][a] * w_m2_arr[a][l];                    
                end //ROW_COLMULTIPLICATE END
                out_m[k * OUT_M_LINE_SIZE + l * OUT_M_BIT_SIZE +: OUT_M_BIT_SIZE] = r_out_m_arr[k][l];
            end//OUT_ARR_COL END
        end//OUT_ARR_ROW END
    end//else END
end // always end
    
endmodule
