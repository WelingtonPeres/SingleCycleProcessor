# Guia de Simulação - Single Cycle Processor

Instruções detalhadas para simular o processador em ModelSim.

## 📋 Requisitos

- ModelSim (versão 10.5c ou superior)
- Verilog compiler (vlog)
- Quartus Prime (opcional, para síntese)

## 🚀 Simulação Rápida (5 minutos)

### Passo 1: Compilar Testbench do ALU

```bash
cd SCProcessor
vlog ALU.v ALUTB.v
vsim -gui work.ALUTB
```

### Passo 2: Executar Simulação

```tcl
run 100 ns
```

**Esperado:**
- Testes de operações: ADD, SUB, AND, OR, SLT, NOR
- Zero flag ativa quando resultado é 0
- Overflow flag (se implementado)

## 🧪 Testes de Módulos Individuais

### 1. Teste do Register File

```bash
vlog RegisterFile.v RegisterFileTB.v
vsim -gui work.RegisterFileTB
run 50 ns
```

**Verifica:**
- Escrita em R[1] = 0xFF
- Leitura síncrona funciona
- R[0] permanece sempre 0

### 2. Teste da Memória de Instruções

```bash
vlog InstructionMemory.v InstructionMemoryTB.v
vsim -gui work.InstructionMemoryTB
run 100 ns
```

**Carrega:**
- Arquivo `.hex` com programa
- Endereços sequenciais retornam instruções

### 3. Teste de Controle

```bash
vlog MainDecoder.v ALUDecoder.v ControlUnit.v \
      MainDecoderTB.v ALUDecoderTB.v ControlUnitTB.v

vsim -gui work.ControlUnitTB
run 200 ns
```

**Valida:**
- Decodificação de opcodes R-type e I-type
- Sinais de controle corretos para cada instrução

## 🏃 Simulação Completa do Processador

### Compilação Completa

```bash
# Compilar todos os módulos
vlog *.v

# Simular
vsim -gui work.ProcessorTB
```

### Script TCL para Simulação Automática

```tcl
# run_simulation.do

vlib work
vlog *.v

vsim -gui work.ProcessorTB

# Executar simulação
run 1000 ns

# Salvar waveform
write wave.wlf

# Fechar
quit -sim
```

**Executar:**
```bash
vsim -do run_simulation.do
```

## 📊 Monitorando Sinais

### Adicionar Sinais ao Waveform

```tcl
# No prompt ModelSim
add wave -position end -format Logic /ProcessorTB/clk
add wave -position end -format Hex /ProcessorTB/PC
add wave -position end -format Hex /ProcessorTB/instr
add wave -position end -format Hex /ProcessorTB/WriteData
add wave -position end -format Hex /ProcessorTB/MemAddr
```

### Sinais Importantes para Debug

| Sinal | Formato | Descrição |
|-------|---------|-----------|
| `clk` | Logic | Clock |
| `reset` | Logic | Reset assíncrono |
| `PC` | Hex | Program Counter |
| `instr` | Hex | Instrução atual |
| `RegWrite` | Logic | Habilita escrita em registrador |
| `MemWrite` | Logic | Habilita escrita em memória |
| `ALUResult` | Hex | Saída da ALU |
| `ReadData1`, `ReadData2` | Hex | Dados lidos do RegisterFile |
| `WriteData` | Hex | Dado a ser escrito |

## 🐛 Debugging

### Problema: Simulação não avança

**Causa:** Sem clock ou clock com frequência muito alta

**Solução:**
```verilog
// Em ProcessorTB.v
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Period = 10ns → 100MHz
end
```

### Problema: ReadData nunca muda

**Causa:** RegisterFile não está sendo escrito

**Solução:**
1. Verificar se `RegWrite` está ativo
2. Validar banco de registradores em testbench
3. Verificar se endereço de escrita (`WriteAddr`) está correto

### Problema: Memória sempre retorna X (desconhecido)

**Causa:** Endereço inválido ou não inicializado

**Solução:**
```verilog
// Verificar arquivo de inicialização
$readmemh("program.hex", mem);
```

## 📝 Criando um Programa Teste

### 1. Escrever em Assembly

```mips
# Soma de dois números
ADDI $1, $0, 10      # R[1] = 10
ADDI $2, $0, 20      # R[2] = 20
ADD  $3, $1, $2      # R[3] = 30
SW   $3, 0($0)       # Mem[0] = 30
```

### 2. Converter para Hex

Usar ferramenta de assembler MIPS (Mars, SPIM, etc)

Ou manualmente:
```
ADDI $1, $0, 10  → 0x2001000A
ADDI $2, $0, 20  → 0x20020014
ADD  $3, $1, $2  → 0x00223820
SW   $3, 0($0)   → 0xAC030000
```

### 3. Criar Arquivo .hex

```hex
# program.hex (formato readmemh)
2001000A
20020014
00223820
AC030000
```

### 4. Carregar no Testbench

```verilog
initial begin
    $readmemh("program.hex", imem.mem);
end
```

## 🔍 Verificação de Resultados

### Monitorar Banco de Registradores

```verilog
// Em ProcessorTB.v
initial begin
    #1000;  // Após simulação
    
    // Print registradores
    for (i = 0; i < 32; i = i + 1)
        $display("R[%d] = %h", i, regfile.regs[i]);
end
```

### Monitorar Memória de Dados

```verilog
initial begin
    #1000;
    
    // Print primeiras 10 palavras
    for (i = 0; i < 10; i = i + 1)
        $display("Mem[%d] = %h", i*4, dmem.mem[i]);
end
```

## 📈 Performance

### Medir Frequência Máxima

1. Sintetizar em Quartus
2. Verificar relatório de timing
3. Verificar "Critical Path Delay"
4. Frequência máxima = 1 / (Critical Path Delay × 2)

**Exemplo:**
- Critical Path = 12 ns
- Máximo Clock = 1 / (12×2) ns = 41.6 MHz

## 🎬 Exemplo Completo de Sessão

```bash
# Terminal
$ cd SCProcessor
$ vsim -gui

# ModelSim GUI
> vlib work
> vlog *.v
> vsim work.ProcessorTB

# Console ModelSim
> run 1000 ns
> write simulation.wlf
> quit
```

## 📊 Interpretando Waveforms

### Bons Sinais

✅ Clock piscando regularmente
✅ PC incrementando (0 → 4 → 8 → 12...)
✅ RegWrite ativo quando deveria
✅ MemWrite ativo no SW
✅ Dados mudando após escrita

### Sinais Problemáticos

❌ PC congelado
❌ RegWrite sempre 0
❌ Todos sinais em X ou Z
❌ Nenhuma mudança após ciclo 0

## 🚀 Simulação Avançada

### Teste de Hazards (em Pipeline futuro)

```verilog
// Cenário: RAW (Read After Write)
// ADD $3, $1, $2
// ADD $4, $3, $5   ← Usa $3 imediatamente
```

### Teste de Branches

```mips
# Teste BEQ
ADDI $1, $0, 5
ADDI $2, $0, 5
BEQ  $1, $2, 3    # Desviar se iguais
ADDI $3, $0, 0
J 5               # Salto incondicional
```

## 💾 Salvando Resultados

```bash
# Salvar waveform
vsim> write my_simulation.wlf

# Salvar transcript
vsim> transcript file my_log.txt
vsim> transcript on
vsim> run 1000 ns
vsim> transcript off
```

---

**Dica:** Sempre começar com testes de módulos individuais antes de testar o processador completo!
