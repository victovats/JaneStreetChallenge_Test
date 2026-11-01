## How it works

A registered unsigned multiplier. The 8-bit operand **A** comes from `ui_in[7:0]` and the 7-bit operand **B** from `uio_in[6:0]`. On each rising clock edge the 15-bit product `A * B` is stored in a register.

Because only 8 output pins are available, `uio_in[7]` (BYTE_SEL) chooses which byte of the product appears on `uo_out`:

- `BYTE_SEL = 0`: `uo_out = P[7:0]`
- `BYTE_SEL = 1`: `uo_out = {0, P[14:8]}`

BYTE_SEL is registered too, so the output always matches the inputs from the previous clock edge. All `uio` pins are inputs.

## How to test

1. Hold `rst_n` low for a few clock cycles, then release it. `uo_out` reads 0 after reset.
2. Set A on `ui_in` and B on `uio_in[6:0]` with `uio_in[7] = 0`, clock once, and read the low byte from `uo_out`.
3. Set `uio_in[7] = 1`, clock once, and read the high byte.

Example: A = 255, B = 127 gives 32385 = 0x7E81, so the low byte is 0x81 and the high byte is 0x7E.

## External hardware

None.
